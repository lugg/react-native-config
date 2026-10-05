# Configuration reader tests

The Apple and Windows generator tests require Ruby with Minitest and Node.js 18+:

```sh
npm test
```

The Apple suite also compiles its Foundation diagnostic harness on macOS. That
harness is skipped on other platforms. Tests use temporary files with dummy
values. The Windows generator tests compile and execute both generated C++
constant forms when `clang++` is available, and are skipped otherwise. They
compare runtime values, independently of the C++ literal syntax, without building
the Windows native bridge. Run in an isolated environment: the Ruby runner refuses to run if the
legacy machine-global `/tmp/envfile` selector exists.

The Android parser fixtures require Java 17+ and the checked-in Gradle wrapper:

```sh
npm run test:android
```

The standalone Gradle project applies the production `android/dotenv.gradle`
reader and records its `buildConfigField` and `resValue` calls. It needs no
Android SDK or Android Gradle plugin. On Windows, use this from the repository root:

```bat
Example\android\gradlew.bat -p test/gradle testInlineComments --no-daemon
```

All three readers use `fixtures/inline_comments.json` for comment, quoting,
empty-value, Unicode and URL-fragment cases. These tests exercise configuration
reading and generation; they do not build a React Native app.
