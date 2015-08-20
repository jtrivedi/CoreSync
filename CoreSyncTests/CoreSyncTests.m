//
//  CoreSyncTests.m
//  CoreSyncTests
//
//  Created by Janum Trivedi on 5/20/15.
//  Copyright (c) 2015 Styled Syntax. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import "CoreSync.h"

@interface CoreSyncTests : XCTestCase

@end

@implementation CoreSyncTests


#pragma mark - Tests

- (void)testDiffAndPatch
{
    NSMutableDictionary* a = [self a];
    NSMutableDictionary* b = [self b];
    
    NSString* jsonChanges = [[[CoreSync diff:a :b] mutableCopy] json];
    
    assert(![a isEqualToDictionary:b]);
    
    [CoreSync patch:a withJSON:jsonChanges];
    
    assert([a isEqualToDictionary:b]);
}


#pragma mark - Private

- (NSMutableDictionary *)a
{
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

- (NSMutableDictionary *)b
{
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

- (void)testDiffPerformance
{
    [self measureBlock:^{
        [self testDiffAndPatch];
    }];
}

@end
