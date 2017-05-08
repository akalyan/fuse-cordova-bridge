using Fuse;
using Fuse.Scripting;
using Fuse.Reactive;
using Uno.UX;
using Uno.Compiler.ExportTargetInterop;
using Uno;
using Uno.Text;
using Uno.Collections;

[ForeignInclude(Language.ObjC, "FuseCDVPluginUtilities.h")]

public class FuseCDVPluginAdapter : NativeModule
{
  // identifier used for this plugin
  protected internal string _ID;

  protected internal extern(iOS) ObjC.Object _nativeLib;
  protected internal FuseCDVBridge _bridge;

  Dictionary<string, Dictionary<string, object>> _contextCallbackMap;
  // { callbackId => { type => string(cordova), context => Context, success => Function, failure => Function}

  public FuseCDVPluginAdapter(string pluginId)
  {
    _ID = pluginId;
    _bridge = FuseCDVBridge.getInstance();
    _contextCallbackMap = new Dictionary<string, Dictionary<string, object>>();
  }

  extern(iOS)
  public ObjC.Object getNativePlugin() {
    return _nativeLib;
  }

  extern(iOS)
  public void handlePluginResult(string callbackId, int status, string jsonArgs) {
    debug_log(_ID + " - Got a result from command delegate");
    debug_log(callbackId + " " + status + " " + jsonArgs);

    if (_contextCallbackMap.ContainsKey(callbackId))
      InvokeCallbackClosure(callbackId, status, jsonArgs);
  }

  protected internal string RegisterCordovaCallbackClosure(Context c, Function successCb, Function failureCb)
  {
    string callbackId = GetUUID();
    debug_log(_ID + " - Adding " + callbackId + " to closure map for cordova requests");
    Dictionary<string, object> callbackMap = new Dictionary<string, object>();
    callbackMap.Add("context", c);
    callbackMap.Add("success", successCb);
    callbackMap.Add("failure", failureCb);
    callbackMap.Add("type", "cordova");
    _contextCallbackMap.Add(callbackId, callbackMap);

    return callbackId;
  }

  class InvokeClosure
  {
    Function _callback;
    string _arg;
    public InvokeClosure(Function callback, string arg)
    {
      _callback = callback;
      _arg = arg;
    }
    public void Call()
    {
      _callback.Call(_arg);
    }
  }

  protected internal void InvokeCallbackClosure(string callbackId, int status, string args)
  {
    Dictionary<string, object> callbackMap = _contextCallbackMap[callbackId];
    if (callbackMap != null)
    {
      Context context = callbackMap["context"] as Context;
      Function successCb = callbackMap["success"] as Function;
      Function failureCb = callbackMap["failure"] as Function;
      string type = callbackMap["type"] as string;

      if (context != null && type == "cordova")
      {
        // TODO: change this status check to reference the CDVCommandStatus enum in CDVPluginResult.h
        if (status == 9 && failureCb != null) { // CDVCommandStatus_ERROR
          context.Dispatcher.Invoke(new InvokeClosure(failureCb, args).Call);
        } else if (successCb != null) {
          context.Dispatcher.Invoke(new InvokeClosure(successCb, args).Call);
        }
      }
    }
  }

  protected string convertArgsArrayToJson(object[] args){
    var sb = new StringBuilder();
    sb.Append("[");
    for (int i = 0; i < args.Length; i++)
    {
      if (i > 0) sb.Append(",");
      sb.Append(Json.Stringify(args[i]));
    }
    sb.Append("]");

    return sb.ToString();
  }

  [Foreign(Language.ObjC)]
  extern(iOS)
  public void performSelector(ObjC.Object nativeLib, string selector, string callbackId, string jsonArgs)
  @{

    NSString* className = @{FuseCDVPluginAdapter:Of(_this)._ID:Get()};
    NSData* jsonData = [jsonArgs dataUsingEncoding:NSUTF8StringEncoding];
    NSError* jsonError;
    NSArray* args = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONWritingPrettyPrinted error:&jsonError];
    CDVInvokedUrlCommand* command =
      [CDVCommandFactory initWithArguments:args
                                callbackId:callbackId
                                 className:className
                                methodName:selector];

    NSString* selectorPlus = [NSString stringWithFormat:@"%@%@", selector, @":"];

    // TODO: research why performing on main thread works, and what the downsides are
    // [nativeLib performSelector:NSSelectorFromString(selectorPlus) withObject:command afterDelay:0];
    [nativeLib performSelectorOnMainThread:NSSelectorFromString(selectorPlus) withObject:command waitUntilDone:YES];
  @}

  [Foreign(Language.Java)]
  extern(Android)
  public static string GetUUID()
  @{
    return UUID.randomUUID().toString();
  @}

  [Foreign(Language.ObjC)]
  extern(iOS)
  public static string GetUUID()
  @{
    NSString *uuid = [[NSUUID UUID] UUIDString];
    return uuid;
  @}

  extern(!(iOS || Android))
  public static string GetUUID()
  {
    return "0000";
  }

}
