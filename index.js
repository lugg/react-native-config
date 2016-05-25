'use strict';

// Bridge to:
// Android: buildConfigField vars set in build.gradle, and exported via ReactConfig
// iOS: config vars set in xcconfig and exposed via ReactNativeConfig.m
var React = require('react-native');
module.exports = React.NativeModules.ReactNativeConfig;
