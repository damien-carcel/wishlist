module.exports = {
  collectCoverageFrom: ['assets/**/*.{ts,tsx}', '!assets/**/*.d.ts'],
  preset: 'ts-jest',
  roots: ['<rootDir>/assets'],
  setupFilesAfterEnv: ['<rootDir>/tests/front/setupTests.ts'],
  testEnvironment: 'jsdom',
  testMatch: ['<rootDir>/assets/**/*.test.{ts,tsx}'],
  transform: { '^.+\\.(ts|tsx)?$': 'ts-jest' },
  watchPlugins: ['jest-watch-typeahead/filename', 'jest-watch-typeahead/testname'],
  resetMocks: true,
};
