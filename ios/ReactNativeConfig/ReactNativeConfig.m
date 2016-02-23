//
//  ReactNativeConfig.m
//  ReactNativeConfig
//
//  Created by Pedro Belo on 2/22/16.
//  Copyright © 2016 Pedro Belo. All rights reserved.
//

#import "ReactNativeConfig.h"

@implementation ReactNativeConfig

RCT_EXPORT_MODULE()

- (NSDictionary *)constantsToExport {
//    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    return @{@"FOO": @"BAR"};
}

@end
