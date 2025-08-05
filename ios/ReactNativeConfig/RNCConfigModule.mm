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
    return @{ @"constants": RNCConfig.env };
}

- (NSDictionary *)getConstants {
    return self.constantsToExport;
}

#ifdef RCT_NEW_ARCH_ENABLED
- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:
    (const facebook::react::ObjCTurboModule::InitParams &)params
{
  return std::make_shared<facebook::react::NativeConfigModuleSpecJSI>(params);
}
#endif

@end
