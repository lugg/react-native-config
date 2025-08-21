/**
 * @format
 */

import 'react-native';
import React from 'react';
import App from '../App';

// Note: test renderer must be required after react-native.

it('renders without crashing', () => {
  expect(() => <App />).not.toThrow();
});
