#import "ReactNativeConfig.h"
#import "GeneratedDotEnv.m" // written during build by BuildDotenvConfig.ruby

@implementation ReactNativeConfig

RCT_EXPORT_MODULE()

+ (NSDictionary *)env {
    return (NSDictionary *)DOT_ENV;
}

+ (NSString *)envFor: (NSString *)key {
    NSString *value = (NSString *)[self.env objectForKey:key];
    return value;
}

- (NSDictionary *)constantsToExport {
    return DOT_ENV
}

@end
