'use strict';

// bridge to the buildConfigField vars set in build.gradle, and exported via ReactConfig
var React = require('react-native');
module.exports = React.NativeModules.ReactNativeConfig;
