#import "ReactNativeConfig.h"
#import "GeneratedDotEnv.m" // written during build by BuildDotenvConfig.ruby

@implementation ReactNativeConfig

+ (NSDictionary *)env {
    return (NSDictionary *)DOT_ENV;
}

+ (NSString *)envFor: (NSString *)key {
    NSString *envValue = (NSString *)[[[NSProcessInfo processInfo]environment]objectForKey:key];
    if (envValue) return envValue;
    NSString *value = (NSString *)[self.env objectForKey:key];
    return value;
}

@end
