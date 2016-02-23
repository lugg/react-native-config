#import "ReactNativeConfig.h"
#import "GeneratedDotEnv.m" // written during build by BuildDotenvConfig.ruby

@implementation ReactNativeConfig

RCT_EXPORT_MODULE()

- (NSDictionary *)constantsToExport {

    return DOT_ENV

}
@end
