# Instructions

- Following Playwright test failed.
- Explain why, be concise, respect Playwright best practices.
- Provide a snippet of code with the fix, if possible.

# Test info

- Name: projects/projectPanel.cancelDraftEscape.spec.js >> Escape annule un draft projet
- Location: e2e/projects/projectPanel.cancelDraftEscape.spec.js:3:1

# Error details

```
Error: expect(locator).toHaveCount(expected) failed

Locator:  locator('.project-item')
Expected: 2
Received: 3
Timeout:  5000ms

Call log:
  - Expect "toHaveCount" with timeout 5000ms
  - waiting for locator('.project-item')
    14 × locator resolved to 3 elements
       - unexpected value "3"

```

# Page snapshot

```yaml
- generic [ref=e1]:
  - main [ref=e2]:
    - generic [ref=e3]:
      - button "E2E" [ref=e4]:
        - generic [ref=e5]: E2E
      - button "E2E Second" [ref=e6]:
        - generic [ref=e7]: E2E Second
      - button "__draft__" [ref=e8]:
        - generic [active] [ref=e9]: __draft__
  - contentinfo "Raccourcis clavier" [ref=e10]:
    - generic [ref=e11]:
      - generic [ref=e12]: Tab
      - text: propriété suivante
    - generic [ref=e13]:
      - generic [ref=e14]: Entrée
      - text: confirmer
    - generic [ref=e15]:
      - generic [ref=e16]: Esc
      - text: annuler
```

# Test source

```ts
  1  | import { test, expect } from '@playwright/test'
  2  | 
  3  | test('Escape annule un draft projet', async ({ page }) => {
  4  |   await page.goto('/')
  5  | 
  6  |   const before = await page.locator('.project-item').count()
  7  | 
  8  |   await page.keyboard.press('n')
  9  |   await page.keyboard.press('Escape')
  10 | 
> 11 |   await expect(page.locator('.project-item')).toHaveCount(before)
     |                                               ^ Error: expect(locator).toHaveCount(expected) failed
  12 | })
  13 | 
```