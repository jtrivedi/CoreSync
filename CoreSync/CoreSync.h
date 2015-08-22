// CoreSync.h
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

#import <Foundation/Foundation.h>

@interface CoreSync : NSObject

/**
 *  Calculates the delta between two NSMutableDictionary instances.
 *
 *  @param a The original dictionary object.
 *  @param b The new dictionary object.
 *
 *  @return An array of CoreSyncTransaction objects that make up the difference between the two dictionaries.
 */
+ (NSArray *)diffAsTransactions:(NSDictionary *)a
                               :(NSDictionary *)b;

/**
 *  Calculates the delta between two NSMutableDictionary instances.
 *
 *  @param a The original dictionary object.
 *  @param b The new dictionary object.
 *
 *  @return A JSON string representing an array of dictionaries representing CoreSyncTransaction objects.
 */
+ (NSString *)diffAsJSON:(NSDictionary *)a
                        :(NSDictionary *)b;

/**
 *  Creates a copy of `a` and sequentially applies each CoreSyncTransaction patch in `transactions` to it.
 *
 *  @param a            The original dictionary to be patched.
 *  @param transactions An array of CoreSyncTransaction objects.
 *
 *  @return             A copy of the patched dictionary.
 */
+ (NSDictionary *)patch:(NSDictionary *)a withTransactions:(NSArray *)transactions;

/**
 *  Deserializes the `json` parameter into an array of CoreSyncTransactions patch objects, then applies each transaction to a copy of `a`.
 *
 *  @param a    The original dictionary to be patched.
 *  @param json The JSON string representing an array of JSON patches.
 *
 *  @return     A copy of the patched dictionary.
 */
+ (NSDictionary *)patch:(NSDictionary *)a withJSON:(NSString *)json;

@end
