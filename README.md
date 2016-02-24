# Config variables for React Native apps

Module to expose config variables to your javascript code in React Native, supporting both iOS and Android.

Bring some [12 factor](http://12factor.net/config) love to your mobile apps!


## Usage

Declare config variables in `.env`:

```
API_URL=https://myapi.com
LOG_ERRORS=true
```

Then access from your app:

```js
import Config from 'react-native-config'

Config.API_URL     // 'https://myapi.com'
Config.SHOW_ERRORS // 'true'
```

### Android

These variables are also available for use in your Gradle configuration, via `project.env`:

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

And automatically made available in `AndroidManifest.xml` and others:

```xml
<meta-data
  android:name="com.google.android.geo.API_KEY"
  android:value="@string/GOOGLE_MAPS_API_KEY" />
```

### iOS

Xcode support is missing; variables declared in `.env`. can be consumed from React Native apps in iOS via `Config`, but not from `plist` files.


### Different environments

Save config for different environments in different files: `.env.staging`, `.env.production`, etc.

By default react-native-config will read from `.env`, but you can change it setting  `ENVFILE` before running it, like:

```
$ ENVFILE=.env.staging react-native run-android
```

This is only support in Android at the moment – The iOS equivalent should be coming soon.


## Setup

Install the package:

```
$ npm install react-native-config --save
```

Then follow the platform-specific instructions below:


### iOS

Link the library with [rnpm](https://github.com/rnpm/rnpm):

```
$ rnpm link react-native-config
```


### Android

Include this module in `android/settings.gradle`:
  
```
include ':react-native-config'
include ':app'

project(':react-native-config').projectDir = new File(rootProject.projectDir,
  '../node_modules/react-native-config/android')
```

Apply a plugin and add dependency to your app build, in `android/app/build.gradle`:

```
// 2nd line, add a new apply:
apply from: project(':react-native-config').projectDir.getPath() + "/dotenv.gradle"

// down below, add new compile:
dependencies {
    ...
    compile project(':react-native-android-config')
}
```

Change your main activity to add a new package, in `android/app/src/main/.../MainActivity.java`:

```java
import com.lugg.ReactNativeConfig.ReactNativeConfigPackage; // add import

public class MainActivity extends ReactActivity {
    // ...

    @Override
    protected List<ReactPackage> getPackages() {
        return Arrays.<ReactPackage>asList(
            new MainReactPackage(),
            new ReactNativeConfigPackage() // add package
        );
    }
```
