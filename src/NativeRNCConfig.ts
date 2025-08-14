import type { TurboModule } from 'react-native';
import { TurboModuleRegistry } from 'react-native';

export interface Spec extends TurboModule {
  // Synchronous getters (supported on Windows TurboModules)
  getAll(): { [key: string]: string };
  get(key: string): string;
  // Optional Composition info hook
  compositionInfo?(): string;
}

export default TurboModuleRegistry.getEnforcing<Spec>('RNCConfigModule');
