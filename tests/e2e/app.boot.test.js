import { test, expect } from '@playwright/test'

test('application boots', async ({ page }) => {

  await page.goto('http://127.0.0.1:4567')

  await expect(page.locator('body')).toBeVisible()

})
