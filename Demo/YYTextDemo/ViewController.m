//
//  ViewController.m
//  YYTextDemo
//
//  Created by ibireme on 15/10/17.
//  Copyright © 2015年 ibireme. All rights reserved.
//

#import "ViewController.h"
#import "YYTextExample.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    YYTextExample *vc = [YYTextExample new];
    [self pushViewController:vc animated:NO];
}



@end
