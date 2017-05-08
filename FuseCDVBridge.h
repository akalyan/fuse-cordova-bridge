#import <Cordova/CDVAppDelegate.h>
#import <Cordova/CDVViewController.h>
#import <Cordova/CDVCommandDelegate.h>
#import <Cordova/CDVCommandDelegateImpl.h>

@interface AppDelegate : CDVAppDelegate {}
@end

@interface MainViewController : CDVViewController
@end

@interface FuseCDVCommandDelegate : CDVCommandDelegateImpl

typedef void(^CallbackBlock)(NSString* callbackId, int status, NSString* args);
@property (nonatomic) CallbackBlock globalCallback;

- (void) registerGlobalCallback: (CallbackBlock) callback;

@end
