//
//  CoreSyncTests.m
//  CoreSyncTests
//
//  Created by Janum Trivedi on 5/20/15.
//  Copyright (c) 2015 Styled Syntax. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CoreSync.h"

@interface CoreSyncTests : XCTestCase

@end

@implementation CoreSyncTests


#pragma mark - Tests

- (void)testDiffAndPatchJSON
{
    NSMutableDictionary* a = [self a];
    NSMutableDictionary* b = [self b];
    
    NSString* JSONChanges = [CoreSync diffAsJSON:a :b];
    
    assert(![a isEqualToDictionary:b]);

    [CoreSync patch:a withJSON:JSONChanges];
    
    assert([a isEqualToDictionary:b]);
}

- (void)testDiffAndPatchTransactions
{
    NSMutableDictionary* a = [self a];
    NSMutableDictionary* b = [self b];

    NSArray* changes = [CoreSync diffAsTransactions:a :b];

    assert(![a isEqualToDictionary:b]);

    [CoreSync patch:a withTransactions:changes];

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

@end
