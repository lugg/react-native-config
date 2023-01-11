#import <Foundation/Foundation.h>

@interface HBReactNativeConfig : NSObject

+ (NSDictionary *)env;
+ (NSString *)envFor: (NSString *)key;

@end
