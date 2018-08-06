// NSMutableDictionary+CoreSync.m
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
        
        if ([self isNumeric:pathComponent]) {
            target = target[[pathComponent intValue]];
        }
        else {
            target = target[pathComponent];
        }
    }
    
    completionBlock(target, lastComponent);
}

- (BOOL)isValueFromKeyPathArray:(NSString *)keyPath
{
    NSArray* keyPathElements = [keyPath componentsSeparatedByString:@"."];
    for (NSString* element in keyPathElements) {
        if ([self isNumeric:element]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)isNumeric:(NSString *)string
{
    NSCharacterSet* notDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    if ([string rangeOfCharacterFromSet:notDigits].location == NSNotFound) {
        return YES;
    }
    return NO;
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

+ (NSDictionary *)dictionaryWithJSON:(NSString *)json
{
    NSError* error;
    NSData* data = [json dataUsingEncoding:NSUTF8StringEncoding];
    return [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
}

@end
