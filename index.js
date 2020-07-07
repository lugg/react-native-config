'use strict';

// Bridge to:
// Android: buildConfigField vars set in build.gradle, and exported via ReactConfig
// iOS: config vars set in xcconfig and exposed via ReactNativeConfig.m
import { NativeModules } from 'react-native';

export const Config = NativeModules.ReactNativeConfigModule || {}
export default Config;
