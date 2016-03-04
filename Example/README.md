# Example app using react-native-config

Just a single app accessing config variables from `.env` and `.env.prod`.


## Running in Android

By default it will read variables from `.env`:

```bash
$ react-native run-android
```

To read from another file just specify it with `ENVFILE`, like:

```bash
$ ENVFILE=.env.prod react-native run-android
```

## Running in iOS

Open the Xcode project file in `Example/ios/Example.xcodeproj`.

Notice there are two schemes setup for the application: "Example" runs the default build, reading vars from `.env` – and "Example (prod)" is configured to read from `.env.prod`.
