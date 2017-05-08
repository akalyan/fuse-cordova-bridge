# Fuse Cordova Bridge

## Description
This project let you use [Cordova](https://cordova.apache.org/) plugins in [Fuse](https://www.fusetools.com/) projects.

## Motivation
To give Fuse developers access to the hundreds of plugins available to Cordova developers. It drives me nuts that there are different versions of the same functionality for Cordova, React Native, NativeScript, and Fuse. This bridge serves to reduce the further proliferation of native plugins that basically do the same thing with slightly different glue code.

## How does it work?
To understand how the bridge works, it helps to have a little background on Cordova. Cordova plugins are classes that extend `CDVPlugin`. Each plugin method exposed to clients accept one parameter - a `CDVInvokedUrlCommand` - and send its result back through a `CDVCommandDelegate`.

In a typical Cordova application, those methods are called from within a web view. The web view request is converted to a native request (the mechanism changes depending on the capabilities of the web view). The native code is then executed, and the result is routed back to the web view through the `CDVCommandDelegate`. In this bridge, the `FuseCDVBridge` essentially plays the role of the web view and the `CDVCommandDelegate`.

## Usage
There's a little bit of glue that needs to be developed to use a Cordova plugin. Follow the included example project in which we wrap the cordova-plugin-touch-id plugin (I know that there is a community-contributed Fuse plugin for TouchID, but this was a good candidate for an example). Here are the steps:

- Add reference to this project in your .unoproj file, e.g.:
```
"Projects": [
  "../fuse-cordova-bridge.unoproj"
],
```
- Within your project, create a cordova project to house the cordova plugins you want to use
```
cordova create cordova-plugins
cd cordova-plugins
```
- In that cordova project, add your plugins
```
cordova plugin add <cordova-plugin-you-want-to-use>
```
- Add platform target (currently, the bridge only supports iOS)
```
cordova platform add ios
```
- Prepare the cordova project
```
cordova prepare
```
- Create FuseCDVPluginIncludes.h file to house all the imports of the cordova plugins
- Add the source files for the plugin and the FuseCDVPluginIncludes.h to your projects .unoproj file
- Create a NativeModule for the plugin (extension of `FuseCDVPluginAdapter`, which does all the heavy lifting) so you can access the plugin's API. See `CDVTouchID` in the included example project for a blueprint, but for each exposed method, follow the pattern in the example commented below:
```
  object verifyFingerprint(Context c, object[] args)
  {
    // again, the bridge only works on iOS right now
    if defined(iOS) {

      // Step 1 - parse out the arguments (these arguments would match the plugin's JS API)
      string prompt = args[0] as string;
      Function successCb = args[1] as Function;
      Function failureCb = args[2] as Function;

      // Step 2 - register the callbacks and generate callbackId
      string callbackId = RegisterCordovaCallbackClosure(c, successCb, failureCb);

      // Step 3 - create arguments list that plugin method is expecting
      List<object> arguments = new List<object>();
      arguments.Add(prompt);

      // Step 4 - call the selector with callbackId and JSON-stringified args
      performSelector(_nativeLib, "verifyFingerprint", callbackId, convertArgsArrayToJson(arguments.ToArray()));

      return null;
    } else {
      debug_log "verifyFingerprint is only implemented for iOS";
      return null;
    }
  }
```
  - One more note: the name of your `NativeModule` (i.e. extension of `FuseCDVPluginAdapter`) should be different than the name of the `CDVPlugin` class you're wrapping to avoid a naming conflict.

## Building your project
The biggest change to the build process for a project that uses the bridge is to link the CordovaLib. To do that:

- Add `-ObjC` to 'Other linker flags' in Build Settings. Why? Cordova seems to need it to add the `cdv_JSONString`method to the `NSArray` implementation. From the docs:
> This flag causes the linker to load every object file in the library that defines an Objective-C class or category. While this option will typically result in a larger executable (due to additional object code loaded into the application), it will allow the successful creation of effective Objective-C static libraries that contain categories on existing classes.
- Link `libCordova.a`
  - Select project
  - Build Phases tab
  - Link Binaries With Libraries
  - Add items (the plus sign on the bottom of the panel)
  - Add Other
  - Select `CordovaLib.xcodeproj` (under `cordova-plugins/platforms/ios/CordovaLib/`)
  - Add items (again)
  - Select `libCordova.a`
- Add `CordovaLib` as target
  - Build Phases tab
  - Target Dependencies
  - Add items
  - Select `CordovaLib`
