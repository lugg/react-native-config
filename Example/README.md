# Example app using react-native-config

Just a single app accessing config variables from `.env` and `.env.prod`.


## Running on Android

By default it will read variables from `.env`:

```bash
$ react-native run-android
```

To read from another file just specify it with `ENVFILE`, like:

```bash
$ ENVFILE=.env.prod react-native run-android
```
