#import "ReactNativeConfig.h"
#import "GeneratedDotEnv.m" // written during build by ./.build/PrepareReactNativeconfig/Contents/macOS/PrepareReactNativeconfig

@implementation ReactNativeConfig

RCT_EXPORT_MODULE()

+ (BOOL)requiresMainQueueSetup
{
    return YES;
}

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
