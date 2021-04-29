# Example app using react-native-config

Just a simple app accessing config variables from `.env` and `.env.production`.


## Running

By default it will read variables from `.env`:

```bash
$ react-native run-android
```

To read from another file just specify it with `ENVFILE`, like:

```bash
$ ENVFILE=.env.prod react-native run-android
```

## Running on Windows

To use the default `.env` file:

```console
npx react-native run-windows
```

To read from another file:
```console
set ENVFILE=.env.production
npx react-native run-windows
```

## Running from Xcode

Open the Xcode project file in `Example/ios/Example.xcodeproj`.

Notice there are two schemes setup for the application: "Example" runs the default build, reading vars from `.env` – and "Example (production)" is configured to read from `.env.production`.
