using Fuse;
using Fuse.Scripting;
using Fuse.Reactive;
using Uno.UX;
using Uno.Compiler.ExportTargetInterop;
using Uno;
using Uno.Collections;

[Require("Xcode.Framework","Foundation.framework")]
[ForeignInclude(Language.ObjC, "FuseCDVBridge.h")]

[UXGlobalModule]
public class FuseCDVBridge : NativeModule
{
  static readonly FuseCDVBridge _instance;

  extern(iOS) ObjC.Object _appDelegate;
  Dictionary<string, FuseCDVPluginAdapter> _pluginMap;
  List<string> _plugins;

  public FuseCDVBridge()
  {

    if (_instance == null) {
      debug_log("Initializing FuseCDVBridge");

      _instance = this;
      Uno.UX.Resource.SetGlobalKey(_instance, "FuseCDVBridge");
      debug_log("Set the global key FuseCDVBridge");

      _pluginMap = new Dictionary<string, FuseCDVPluginAdapter>();
      _plugins = new List<string>();

      if defined(iOS) {
        debug_log("Allocating app delegate");
        _appDelegate = AllocAppDelegateWithGlobalCallback(dispatchCallback);
      }
    }

  }

  public static FuseCDVBridge getInstance()
  {
    if (_instance != null)
      return _instance;

    return new FuseCDVBridge();
  }

  [Foreign(Language.ObjC)]
  extern(iOS)
  ObjC.Object AllocAppDelegateWithGlobalCallback(Action<string, int, string> cb)
  @{
    AppDelegate* appDelegate = [AppDelegate alloc];
    [appDelegate application:[UIApplication sharedApplication] didFinishLaunchingWithOptions:nil];
    [(FuseCDVCommandDelegate*)appDelegate.viewController.commandDelegate registerGlobalCallback:cb];
    return appDelegate;
  @}

  extern(iOS)
  void dispatchCallback(string callbackId, int status, string result)
  {
    debug_log("Got a result from command delegate");
    debug_log(callbackId + " " + status + " " + result);

    // iterate through all plugins and invoke callbackId
    foreach (var p in _plugins) {
      FuseCDVPluginAdapter plugin = _pluginMap[p];
      plugin.handlePluginResult(callbackId, status, result);
    }
  }

  extern(!iOS)
  void dispatchCallback(string callbackId, string result)
  {
    debug_log("TODO: support for non-iOS");
  }

  extern(!iOS)
  public void registerPlugin(string name, FuseCDVPluginAdapter plugin)
  {
    debug_log("registerPlugin not implemented on this platform");
  }

  extern(iOS)
  public void registerPlugin(string name, FuseCDVPluginAdapter plugin)
  {
    if (!_plugins.Contains(name)) {
      RegisterPlugin(_appDelegate, name, plugin.getNativePlugin());
      _pluginMap.Add(name, plugin);
      _plugins.Add(name);
    } else {
      debug_log("Trying to add plugin '" + name + "' that has already been registered");
    }
  }

  [Foreign(Language.ObjC)]
  extern(iOS)
  void RegisterPlugin(ObjC.Object appDelegate, string name, ObjC.Object plugin)
  @{
    [((AppDelegate *)appDelegate).viewController registerPlugin:plugin withClassName:name];
  @}

  extern(!iOS)
  void RegisterPlugin(object appDelegate, string name, object plugin)
  {
    debug_log("TODO: support for non-iOS");
  }
}
