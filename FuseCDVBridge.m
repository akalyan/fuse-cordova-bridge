#import "FuseCDVBridge.h"

#pragma mark App Delegate

@implementation AppDelegate

- (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{
    self.viewController = [[MainViewController alloc] init];
    return YES; // [super application:application didFinishLaunchingWithOptions:launchOptions];
}

@end

#pragma mark View Controller

@implementation MainViewController

- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Uncomment to override the CDVCommandDelegateImpl used
        _commandDelegate = [[FuseCDVCommandDelegate alloc] initWithViewController:self];
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Uncomment to override the CDVCommandDelegateImpl used
        _commandDelegate = [[FuseCDVCommandDelegate alloc] initWithViewController:self];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

    // Release any cached data, images, etc that aren't in use.
}

#pragma mark View lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    // View defaults to full size.  If you want to customize the view's size, or its subviews (e.g. webView),
    // you can do so here.

    [super viewWillAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

@end

#pragma mark Command Delegate

@implementation FuseCDVCommandDelegate

/* To override the methods, uncomment the line in the init function(s)
 in MainViewController.m
 */

- (id)getCommandInstance:(NSString*)className
{
    return [super getCommandInstance:className];
}

- (NSString*)pathForResource:(NSString*)resourcepath
{
    return [super pathForResource:resourcepath];
}

- (void)registerGlobalCallback: (CallbackBlock) callback
{
    self.globalCallback = callback;
}

- (void)sendPluginResult:(CDVPluginResult*)result callbackId:(NSString*)callbackId
{
  CDV_EXEC_LOG(@"Exec(%@): Sending result. Status=%@", callbackId, result.status);
  // This occurs when there is are no win/fail callbacks for the call.
  if ([@"INVALID" isEqualToString:callbackId]) {
    return;
  }

  int status = [result.status intValue];
  NSString* argumentsAsJSON = nil;
  if (result.message != nil) {
   argumentsAsJSON = [result argumentsAsJSON];
  }
  
  self.globalCallback(callbackId, status, argumentsAsJSON);
}

@end
