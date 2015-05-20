//
//  TestController.m
//  CoreSync
//
//  Created by Janum Trivedi on 5/17/15.
//  Copyright (c) 2015 Styled Syntax. All rights reserved.
//

#import "TestController.h"
#import "CoreSync.h"

@implementation TestController

- (void)viewDidLoad
{
    CoreSync* manager = [CoreSync sharedManager];
    
    NSMutableDictionary* a = [manager a];
    NSMutableDictionary* b = [manager b];
    
    NSString* jsonChanges = [[[manager diff:a :b] mutableCopy] json];
    
    [manager patch:a withJSON:jsonChanges];
    
    assert([a isEqualToDictionary:b]);
}

- (instancetype)init
{
    if (self == [super init]) {
        [self viewDidLoad];
    }
    return self;
}

@end
