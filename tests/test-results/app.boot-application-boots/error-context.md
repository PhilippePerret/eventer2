# Instructions

- Following Playwright test failed.
- Explain why, be concise, respect Playwright best practices.
- Provide a snippet of code with the fix, if possible.

# Test info

- Name: app.boot.test.js >> application boots
- Location: e2e/app.boot.test.js:3:1

# Error details

```
Error: expect(locator).toBeVisible() failed

Locator:  locator('body')
Expected: visible
Received: hidden
Timeout:  5000ms

Call log:
  - Expect "toBeVisible" with timeout 5000ms
  - waiting for locator('body')
    14 × locator resolved to <body>…</body>
       - unexpected value "hidden"

```

```yaml
- main
- contentinfo "Raccourcis clavier"
```

# Test source

```ts
  1  | import { test, expect } from '@playwright/test'
  2  | 
  3  | test('application boots', async ({ page }) => {
  4  | 
  5  |   await page.goto('http://127.0.0.1:4567')
  6  | 
> 7  |   await expect(page.locator('body')).toBeVisible()
     |                                      ^ Error: expect(locator).toBeVisible() failed
  8  | 
  9  | })
  10 | 
```