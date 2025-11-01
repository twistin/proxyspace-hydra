module.exports = {
  testEnvironment: 'node',
  coverageDirectory: 'coverage',
  collectCoverageFrom: [
    '*.js',
    '!osc_ws_proxy*.js',
    '!jest.config.js'
  ],
  testMatch: [
    '**/test/**/*.test.js'
  ],
  verbose: true
};
