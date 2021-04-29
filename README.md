<h1 align="center">React Native Config</h1>

<p align="center">Module to expose config variables to your javascript code in React Native, supporting both iOS and Android.</p>
<p align="center">Bring some <a href="http://12factor.net/config">12 factor</a> love to your mobile apps!</p>
<p align="center">Forked from <a href="https://github.com/luggit/react-native-config">luggit's repo</a></p>

<p align="center">

<br>

# Setup (RN >= 0.60)

Install the package:

```sh
yarn add @bam.tech/react-native-config
```

Create a new file `.env` in the root of your React Native app:

```
API_URL=https://myapi.com
GOOGLE_MAPS_API_KEY=abcdefgh
```

Keep in mind this module doesn't obfuscate or encrypt secrets for packaging, so **do not store sensitive keys in `.env`**. It's [basically impossible to prevent users from reverse engineering mobile app secrets](https://rammic.github.io/2015/07/28/hiding-secrets-in-android-apps/), so design your app (and APIs) with that in mind.

## Setup Android

You'll also need to manually apply a plugin to your app, from `android/app/build.gradle`:

```
// 2nd line, add a new apply:
apply from: project(':@bam.tech_react-native-config').projectDir.getPath() + "/dotenv.gradle"
```

### Required if dynamic app id

In `android/app/build.gradle`, if you use `applicationIdSuffix` or `applicationId` that is different from the package name indicated in `AndroidManifest.xml` in `<manifest package="...">` tag, for example, to support different build variants:
Add this in `android/app/build.gradle`

```
defaultConfig {
    ...
    resValue "string", "build_config_package", "YOUR_PACKAGE_NAME_IN_ANDROIDMANIFEST.XML"
}
```

### Optional : Proguard

When Proguard is enabled (which it is by default for Android release builds), it can rename the `BuildConfig` Java class in the minification process and prevent React Native Config from referencing it. To avoid this, add an exception to `android/app/proguard-rules.pro`:

    -keep class com.mypackage.BuildConfig { *; }

`mypackage` should match the `package` value in your `app/src/main/AndroidManifest.xml` file.

### Optional : Multi-environment support

The same environment variable can be used to assemble releases with a different config:

Define a map in `build.gradle` associating builds with env files. Do it before the `apply from` call, and use build cases in lowercase, like:

(Note: For React Native 0.60 or greater, [autolinking](https://reactnative.dev/blog/2019/07/03/version-60#native-modules-are-now-autolinked) is available)

(Note: For Windows, this module supports autolinking when used with `react-native-windows@0.63`
or later. For earlier versions you need to manually link the module.)

```
project.ext.envConfigFiles = [
    debug: ".env.development",
    release: ".env.production",
    anothercustombuild: ".env",
]
apply from: project(':@bam.tech_react-native-config').projectDir.getPath() + "/dotenv.gradle"
```

Also note that besides requiring lowercase, the matching is done with `buildFlavor.startsWith`, so a build named `debugProd` could match the `debug` case, above.

## Setup iOS

```
cd ios
pod install
```

- Right click on your project folder, create a "New file..."
- Select the "Configuration Settings File" file type
- Name it "react-native-config.xcconfig"
- Remove this file from git (as it will be generated each build):

  ```diff
  # .gitignore

  # react-native-config codegen
  ios/react-native-config.xcconfig
  ios/envfile
  ```

- In the Xcode menu, go to Product > Scheme > Edit Scheme
- Expand the "Build" settings on left
- Click "Pre-actions", and under the plus sign select "New Run Script Action"
- Where it says "Type a script or drag a script file", type:

  ```
  echo ".env.development" > "${SRCROOT}/envfile"
  ENVFILE=.env.development ${SRCROOT}/../node_modules/@bam.tech/react-native-config/ios/ReactNativeConfig/BuildXCConfig.rb ${SRCROOT}/.. ${SRCROOT}/react-native-config.xcconfig
  ```

- In your xcode project, in the Info tab ...
- ... expand the Configurations section
- For Debug and Release, on your project name row, select the `react-native-config` configuration option.

### Optional : Multi-environment support

The basic idea in iOS is to have one scheme per environment file, so you can easily alternate between them.
For each environment, use the following step (and change `development` by your env name - staging, test, production) :

- In the Xcode menu, go to Product > Scheme > Edit Scheme
- Duplicate Scheme
- Expand the "Build" settings on left
- Click "Pre-actions", and under the plus sign select "New Run Script Action"
- Where it says "Type a script or drag a script file", type:
  ```
  echo ".env.development" > "${SRCROOT}/envfile"
  ENVFILE=.env.development ${SRCROOT}/../node_modules/@bam.tech/react-native-config/ios/ReactNativeConfig/BuildXCConfig.rb ${SRCROOT}/.. ${SRCROOT}/react-native-config.xcconfig
  ```

# Usage

## Javascript

```js
import Config from "@bam.tech/react-native-config";

Config.API_URL; // 'https://myapi.com'
Config.GOOGLE_MAPS_API_KEY; // 'abcdefgh'
```

## Android

Config variables set in `.env` are available to your Java classes via `BuildConfig`:

```java
public HttpURLConnection getApiClient() {
    URL url = new URL(BuildConfig.API_URL);
    // ...
}
```

You can also read them from your Gradle configuration.
All variables are strings, so you may need to cast them. For instance, in Gradle:

```groovy
defaultConfig {
    applicationId project.env.get("APP_ID")
    versionCode project.env.get("VERSION_CODE").toInteger()
}
```

And use them to configure libraries in `AndroidManifest.xml` and others:

```xml
<meta-data
  android:name="com.google.android.geo.API_KEY"
  android:value="@string/GOOGLE_MAPS_API_KEY" />
```

## iOS

Read variables declared in `.env` from your Obj-C classes like:

```objective-c
// import header
#import "ReactNativeConfig.h"

// then read individual keys like:
NSString *apiUrl = [ReactNativeConfig envFor:@"API_URL"];

// or just fetch the whole config
NSDictionary *config = [ReactNativeConfig env];
```

In `Info.plist` or `project.pbxproj`, read variables like so :

```xml
	<key>CFBundleDisplayName</key>
	<string>$(DISPLAY_NAME)</string>
```

```pbxproj
  PROVISIONING_PROFILE_SPECIFIER = "$(PROVISIONING_PROFILE_SPECIFIER)";
```

# Testing

## Jest

For mocking the `Config.FOO_BAR` usage, create a mock at `__mocks__/@bam.tech/react-native-config.js`.

```
// __mocks__/react-native-config.js
export default {
  FOO_BAR: 'baz',
};
```

### Example with exact values from `.env`

`yarn add -D dotenv`

```js
// __mocks__/@bam.tech/react-native-config.js

import fs from "fs";
import path from "path";

import dotenv from "dotenv";

const buf = fs.readFileSync(path.resolve(__dirname, "..", "..", ".env"));
const config = dotenv.parse(buf);

export default config;
```

# Credits

Forked from original repo created by Pedro Belo at [Lugg](https://lugg.com/).
