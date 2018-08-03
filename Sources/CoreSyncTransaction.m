// CoreSyncTransaction.m
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

#import "CoreSyncTransaction.h"

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
