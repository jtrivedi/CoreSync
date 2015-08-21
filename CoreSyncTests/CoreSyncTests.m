// CoreSyncTests.m
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

#import <XCTest/XCTest.h>
#import "CoreSync.h"

@interface CoreSyncTests : XCTestCase

@end

@implementation CoreSyncTests


#pragma mark - Tests

- (void)testDiffAndPatchJSON
{
    NSDictionary* a = [self a];
    NSDictionary* b = [self b];
    
    NSString* JSONChanges = [CoreSync diffAsJSON:a :b];
    
    assert(![a isEqualToDictionary:b]);

    a = [CoreSync patch:a withJSON:JSONChanges];
    
    assert([a isEqualToDictionary:b]);
}

- (void)testDiffAndPatchTransactions
{
    NSDictionary* a = [self a];
    NSDictionary* b = [self b];

    NSArray* changes = [CoreSync diffAsTransactions:a :b];

    assert(![a isEqualToDictionary:b]);

    a = [CoreSync patch:a withTransactions:changes];

    assert([a isEqualToDictionary:b]);
}


#pragma mark - Private

- (NSDictionary *)a
{
    return @{
             @"a" : @"a",
             @"b" : @2,
             @"d" : @{
                     @"key1" : @"val1",
                     @"key2" : @"val2",
                     @"key4" : @"val4",
                     },
             @"e" : @[
                     @1, @3, @{
                         @"a" : @"b", @"b" : @"bVal", @"d" : @"dVal1",
                         },
                     @5,
                     ],
             };
}

- (NSDictionary *)b
{
    return @{
             @"a" : @"b",
             @"c": @3,
             @"d" : @{
                     @"key1" : @"val2",
                     @"key3" : @"val3",
                     @"key4" : @"val4",
                     },
             @"e" : @[
                     @1, @2, @{
                         @"a" : @"b", @"c" : @"e", @"d" : @"dVal2",
                         },
                     ],
             };
}

@end
