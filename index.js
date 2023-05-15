'use strict';

import { NativeModules, Platform } from 'react-native';

// new arch is not supported on Windows yet
export const Config = Platform.OS === 'windows'
    ? NativeModules.RNCConfigModule
    : require('./codegen/NativeConfigModule').default.getConstants().constants;

export default Config;
