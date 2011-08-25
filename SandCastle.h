#include <Foundation/Foundation.h>
#imclude <AppSupport/CPDistributedMessagingCenter.h>

@interface SandCastle : NSObject {
}

+ (void)createHardLinkToTarget:(NSString *)target fromPath:(NSString *)path;
+ (NSDictionary *) attributesForItemAtPath:(NSString *)path;
+ (void)createDirectoryAtResolvedPath:(NSString *)path;
+ (void)removeItemAtResolvedPath:(NSString *)path;
+ (void)moveTemporaryFile:(NSString *)file toResolvedPath:(NSString *)path;
+ (CPDistributedMessagingCenter *)center;
+ (NSString *)temporaryPathForFileName:(NSString *)fileName;

@end

