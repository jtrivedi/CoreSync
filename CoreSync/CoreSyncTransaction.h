//
//  CoreSyncTransaction.h
//  CoreSync
//
//  Created by Janum Trivedi on 5/17/15.
//  Copyright (c) 2015 Styled Syntax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CoreSyncTransaction : NSObject

typedef enum : NSUInteger {
    CSTransactionTypeAddition,
    CSTransactionTypeDeletion,
    CSTransactionTypeEdit,
} CSTransactionType;

@property (nonatomic, assign) CSTransactionType transactionType;
@property (nonatomic, strong) NSString* keyPath;
@property (nonatomic, strong) NSObject* value;

- (instancetype)initWithTransactionType:(CSTransactionType)type
                                keyPath:(NSString *)keyPath
                                  value:(NSObject *)value;

- (instancetype)initWithDictionary:(NSDictionary *)dict;

- (NSDictionary *)toDictionary;

@end
