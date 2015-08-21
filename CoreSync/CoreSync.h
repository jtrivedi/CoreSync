//
//  CoreSync.h
//  CoreSync
//
//  Created by Janum Trivedi on 5/16/15.
//  Copyright (c) 2015 Styled Syntax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSMutableDictionary+CoreSync.h"

@interface CoreSync : NSObject

/**
 *  Calculates the delta between two NSMutableDictionary instances.
 *
 *  @param a The old dictionary object.
 *  @param b The current dictionary object.
 *
 *  @return An array of CoreSyncTransaction objects that make up the difference between the two dictionaries.
 */
+ (NSArray *)diffAsTransactions:(NSMutableDictionary *)a
                               :(NSMutableDictionary *)b;

/**
 *  Calculates the delta between two NSMutableDictionary instances.
 *
 *  @param a The old dictionary object.
 *  @param b The current dictionary object.
 *
 *  @return A JSON string representing an array of dictionaries representing CoreSyncTransaction objects.
 */
+ (NSString *)diffAsJSON:(NSMutableDictionary *)a
                        :(NSMutableDictionary *)b;

/**
 *  Sequentially applies each CoreSyncTransaction patch object in `transactions` to `a`. This "patches" `a`.
 *
 *  @param a            The dictionary to be patched.
 *  @param transactions An array of CoreSyncTransaction objects.
 */
+ (void)patch:(NSMutableDictionary *)a withTransactions:(NSArray *)transactions;

/**
 *  Deserializes the `json` parameter into an array of CoreSyncTransactions objects, then applies each transaction to `a`.
 *
 *  @param a    The dictionary to be patched.
 *  @param json The JSON string representing an array of JSON patches.
 */
+ (void)patch:(NSDictionary *)a withJSON:(NSString *)json;

@end
