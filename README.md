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

Xcode support is missing; variables declared in `.env`. can be consumed from React Native apps in iOS via `Config`, but not from `plist` files.


### Different environments

Save config for different environments in different files: `.env.staging`, `.env.production`, etc.

By default react-native-config will read from `.env`, but you can change it when building or releasing your app.


#### Android

To pick which file to use in Android, just set `ENVFILE` before building/running your app. For instance:

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

**UPDATE**
It is also possible to add a `.xcconfig` extention to the env files, e.g. `.env.production.xcconfig`, then drag and drop them into your Xcode project.
- When the dialog pops up just chose to reference these files, don't copy them.
- Then select the project on the left (the root in project navigator)
- On the right side under Configuration select the `.env` file you want to use for each scheme. e.g. `Debug -> .env.debug` and `Release -> .env.production`
Since we added the `.xcconfig` Xcode can pick the `.env` file as its own configuration settings, and it uses the same format as we do.

Now you can use the env variables inside `Info.plist` just like
```xml
<key>CFBundleIdentifier</key>¬
<string>$(MY_BUNDLE_IDENTIFIER)</string>¬
<key>CFBundleInfoDictionaryVersion</key>¬
<string>6.0</string>¬
<key>CFBundleName</key>¬
<string>$(MY_PRODUCT_NAME)</string>
```
You can find a good tutorial and more information about Xcode Config files [here](http://www.jontolof.com/cocoa/using-xcconfig-files-for-you-xcode-project/)


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
    compile project(':react-native-config')
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

##### Advanced Setup

In `android/app/build.gradle`, if you use `applicationIdSuffix` or `applicationId` that is different from the package name indicated in `AndroidManifest.xml` in `<manifest package="...">` tag, for example, to support different build variants:
Add this in `android/app/build.gradle`

```
defaultConfig {
    ...
    resValue "string", "build_config_package", "YOUR_PACKAGE_NAME_IN_ANDROIDMANIFEST.XML"
}
```
