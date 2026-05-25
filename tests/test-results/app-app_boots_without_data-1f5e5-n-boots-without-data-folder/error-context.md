# Instructions

- Following Playwright test failed.
- Explain why, be concise, respect Playwright best practices.
- Provide a snippet of code with the fix, if possible.

# Test info

- Name: app/app_boots_without_data_folder.spec.js >> application boots without data folder
- Location: e2e/app/app_boots_without_data_folder.spec.js:5:1

# Error details

```
Error: expect(received).toBe(expected) // Object.is equality

Expected: true
Received: false
```

# Page snapshot

```yaml
- generic [active] [ref=e1]:
  - main [ref=e2]:
    - generic [ref=e3]: __e2e__
  - contentinfo "Raccourcis clavier" [ref=e4]
```

# Test source

```ts
  1  | import { test, expect } from '@playwright/test'
  2  | import fs from 'fs'
  3  | import path from 'path'
  4  | 
  5  | test('application boots without data folder', async ({ page }) => {
  6  | 
  7  |   const dataFolder = path.join(process.cwd(), 'data')
  8  | 
  9  |   if (fs.existsSync(dataFolder)) {
  10 |     fs.rmSync(dataFolder, { recursive: true, force: true })
  11 |   }
  12 | 
  13 |   await page.goto('http://localhost:4567')
  14 | 
> 15 |   expect(fs.existsSync(dataFolder)).toBe(true)
     |                                     ^ Error: expect(received).toBe(expected) // Object.is equality
  16 | 
  17 |   const projectsFolder = path.join(dataFolder, '__projects__')
  18 |   const demoFolder     = path.join(projectsFolder, 'demo')
  19 | 
  20 |   expect(fs.existsSync(projectsFolder)).toBe(true)
  21 |   expect(fs.existsSync(demoFolder)).toBe(true)
  22 | 
  23 |   expect(
  24 |     fs.existsSync(
  25 |       path.join(dataFolder, '__projects__.json')
  26 |     )
  27 |   ).toBe(true)
  28 | 
  29 |   expect(
  30 |     fs.existsSync(
  31 |       path.join(demoFolder, '__events__.json')
  32 |     )
  33 |   ).toBe(true)
  34 | 
  35 |   expect(
  36 |     fs.existsSync(
  37 |       path.join(demoFolder, '__brins__.json')
  38 |     )
  39 |   ).toBe(true)
  40 | 
  41 |   expect(
  42 |     fs.existsSync(
  43 |       path.join(demoFolder, '__persos__.json')
  44 |     )
  45 |   ).toBe(true)
  46 | 
  47 |   await expect(page.locator('body')).toContainText(
  48 |     'Projet de démonstration'
  49 |   )
  50 | 
  51 | })
  52 | 
```