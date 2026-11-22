import { expect, test } from '@playwright/test';

test.describe('Home Page', () => {
  test('it says hello', async ({ page }) => {
    await page.goto('http://localhost:3000/');

    const content = page.getByTestId('hello');

    await expect(content).toContainText('Hello Hono!');
  });
});
