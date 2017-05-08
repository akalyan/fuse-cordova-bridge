using Fuse;
using Fuse.Scripting;
using Fuse.Reactive;
using Uno.UX;
using Uno.Compiler.ExportTargetInterop;
using Uno;
using Uno.Collections;

[Require("Xcode.Framework","Foundation.framework")]
[ForeignInclude(Language.ObjC, "FuseCDVPluginIncludes.h")]

[UXGlobalModule]
public class CDVTouchID : FuseCDVPluginAdapter
{
  static readonly CDVTouchID _instance;

  public CDVTouchID() : base("CDVTouchID")
  {
    if(_instance != null)
      return;

    _instance = this;
    Uno.UX.Resource.SetGlobalKey(_instance, _ID);

    AddMember(new NativeFunction("isAvailable", (NativeCallback)isAvailable));
    AddMember(new NativeFunction("didFingerprintDatabaseChange", (NativeCallback)didFingerprintDatabaseChange));
    AddMember(new NativeFunction("verifyFingerprint", (NativeCallback)verifyFingerprint));
    AddMember(new NativeFunction("verifyFingerprintWithCustomPasswordFallback", (NativeCallback)verifyFingerprintWithCustomPasswordFallback));
    AddMember(new NativeFunction("verifyFingerprintWithCustomPasswordFallbackAndEnterPasswordLabel", (NativeCallback)verifyFingerprintWithCustomPasswordFallbackAndEnterPasswordLabel));

    if defined(iOS)
      _nativeLib = AllocNativeLib();

    // needs to be done last
    _bridge.registerPlugin(_ID, this);
  }

  [Foreign(Language.ObjC)]
  extern(iOS)
  ObjC.Object AllocNativeLib()
  @{
    TouchID *plugin = [TouchID alloc];
    [plugin pluginInitialize];
    return plugin;
  @}

  object isAvailable(Context c, object[] args)
  {
    if defined(iOS) {
      Function successCb = args[0] as Function;
      Function failureCb = args[1] as Function;

      string callbackId = RegisterCordovaCallbackClosure(c, successCb, failureCb);

      performSelector(_nativeLib, "isAvailable", callbackId, "[]");
      return null;
    } else {
      debug_log "isAvailable is only implemented for iOS";
      return null;
    }
  }

  object didFingerprintDatabaseChange(Context c, object[] args)
  {
    if defined(iOS) {
      Function successCb = args[0] as Function;
      Function failureCb = args[1] as Function;

      string callbackId = RegisterCordovaCallbackClosure(c, successCb, failureCb);

      performSelector(_nativeLib, "didFingerprintDatabaseChange", callbackId, "[]");
      return null;
    } else {
      debug_log "didFingerprintDatabaseChange is only implemented for iOS";
      return null;
    }
  }

  object verifyFingerprint(Context c, object[] args)
  {
    if defined(iOS) {
      string prompt = args[0] as string;
      Function successCb = args[1] as Function;
      Function failureCb = args[2] as Function;

      string callbackId = RegisterCordovaCallbackClosure(c, successCb, failureCb);

      List<object> arguments = new List<object>();
      arguments.Add(prompt);

      performSelector(_nativeLib, "verifyFingerprint", callbackId, convertArgsArrayToJson(arguments.ToArray()));
      return null;
    } else {
      debug_log "verifyFingerprint is only implemented for iOS";
      return null;
    }
  }

  object verifyFingerprintWithCustomPasswordFallback(Context c, object[] args)
  {
    if defined(iOS) {
      string prompt = args[0] as string;
      Function successCb = args[1] as Function;
      Function failureCb = args[2] as Function;

      string callbackId = RegisterCordovaCallbackClosure(c, successCb, failureCb);

      List<object> arguments = new List<object>();
      arguments.Add(prompt);

      performSelector(_nativeLib, "verifyFingerprintWithCustomPasswordFallback", callbackId, convertArgsArrayToJson(arguments.ToArray()));
      return null;
    } else {
      debug_log "verifyFingerprintWithCustomPasswordFallback is only implemented for iOS";
      return null;
    }
  }

  object verifyFingerprintWithCustomPasswordFallbackAndEnterPasswordLabel(Context c, object[] args)
  {
    if defined(iOS) {
      string prompt = args[0] as string;
      string passwordPrompt = args[1] as string;
      Function successCb = args[2] as Function;
      Function failureCb = args[3] as Function;

      string callbackId = RegisterCordovaCallbackClosure(c, successCb, failureCb);

      List<object> arguments = new List<object>();
      arguments.Add(prompt);
      arguments.Add(passwordPrompt);

      performSelector(_nativeLib, "verifyFingerprintWithCustomPasswordFallbackAndEnterPasswordLabel", callbackId, convertArgsArrayToJson(arguments.ToArray()));
      return null;
    } else {
      debug_log "verifyFingerprintWithCustomPasswordFallbackAndEnterPasswordLabel is only implemented for iOS";
      return null;
    }
  }

}
