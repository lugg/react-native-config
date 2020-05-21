#import "ReactNativeConfig.h"
#import "ReactNativeConfigModule.h"

@implementation ReactNativeConfigModule

RCT_EXPORT_MODULE()

+ (BOOL)requiresMainQueueSetup
{
    return YES;
}

+ (NSDictionary *)env {
    return ReactNativeConfig.env;
}

+ (NSString *)envFor: (NSString *)key {
    return [ReactNativeConfig envFor:key];
}

- (NSDictionary *)constantsToExport {
    return ReactNativeConfig.env;
}

@end
