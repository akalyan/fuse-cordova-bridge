#import <Cordova/CDVInvokedUrlCommand.h>

@interface CDVCommandFactory : NSObject

+ (id) initWithArguments:(NSArray*)arguments
              callbackId:(NSString*)callbackId
               className:(NSString*)className
              methodName:(NSString*)methodName;

@end
