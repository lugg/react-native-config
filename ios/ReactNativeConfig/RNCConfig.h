#import <Foundation/Foundation.h>

@interface RNCConfig : NSObject

+ (NSDictionary *)env;
+ (NSString *)envFor: (NSString *)key;

@end
