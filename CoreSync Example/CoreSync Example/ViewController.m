//
//  ViewController.m
//  CoreSync Example
//
//  Created by Tom Baranes on 03/08/2018.
//  Copyright © 2018 jtrivedi. All rights reserved.
//

#import "ViewController.h"
@import CoreSync;

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSDictionary *A = @{};
    NSDictionary *B = @{};
    [CoreSync diffAsJSON:A :B];
}

@end
