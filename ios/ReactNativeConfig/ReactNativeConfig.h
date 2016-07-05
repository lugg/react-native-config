#import "RCTBridgeModule.h"

@interface ReactNativeConfig : NSObject <RCTBridgeModule>
+ (NSDictionary *) constantsToExport;
@end
