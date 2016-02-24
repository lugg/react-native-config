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


## Setup

Install the package:

```
$ npm install react-native-config --save
```

Then follow the platform-specific instructions below:


### iOS

Rnpm is not working with this at the moment (please let me know if you can help!).

In the meantime you'll need to add the `.xcodeproj` as an external library and flag the `.a` file manually under "Link Binary with Libraries". [Similar to this](https://github.com/marcshilling/react-native-image-picker#ios-1).


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
