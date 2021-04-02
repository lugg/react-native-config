#import <Foundation/Foundation.h>

@interface ReactNativeConfig : NSObject

+ (NSDictionary *)env;
+ (NSString *)envFor: (NSString *)key;

@end
