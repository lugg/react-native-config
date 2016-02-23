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

### Android

1. Include this module in `android/settings.gradle`:
  
  ```
  include ':react-native-android-config'
  include ':app'

  project(':react-native-android-config').projectDir = new File(rootProject.projectDir,
    '../node_modules/react-native-android-config/android')
  ```
2. Apply a plugin and add dependency to your app build, in `android/app/build.gradle`:
  
  ```
  // first line
  apply from: project(':react-native-config').projectDir.getPath() + "/dotenv.gradle"

  // down below
  dependencies {
      ...
      compile project(':react-native-android-config')
  }
  ```
3. Change your main activity to add a new package, in `android/app/src/main/.../MainActivity.java`:
  
  ```java
  import com.lugg.ReactConfig.ReactConfigPackage; // add import

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
