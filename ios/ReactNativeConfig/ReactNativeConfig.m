#import "ReactNativeConfig.h"

@implementation ReactNativeConfig

RCT_EXPORT_MODULE()

- (NSDictionary *)constantsToExport {

    NSError *jsonError = nil;
    NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"dotenv.json"];
    NSData *jsonData = [NSData dataWithContentsOfFile:filePath options:kNilOptions error:&jsonError ];

    NSLog(@"here");
    NSDictionary *env = (NSDictionary*) [NSKeyedUnarchiver unarchiveObjectWithData:jsonData];
    return env;
}

@end
