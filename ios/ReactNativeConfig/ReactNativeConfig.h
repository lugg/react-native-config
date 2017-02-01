#import <React/RCTBridgeModule.h>

@interface ReactNativeConfig : NSObject <RCTBridgeModule>

+ (NSDictionary *)env;
+ (NSString *)envFor: (NSString *)key;

@end
