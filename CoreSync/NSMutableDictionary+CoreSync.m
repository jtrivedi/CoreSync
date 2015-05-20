//
//  NSDictionary+CoreSync.m
//  CoreSync
//
//  Created by Janum Trivedi on 5/17/15.
//  Copyright (c) 2015 Styled Syntax. All rights reserved.
//

#import "NSMutableDictionary+CoreSync.h"

@implementation NSMutableDictionary (CoreSync)


- (void)applyTransaction:(CoreSyncTransaction *)transaction
{
    switch (transaction.transactionType) {
        case CSTransactionTypeAddition:
            [self add:transaction];
            break;
                
        case CSTransactionTypeDeletion:
            [self delete:transaction];
            break;

        case CSTransactionTypeEdit:
            [self edit:transaction];
            break;
    }
}

- (void)add:(CoreSyncTransaction *)transaction
{
    NSString* keyPath = [self cleanKeyPath:transaction.keyPath];
    
    if (! [self isValueFromKeyPathArray:keyPath]) {
        // Dictionary
        [self setValue:transaction.value forKeyPath:keyPath];
    }
    else {
        // Array
        [self returnTargetWithKeyPath:keyPath completionBlock:^(id target, NSString *lastComponent) {
            if ([target isKindOfClass:[NSArray class]]) {
                [(NSMutableArray *)target addObject:transaction.value];
            }
            else if ([target isKindOfClass:[NSDictionary class]]) {
                [(NSMutableDictionary *)target setObject:transaction.value forKey:lastComponent];
            }
        }];
    }
}

- (void)delete:(CoreSyncTransaction *)transaction
{
    NSString* keyPath = [self cleanKeyPath:transaction.keyPath];
    
    if (! [self isValueFromKeyPathArray:keyPath]) {
        // Dictionary
        [self removeObjectForKeyPath:keyPath];
    }
    else {
        // Array
        [self returnTargetWithKeyPath:keyPath completionBlock:^(id target, NSString *lastComponent) {
            if ([target isKindOfClass:[NSArray class]]) {
                [(NSMutableArray *)target removeObjectAtIndex:[lastComponent intValue]];
            }
            else if ([target isKindOfClass:[NSDictionary class]]) {
                [(NSMutableDictionary *)target removeObjectForKey:lastComponent];
            }
        }];
    }
}

- (void)edit:(CoreSyncTransaction *)transaction
{
    NSString* keyPath = [self cleanKeyPath:transaction.keyPath];
    
    if (! [self isValueFromKeyPathArray:keyPath]) {
        // Dictionary
        [self setValue:transaction.value forKeyPath:keyPath];
    }
    else {
        // Array
        [self returnTargetWithKeyPath:keyPath completionBlock:^(id target, NSString *lastComponent) {
            if ([target isKindOfClass:[NSArray class]]) {
                [(NSMutableArray *)target replaceObjectAtIndex:[lastComponent intValue] withObject:transaction.value];
            }
            else if ([target isKindOfClass:[NSDictionary class]]) {
                [(NSMutableDictionary *)target setObject:transaction.value forKey:lastComponent];
            }
        }];
    }
}

- (void)returnTargetWithKeyPath:(NSString *)keyPath completionBlock:(void (^)(id target, NSString* lastComponent))completionBlock
{
    NSMutableArray* components = [keyPath componentsSeparatedByString:@"."].mutableCopy;
    
    NSString* lastComponent = [components lastObject];
    
    id target = self;
    
    for (NSString* pathComponent in components) {
        if ([pathComponent isEqualToString:lastComponent]) {
            break;
        }
        
        if ([pathComponent containsString:@"["]) {
            NSString* component = pathComponent;
            component = [component stringByReplacingOccurrencesOfString:@"[" withString:@""];
            component = [component stringByReplacingOccurrencesOfString:@"]" withString:@""];
            
            target = target[[component intValue]];
        }
        else {
            target = target[pathComponent];
        }
    }
    
    if ([lastComponent containsString:@"["]) {
        lastComponent = [lastComponent stringByReplacingOccurrencesOfString:@"[" withString:@""];
        lastComponent = [lastComponent stringByReplacingOccurrencesOfString:@"]" withString:@""];
    }
    
    completionBlock(target, lastComponent);
}


- (BOOL)isValueFromKeyPathArray:(NSString *)keyPath
{
    return [keyPath containsString:@"["];
}

- (NSString *)cleanKeyPath:(NSString *)keyPath
{
    keyPath = [keyPath stringByReplacingOccurrencesOfString:@"/" withString:@"."];
    keyPath = [keyPath substringFromIndex:1];
    return keyPath;
}

- (void)removeObjectForKeyPath:(NSString *)keyPath
{
    NSArray* keyPathElements = [keyPath componentsSeparatedByString:@"."];
    NSUInteger numElements = [keyPathElements count];

    if (numElements == 1) {
        [self removeObjectForKey:keyPath];
    }
    else {
        NSString* keyPathHead = [[keyPathElements subarrayWithRange:(NSRange){0, numElements - 1}] componentsJoinedByString:@"."];
        NSMutableDictionary * tailContainer = [self valueForKeyPath:keyPathHead];
        [tailContainer removeObjectForKey:[keyPathElements lastObject]];
    }
}

- (NSString *)json
{
    NSError* error;
    NSData* data = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:&error];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

+ (NSDictionary *)dictionaryWithJSON:(NSString *)json
{
    NSError* error;
    NSData* data = [json dataUsingEncoding:NSUTF8StringEncoding];
    return [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
}

@end
