//
//  CoreSyncTransaction.m
//  CoreSync
//
//  Created by Janum Trivedi on 5/17/15.
//  Copyright (c) 2015 Styled Syntax. All rights reserved.
//

#import "CoreSyncTransaction.h"
#import "NSMutableDictionary+CoreSync.h"

@implementation CoreSyncTransaction

- (instancetype)initWithTransactionType:(CSTransactionType)type
                                keyPath:(NSString *)keyPath
                                  value:(NSObject *)value {
    if (self == [super init]) {
        self.transactionType = type;
        self.keyPath = keyPath;
        self.value = value;
    }
    
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    if (self == [super init]) {
        NSString* operation = dict[@"op"];
        NSString* path = dict[@"path"];
        id value = dict[@"value"];
        
        self.keyPath = path;
        self.value = value;
        
        if ([operation isEqualToString:@"add"]) {
            self.transactionType = CSTransactionTypeAddition;
        }
        else if ([operation isEqualToString:@"replace"]) {
            self.transactionType = CSTransactionTypeEdit;
        }
        else if ([operation isEqualToString:@"remove"]) {
            self.transactionType = CSTransactionTypeDeletion;
        }
    }
    
    return self;
}

- (NSDictionary *)toDictionary
{
    NSDictionary* patch;
    switch (self.transactionType) {
        case CSTransactionTypeAddition:
            patch = @{
                      @"op" : @"add",
                      @"path" : self.keyPath,
                      @"value" : self.value,
                      };
            break;
            
        case CSTransactionTypeDeletion:
            patch = @{
                      @"op" : @"remove",
                      @"path" : self.keyPath,
                      };
            break;
            
        case CSTransactionTypeEdit:
            patch = @{
                      @"op" : @"replace",
                      @"path" : self.keyPath,
                      @"value" : self.value,
                      };
            break;
    }
    
    return patch;
}

- (id)keyFromKeyPath
{
    return [[self.keyPath componentsSeparatedByString:@"/"] lastObject];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"Type: %lu, Keypath: %@, Value: %@", (unsigned long)self.transactionType, self.keyPath, self.value];
}

@end
