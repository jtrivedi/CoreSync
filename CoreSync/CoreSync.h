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

+ (CoreSync *)sharedManager;

- (NSDictionary *)diff:(id)a :(id)b;

- (void)patch:(NSDictionary *)a withJSON:(NSString *)json;

- (NSMutableDictionary *)a;
- (NSMutableDictionary *)b;

@end
