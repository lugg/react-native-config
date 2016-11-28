# Config variables for React Native apps

Module to expose config variables to your javascript code in React Native, supporting both iOS and Android.

Bring some [12 factor](http://12factor.net/config) love to your mobile apps!


## Usage

Declare config variables in `.env`:

```
API_URL=https://myapi.com
GOOGLE_MAPS_API_KEY=abcdefgh
```

Then access from your app:

```js
import Config from 'react-native-config'

Config.API_URL  // 'https://myapi.com'
Config.GOOGLE_MAPS_API_KEY  // 'abcdefgh'
```

Keep in mind this module doesn't obfuscate or encrypt secrets for packaging, so do not store sensitive keys in `.env`. It's [basically impossible to prevent users from reverse engineering mobile app secrets](https://rammic.github.io/2015/07/28/hiding-secrets-in-android-apps/), so design your app (and APIs) with that in mind.


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
signingConfigs {
    release {
        storeFile file(project.env.get("RELEASE_STORE_FILE"))
        storePassword project.env.get("RELEASE_STORE_PASSWORD")
        keyAlias project.env.get("RELEASE_KEY_ALIAS")
        keyPassword project.env.get("RELEASE_KEY_PASSWORD")
    }
}
```

And use them to configure libraries in `AndroidManifest.xml` and others:

```xml
<meta-data
  android:name="com.google.android.geo.API_KEY"
  android:value="@string/GOOGLE_MAPS_API_KEY" />
```

### iOS

Read variables declared in `.env` from your Obj-C classes like:

```objective-c
// import header
#import "ReactNativeConfig.h"

// then read individual keys like:
NSString *apiUrl = [ReactNativeConfig envFor:@"API_URL"];

// or just fetch the whole config
NSDictionary *config = [ReactNativeConfig env];
```

Support for `plist` files is missing. We'd love to be able to refer to config from `.env` there, but haven't found a way to support this yet. Let us know if you have ideas!


### Different environments

Save config for different environments in different files: `.env.staging`, `.env.production`, etc.

By default react-native-config will read from `.env`, but you can change it when building or releasing your app.


#### Android

To pick which file to use in Android, set a variable in your `build.config` before the `apply from:`:

```
project.ext.envConfigFiles = [
    debug: ".env.development",
    release: ".env.production",
    anyCustomBuildTypeName: ".env",
]

apply from: project(':react-native-config').projectDir.getPath() + "/dotenv.gradle"
```

Alternatively, you can set `ENVFILE` before building/running your app. For instance:

```
$ ENVFILE=.env.staging react-native run-android
```

#### iOS

Support for Xcode is still a bit experimental – but at this moment the recommendation is to create a new scheme for your app, and configure it to use a different env file.

To create a new scheme, open your app in Xcode and then:

- Click the current app scheme (button with your app name next to the stop button)
- Click "Manage Schemes..."
- Select your current scheme (the one on top)
- Click the settings gear below the list and select "Duplicate"
- Give it a proper name on the top left. For instance: "Myapp (staging)"

To make a scheme use a different env file, on the manage scheme window:

- Expand the "Build" settings on left
- Click "Pre-actions", and under the plus sign select "New Run Script Action"
- Fill in with this script on the dark box, replacing `.env.staging` for the file you want:

```
echo ".env.staging" > /tmp/envfile
```

This is still experimental and obviously a bit dirty – let me know if you have better ideas on this front!


## Setup

Install the package:

```
$ npm install react-native-config --save
```

Link the library:

```
$ react-native link react-native-config
```

### Extra step for Android

Apply a plugin to your app build in `android/app/build.gradle`:

```
// 2nd line, add a new apply:
apply from: project(':react-native-config').projectDir.getPath() + "/dotenv.gradle"
```


#### Advanced Android Setup

In `android/app/build.gradle`, if you use `applicationIdSuffix` or `applicationId` that is different from the package name indicated in `AndroidManifest.xml` in `<manifest package="...">` tag, for example, to support different build variants:
Add this in `android/app/build.gradle`

```
defaultConfig {
    ...
    resValue "string", "build_config_package", "YOUR_PACKAGE_NAME_IN_ANDROIDMANIFEST.XML"
}
```

## Troubleshooting

### Problems with Proguard

When Proguard is enabled (which it is by default for Android release builds), it can rename the `BuildConfig` Java class in the minification process and prevent React Native Config from referencing it. To avoid this, add an exception to `android/app/proguard-rules.pro`:

    -keep class com.mypackage.BuildConfig { *; }
    
`mypackage` should match the `package` value in your `app/src/main/AndroidManifest.xml` file.
