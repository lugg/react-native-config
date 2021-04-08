import { driver, By2 } from 'selenium-appium'
import { until } from 'selenium-webdriver';

const setup = require('../jest-setups/jest.setup');
jest.setTimeout(60000);

beforeAll(() => {
  return driver.startWithCapabilities(setup.capabilites);
});

afterAll(() => {
  return driver.quit();
});

describe('Test App', () => {

  test('API_URL present', async () => {
    // Get the element by label, will fail if the element is not present
    // we use the API_URL from the .env file
    await driver.wait(until.elementLocated(By2.nativeName('API_URL=http://localhost')));
  });

})
