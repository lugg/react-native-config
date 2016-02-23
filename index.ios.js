'use strict';

// bridge to the config vars set in xcconfig and exposed via ReactNativeConfig.m
var React = require('react-native');
module.exports = React.NativeModules.ReactNativeConfig;
