# Config variables for React Native apps

Module to expose config variables to your javascript code in React Native, supporting both iOS (Objective-C & Swift) and Android.

Bring some [12 factor](http://12factor.net/config) love to your mobile apps!


## Basic Usage

Create a new file `.env.debug.json` & `.env.release.json`in the root of your React Native app:

```
{
"env": 
  {
    "<#key#>": 
        {
            "value": "https://<#your domain#>",
            "valueType": "Url"
        },
    "<#second key#>": 
        {
        "value": "<#string value#>",
        "valueType": "String"
        }
  }
}
```

Then access variables defined there from your app:

// TODO: Currently there is a bug with this

```js
import Config from 'react-native-config'

Config.API_URL  // 'https://myapi.com'
Config.GOOGLE_MAPS_API_KEY  // 'abcdefgh'
```

Keep in mind this module doesn't obfuscate or encrypt secrets for packaging, so **do not store sensitive keys in `.env`**. 

It's [basically impossible to prevent users from reverse engineering mobile app secrets](https://rammic.github.io/2015/07/28/hiding-secrets-in-android-apps/), so design your app (and APIs) with that in mind.
// TODO: add secret keys in both android and iOS that are stored using git_secret and secure storage for both Android and iOS to solve issue above [github issue #1](https://github.com/doozMen/react-native-config/issues/1)

## Setup

Install the package:

add  dependency to package.json

``` json
"dependencies": {
    "doozMen/react-native-config": "^1.0.0"
    }
```

```
cd <#project root#>
npm install
```

> ⚠️ Only works for project that use expokit and ejected the project

# iOS

In xcode project

1. Add project as a sub project and add product `ReactiveConfigSwift` to embed frameworks
2. Point framework search path to `$(BUILD_DIR)/$(CONFIGURATION)$(EFFECTIVE_PLATFORM_NAME)`
3. Point header search path to `$(BUILD_DIR)/$(CONFIGURATION)$(EFFECTIVE_PLATFORM_NAME)/include` and set it to **recursive**
4. Point library search path to `$(BUILD_DIR)/$(CONFIGURATION)$(EFFECTIVE_PLATFORM_NAME)`
5. Add `ReactiveConfig` as a target dependency
6. Link product `ReactiveConfig.a`

### Extra step for Android

You'll also need to manually apply a plugin to your app, from `android/app/build.gradle`:

```
// 2nd line, add a new apply:
apply from: project(':react-native-config').projectDir.getPath() + "/dotenv.gradle"
```


### Extra step for iOS (support Info.plist)

* Go to your project -> Build Settings -> All
* Search for "preprocess"
* Set `Preprocess Info.plist File` to `Yes`
* Set `Info.plist Preprocessor Prefix File` to `${BUILD_DIR}/GeneratedInfoPlistDotEnv.h`
* Set `Info.plist Other Preprocessor Flags` to `-traditional`
* If you don't see those settings, verify that "All" is selected at the top (instead of "Basic")


#### Advanced Android Setup

In `android/app/build.gradle`, if you use `applicationIdSuffix` or `applicationId` that is different from the package name indicated in `AndroidManifest.xml` in `<manifest package="...">` tag, for example, to support different build variants:
Add this in `android/app/build.gradle`

```
defaultConfig {
    ...
    resValue "string", "build_config_package", "YOUR_PACKAGE_NAME_IN_ANDROIDMANIFEST.XML"
}
```

## Native Usage

### Android

Config variables set in `.env` are available to your Java classes via `BuildConfig`:

```java
public HttpURLConnection getApiClient() {
    URL url = new URL(BuildConfig.API_URL);
    // ...
}
```

You can also read them from your Gradle configuration:

```groovy
defaultConfig {
    applicationId project.env.get("APP_ID")
}
```

And use them to configure libraries in `AndroidManifest.xml` and others:

```xml
<meta-data
  android:name="com.google.android.geo.API_KEY"
  android:value="@string/GOOGLE_MAPS_API_KEY" />
```

All variables are strings, so you may need to cast them. For instance, in Gradle:

```
versionCode project.env.get("VERSION_CODE").toInteger()
```

Once again, remember variables stored in `.env` are published with your code, so **DO NOT put anything sensitive there like your app `signingConfigs`.**

### iOS

#### Swift

``` swift
import ReactNativeConfigSwift

// API_URL is the key you added to the .env file
let apiURL = Environment.API_URL

```
#### Objective-C
Read variables declared in `.env` from your Obj-C classes like:

```objective-c
// import header
#import "ReactNativeConfig.h"

// then read individual keys like:
NSString *apiUrl = [ReactNativeConfig envFor:@"API_URL"];

// or just fetch the whole config
NSDictionary *config = [ReactNativeConfig env];
```

### Different environments

// TODO make this work again

Save config for different environments in different files: `.env.staging`, `.env.production`, etc.

By default react-native-config will read from `.env`, but you can change it when building or releasing your app.

The simplest approach is to tell it what file to read with an environment variable, like:

```
$ ENVFILE=.env.staging react-native run-ios           # bash
$ SET ENVFILE=.env.staging && react-native run-ios    # windows
$ env:ENVFILE=".env.staging"; react-native run-ios    # powershell
```

This also works for `run-android`. Alternatively, there are platform-specific options below.


#### Android

The same environment variable can be used to assemble releases with a different config:

```
$ cd android && ENVFILE=.env.staging ./gradlew assembleRelease
```

Alternatively, you can define a map in `build.gradle` associating builds with env files. Do it before the `apply from` call, and use build cases in lowercase, like:

```
project.ext.envConfigFiles = [
    debug: ".env.development",
    release: ".env.production",
    anothercustombuild: ".env",
]

apply from: project(':react-native-config').projectDir.getPath() + "/dotenv.gradle"
```


#### iOS
If you use `debug` and `release` configurations there is nothing more to do. If you do you need to for this repo and add your config.

## Prepare excutable

The files needed are generated using an executable app that is pre build `./.build/PrepareReactNativeconfig.app/Contents/MacOS/PrepareReactNativeconfig`

If you need to rebuild this file you can do so but first resolve the dependencies using [carthage](https://github.com/Carthage/Carthage)

``` bash
carthage update --no-build
```
Then add a scheme to the excoe project to build the target `PrepareReactNativeconfig`.
Adjust the code in the `main.swift`

## Troubleshooting

### Problems with Proguard

When Proguard is enabled (which it is by default for Android release builds), it can rename the `BuildConfig` Java class in the minification process and prevent React Native Config from referencing it. To avoid this, add an exception to `android/app/proguard-rules.pro`:

    -keep class com.mypackage.BuildConfig { *; }
    
`mypackage` should match the `package` value in your `app/src/main/AndroidManifest.xml` file.

## Testing

### Jest

For mocking the `Config.FOO_BAR` usage, create a mock at `__mocks__/react-native-config.js`:

```
// __mocks__/react-native-config.js
export default {
  FOO_BAR: 'baz',
};
```
