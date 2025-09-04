'use strict';

// Bridge to:
// Android: buildConfigField vars set in build.gradle, and exported via ReactConfig
// iOS: config vars set in xcconfig and exposed via RNCConfig.m
import { NativeModules, TurboModuleRegistry, Platform } from 'react-native';

// New-arch TurboModule name should match native module name
const TM_NAME = 'RNCConfigModule';

function getTurboModule() {
	try {
		if (TurboModuleRegistry?.get) {
			return TurboModuleRegistry.get(TM_NAME);
		}
	} catch (_) {}
	return null;
}

const Turbo = getTurboModule();
const Paper = NativeModules?.RNCConfigModule;

let config = {};
if (Turbo) {
	// Prefer TM sync getAll when available to return a plain object
	if (typeof Turbo.getAll === 'function') {
		try { config = Turbo.getAll() || {}; } catch (_) { config = {}; }
	} else {
		config = Turbo;
	}
} else if (Paper) {
	config = Paper;
}

export const Config = config;
export default Config;