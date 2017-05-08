#import "FuseCDVPluginUtilities.h"

@implementation CDVCommandFactory

+ (id) initWithArguments:(NSArray*)arguments
              callbackId:(NSString*)callbackId
               className:(NSString*)className
              methodName:(NSString*)methodName
{
  return [[CDVInvokedUrlCommand alloc] initWithArguments:arguments
                                              callbackId:callbackId
                                               className:className
                                              methodName:methodName];
}

@end
