#import "HBReactNativeConfig.h"
#import "HBReactNativeConfigModule.h"

@implementation HBReactNativeConfigModule

RCT_EXPORT_MODULE()

+ (BOOL)requiresMainQueueSetup
{
    return YES;
}

+ (NSDictionary *)env {
    return HBReactNativeConfig.env;
}

+ (NSString *)envFor: (NSString *)key {
    return [HBReactNativeConfig envFor:key];
}

- (NSDictionary *)constantsToExport {
    return HBReactNativeConfig.env;
}

@end