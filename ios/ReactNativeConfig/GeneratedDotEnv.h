@import Foundation;

extern const NSDictionary *DOT_ENV;

@interface ReactNativeConfigTrampoline: NSObject

// Only sets up on first call.
+ (void)setup;

@end
