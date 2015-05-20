
//
//  CoreSync.m
//  CoreSync
//
//  Created by Janum Trivedi on 5/16/15.
//  Copyright (c) 2015 Styled Syntax. All rights reserved.
//

#import "CoreSync.h"
#import "CoreSyncTransaction.h"
#import "NSMutableDictionary+CoreSync.h"


@implementation CoreSync

static const BOOL kShouldLog = NO;


+ (CoreSync *)sharedManager
{
    static CoreSync* sharedManager = nil;
    static dispatch_once_t isDispatched;
    
    dispatch_once(&isDispatched, ^{
        sharedManager = [[CoreSync alloc] init];
    });
    
    return sharedManager;
}


#pragma mark - Public API

- (NSDictionary *)diff:(id)a :(id)b
{
    NSMutableArray* diffTransactions = [self diffDictionary:a :b root:@""];

    return [self dictionaryFromTransactions:diffTransactions];
}

- (void)patch:(NSMutableDictionary *)a withJSON:(NSString *)json
{
    NSDictionary* transactions = [NSMutableDictionary dictionaryWithJSON:json][@"transactions"];
    
    for (NSDictionary* transactionDict in transactions) {
        CoreSyncTransaction* transaction = [[CoreSyncTransaction alloc] initWithDictionary:transactionDict];
        [a applyTransaction:transaction];
    }
}


#pragma mark - Test

- (NSMutableDictionary *)a {
    return @{
             @"a" : @"a",
             @"b" : @2,
             @"d" : @{
                     @"key1" : @"val1",
                     @"key2" : @"val2",
                     @"key4" : @"val4",
                     }.mutableCopy,
             @"e" : @[
                        @1, @3, @{
                                @"a" : @"b", @"b" : @"bVal", @"d" : @"dVal1",
                                }.mutableCopy,
                        @5,
                     ].mutableCopy,
             }.mutableCopy;
}

- (NSMutableDictionary *)b {
    return @{
             @"a" : @"b",
             @"c": @3,
             @"d" : @{
                     @"key1" : @"val2",
                     @"key3" : @"val3",
                     @"key4" : @"val4",
                     }.mutableCopy,
             @"e" : @[
                        @1, @2, @{
                                @"a" : @"b", @"c" : @"e", @"d" : @"dVal2",
                                }.mutableCopy,
                      ].mutableCopy,
             }.mutableCopy;
}

- (void)testDiff
{
//    NSMutableDictionary* a = [self a];
//    NSMutableDictionary* b = [self b];
//    
//    self.transactions = [[NSMutableArray alloc] init];
//    
//    [self diffDictionary:a :b root:@""];
//
////    [self transactionsToDictionary:YES];
//    
//    assert([a isEqualToDictionary:b] && a != b);
}

- (NSDictionary *)dictionaryFromTransactions:(NSMutableArray *)transactions
{
    NSMutableDictionary* transactionDictionary = [[NSMutableDictionary alloc] init];
    [transactionDictionary setObject:[[NSMutableArray alloc] init] forKey:@"transactions"];
    
    for (CoreSyncTransaction* transaction in transactions) {
        [transactionDictionary[@"transactions"] addObject:[transaction toDictionary]];
    }
    
    return transactionDictionary;
}

- (CoreSyncTransaction *)editWithPath:(id)path value:(NSObject *)value
{
    return [[CoreSyncTransaction alloc] initWithTransactionType:CSTransactionTypeEdit
                                                        keyPath:path
                                                          value:value];
}

- (CoreSyncTransaction *)deletionWithPath:(id)path
{
    return [[CoreSyncTransaction alloc] initWithTransactionType:CSTransactionTypeDeletion
                                                        keyPath:path
                                                          value:nil];
}

- (CoreSyncTransaction *)additionWithPath:(id)path value:(NSObject *)value
{
    return [[CoreSyncTransaction alloc] initWithTransactionType:CSTransactionTypeAddition
                                                        keyPath:path
                                                          value:value];
}

- (NSMutableArray *)diffDictionary:(NSMutableDictionary *)a :(NSMutableDictionary *)b root:(NSString *)root
{
    NSMutableArray* transactions = [[NSMutableArray alloc] init];
    
    NSArray* aKeys = [self sortedKeys:a];
    
    for (NSString* aKey in aKeys) {
        NSString* fullRoot = [NSString stringWithFormat:@"%@/%@", root, aKey];
        
        if (! b[aKey]) {
            if (kShouldLog) {
                NSLog(@"Key: %@/%@ was removed", root, aKey);
            }
            
            CoreSyncTransaction* delete = [self deletionWithPath:fullRoot];
            [transactions addObject:delete];
        }
        else {
            id aValue = a[aKey];
            id bValue = b[aKey];
            
            if ([self areEqual:aValue :bValue]) {
                if (kShouldLog) {
                    NSLog(@"Key: %@/%@ with value: %@ has not changed", root, aKey, a[aKey]);
                }
            }
            else {
                if ([aValue isKindOfClass:[NSDictionary class]]) {
                    [transactions addObjectsFromArray:[self diffDictionary:aValue :bValue root:fullRoot]];
                }
                else if ([aValue isKindOfClass:[NSArray class]]) {
                    [transactions addObjectsFromArray:[self diffArray:aValue :bValue root:fullRoot]];
                }
                else {
                    if (kShouldLog) {
                        NSLog(@"Key: %@/%@ has changed: %@ -> %@", root, aKey, aValue, bValue);
                    }
                    
                    CoreSyncTransaction* edit = [self editWithPath:fullRoot value:bValue];
                    [transactions addObject:edit];
                }
            }
        }
    }
    
    NSArray* bKeys = [self sortedKeys:b];
    for (NSString* bKey in bKeys) {
        if (! a[bKey]) {
            if (kShouldLog) {
                NSLog(@"Key: %@/%@ was added", root, bKey);
            }
            
            NSString* fullRoot = [NSString stringWithFormat:@"%@/%@", root, bKey];
            
            CoreSyncTransaction* add = [self additionWithPath:fullRoot value:b[bKey]];
            [transactions addObject:add];
        }
    }
    
    return transactions;
}

- (NSMutableArray *)diffArray:(NSArray *)a :(NSArray *)b root:(NSString *)root
{
    NSMutableArray* transactions = [[NSMutableArray alloc] init];
    
    if ([a isEqualToArray:b]) {
        return transactions;
    }
    
    NSUInteger min = MIN(a.count, b.count);
    NSUInteger max = MAX(a.count, b.count);
    
    for (NSUInteger i = 0; i < min; ++i) {
        if (! [self areEqual:a[i] :b[i]]) {
            
            NSNumber* index = [NSNumber numberWithInteger:i];
            NSString* fullPath = [NSString stringWithFormat:@"%@/[%@]", root, index];

            if ([a[i] isKindOfClass:[NSDictionary class]]) {
                [transactions addObjectsFromArray:[self diffDictionary:a[i] :b[i] root:fullPath]];
            }
            else if ([a[i] isKindOfClass:[NSArray class]]) {
                [transactions addObjectsFromArray:[self diffArray:a :b root:fullPath]];
            }
            else {
                if (kShouldLog) {
                    NSLog(@"Key: %@/[%lu] element changed: %@ -> %@", root, i, a[i], b[i]);
                }
                
                CoreSyncTransaction* edit = [self editWithPath:fullPath value:b[i]];
                [transactions addObject:edit];
            }
        }
    }

    for (NSUInteger i = min; i < max; ++i) {
        NSNumber* index = [NSNumber numberWithInteger:i];
        NSString* fullPath = [NSString stringWithFormat:@"%@/[%@]", root, index];
        
        if (b.count > a.count) {
            // Addition
            if (kShouldLog) {
                NSLog(@"Key: %@/[%lu] element was added: %@", root, i, b[i]);
            }

            CoreSyncTransaction* addition = [self additionWithPath:fullPath value:b[i]];
            [transactions addObject:addition];
        }
        else {
            // Deletion
            if (kShouldLog) {
                NSLog(@"Key: %@/[%lu] element was removed: %@", root, i, a[i]);   
            }
            
            CoreSyncTransaction* deletion = [self deletionWithPath:fullPath];
            [transactions addObject:deletion];
        }
    }
    
    return transactions;
}

- (BOOL)areEqual:(NSObject *)a :(NSObject *)b
{
    if (! [self areEqualType:a :b]) {
        return NO;
    }
    
    if ([self areEqualValue:a :b]) {
        return YES;
    }
    else {
        return NO;
    }
}

- (BOOL)areEqualValue:(NSObject *)a :(NSObject *)b
{
    if ([a isKindOfClass:[NSString class]]) {
        return [(NSString *)a isEqualToString:(NSString *)b];
    }
    else if ([a isKindOfClass:[NSNumber class]]) {
        return [(NSNumber *)a isEqualToNumber:(NSNumber *)b];
    }
    else if ([a isKindOfClass:[NSDictionary class]]) {
        return [(NSDictionary *)a isEqualToDictionary:(NSDictionary *)b];
    }
    else if ([a isKindOfClass:[NSArray class]]) {
        return [(NSArray *)a isEqualToArray:(NSArray *)b];
    }
    
    return NO;
}

- (BOOL)areEqualType:(NSObject *)a :(NSObject *)b
{
    return [a class] == [b class];
}

- (NSArray *)sortedKeys:(NSDictionary *)dictionary
{
    return [dictionary.allKeys sortedArrayUsingComparator:^(id aK, id bK) {
        return [aK compare:bK options:NSNumericSearch];
    }];
}

- (instancetype)init
{
    if (self == [super init]) {
//        [self testDiff];
    }
    
    return self;
}

@end
