// CoreSync.m
// Copyright (c) 2015 Janum Trivedi (http://janumtrivedi.com/)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "CoreSync.h"
#import "CoreSyncTransaction.h"
#import "NSMutableDictionary+CoreSync.h"

@implementation CoreSync

static const BOOL kShouldLog = NO;


#pragma mark - Diff API

+ (NSArray *)diffAsTransactions:(NSMutableDictionary *)a :(NSMutableDictionary *)b
{
    return [self diffDictionary:a :b root:@""];
}

+ (NSArray *)diffAsDictionary:(NSMutableDictionary *)a :(NSMutableDictionary *)b
{
    NSMutableArray* transactions = [self diffDictionary:a :b root:@""];
    
    return [self serializeTransactionsToArray:transactions];
}

+ (NSString *)diffAsJSON:(NSMutableDictionary *)a :(NSMutableDictionary *)b
{
    NSMutableArray* transactions = [self diffDictionary:a :b root:@""];
    
    NSArray* toArray = [self serializeTransactionsToArray:transactions];
    
    return [self toJSON:toArray];
}


#pragma mark - Patch API

+ (void)patch:(NSMutableDictionary *)a withTransactions:(NSArray *)transactions
{
    for (CoreSyncTransaction* transaction in transactions) {
        [a applyTransaction:transaction];
    }
}

+ (void)patch:(NSMutableDictionary *)a withJSON:(NSString *)json
{
    NSDictionary* transactions = [NSMutableDictionary dictionaryWithJSON:json];
    
    for (NSDictionary* transactionDict in transactions) {
        CoreSyncTransaction* transaction = [[CoreSyncTransaction alloc] initWithDictionary:transactionDict];
        [a applyTransaction:transaction];
    }
}


#pragma mark - Private functions

+ (NSArray *)serializeTransactionsToArray:(NSMutableArray *)transactions
{
    NSMutableArray* transactionDictionaries = [[NSMutableArray alloc] init];
    for (CoreSyncTransaction* transaction in transactions) {
        [transactionDictionaries addObject:transaction.toDictionary];
    }
    
    NSData* data = [NSJSONSerialization dataWithJSONObject:transactionDictionaries options:0 error:nil];
    return [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
}

+ (CoreSyncTransaction *)editWithPath:(id)path value:(NSObject *)value
{
    return [[CoreSyncTransaction alloc] initWithTransactionType:CSTransactionTypeEdit
                                                        keyPath:path
                                                          value:value];
}

+ (CoreSyncTransaction *)deletionWithPath:(id)path
{
    return [[CoreSyncTransaction alloc] initWithTransactionType:CSTransactionTypeDeletion
                                                        keyPath:path
                                                          value:nil];
}

+ (CoreSyncTransaction *)additionWithPath:(id)path value:(NSObject *)value
{
    return [[CoreSyncTransaction alloc] initWithTransactionType:CSTransactionTypeAddition
                                                        keyPath:path
                                                          value:value];
}


#pragma mark - Core Diff Algorithm

+ (NSMutableArray *)diffDictionary:(NSMutableDictionary *)a :(NSMutableDictionary *)b root:(NSString *)root
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

+ (NSMutableArray *)diffArray:(NSArray *)a :(NSArray *)b root:(NSString *)root
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

+ (BOOL)areEqual:(NSObject *)a :(NSObject *)b
{
    if (! [self areEqualType:a :b]) {
        return NO;
    }
    
    return [self areEqualValue:a :b];
}

+ (BOOL)areEqualValue:(NSObject *)a :(NSObject *)b
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

+ (BOOL)areEqualType:(NSObject *)a :(NSObject *)b
{
    return [a class] == [b class];
}

+ (NSArray *)sortedKeys:(NSDictionary *)dictionary
{
    return [dictionary.allKeys sortedArrayUsingComparator:^(id aK, id bK) {
        return [aK compare:bK options:NSNumericSearch];
    }];
}

+ (NSString *)toJSON:(id)JSONObject
{
    NSError* error;
    NSData* data = [NSJSONSerialization dataWithJSONObject:JSONObject options:NSJSONWritingPrettyPrinted error:&error];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

@end
