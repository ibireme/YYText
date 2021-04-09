//
//  YYTextHighlight+NSLink.m
//  YYTextDemo
//
//  Created by Frank on 2021/4/8.
//  Copyright © 2021 ibireme. All rights reserved.
//

#import "YYTextHighlight+NSLink.h"

@implementation YYTextHighlight (NSLink)

- (NSURL *)link {
    return self.userInfo[@"NSLink.URL"];
}

- (void)setLink:(NSURL *)link {
    NSMutableDictionary *info = self.userInfo ? [self.userInfo mutableCopy] : [NSMutableDictionary new];
    info[@"NSLink.URL"] = link;
    self.userInfo = info;
}

@end
