#import "HBReactNativeConfig.h"
#import "GeneratedDotEnv.m" // written during build by BuildDotenvConfig.ruby

@implementation HBReactNativeConfig

+ (NSDictionary *)env {
    return (NSDictionary *)DOT_ENV;
}

+ (NSString *)envFor: (NSString *)key {
    NSString *value = (NSString *)[self.env objectForKey:key];
    return value;
}

@end
