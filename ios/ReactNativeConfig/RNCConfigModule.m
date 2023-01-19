#import "RNCConfig.h"
#import "RNCConfigModule.h"

@implementation RNCConfigModule

RCT_EXPORT_MODULE()

+ (BOOL)requiresMainQueueSetup
{
    return YES;
}

+ (NSDictionary *)env {
    return RNCConfig.env;
}

+ (NSString *)envFor: (NSString *)key {
    return [RNCConfig envFor:key];
}

- (NSDictionary *)constantsToExport {
    return RNCConfig.env;
}

@end
