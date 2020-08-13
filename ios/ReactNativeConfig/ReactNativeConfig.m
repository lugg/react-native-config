#import "ReactNativeConfig.h"
#import "GeneratedDotEnv.h" // .m is written during build by BuildDotenvConfig.ruby

@implementation ReactNativeConfig

+ (NSDictionary *)env {
    return (NSDictionary *)DOT_ENV;
}

+ (NSString *)envFor: (NSString *)key {
    NSString *value = (NSString *)[self.env objectForKey:key];
    return value;
}

@end
