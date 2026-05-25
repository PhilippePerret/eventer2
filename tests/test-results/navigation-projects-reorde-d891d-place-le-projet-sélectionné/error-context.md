# Instructions

- Following Playwright test failed.
- Explain why, be concise, respect Playwright best practices.
- Provide a snippet of code with the fix, if possible.

# Test info

- Name: navigation/projects-reordering.spec.js >> Réorganisation des projets >> Cmd + flèche haut/bas déplace le projet sélectionné
- Location: e2e/navigation/projects-reordering.spec.js:77:3

# Error details

```
Error: expect(received).toBe(expected) // Object.is equality

- Expected  - 2
+ Received  + 2

- Projet Beta
- beta
+ Projet Alpha
+ alpha
```

# Page snapshot

```yaml
- generic [active] [ref=e1]:
  - main [ref=e2]:
    - generic [ref=e3]:
      - generic [ref=e4]:
        - generic [ref=e5]: Projet Alpha
        - generic [ref=e6]: alpha
      - generic [ref=e7]:
        - generic [ref=e8]: Projet Beta
        - generic [ref=e9]: beta
      - generic [ref=e10]:
        - generic [ref=e11]: Projet Gamma
        - generic [ref=e12]: gamma
  - contentinfo "Raccourcis clavier" [ref=e13]
```

# Test source

```ts
  3   | import path from 'path'
  4   | 
  5   | const PROJECT_ROOT = path.resolve(process.cwd(), '..')
  6   | const DATA_FOLDER  = path.join(PROJECT_ROOT, 'data')
  7   | 
  8   | function log(step) {
  9   |   console.log(`[TEST] ${step}`)
  10  | }
  11  | 
  12  | function writeJson(pathname, data) {
  13  |   fs.mkdirSync(path.dirname(pathname), { recursive: true })
  14  |   fs.writeFileSync(pathname, JSON.stringify(data, null, 2))
  15  | }
  16  | 
  17  | function prepareData() {
  18  | 
  19  |   log('préparation de 3 projets')
  20  | 
  21  |   if (fs.existsSync(DATA_FOLDER)) {
  22  |     fs.rmSync(DATA_FOLDER, { recursive: true, force: true })
  23  |   }
  24  | 
  25  |   const projectsFolder = path.join(DATA_FOLDER, '__projects__')
  26  | 
  27  |   writeJson(
  28  |     path.join(DATA_FOLDER, '__projects__.json'),
  29  |     {
  30  |       id: '__projects__',
  31  |       scale: 'eventer',
  32  |       events: ['alpha', 'beta', 'gamma'],
  33  |       brins: [],
  34  |       persos: [],
  35  |       active: true
  36  |     }
  37  |   )
  38  | 
  39  |   ;[
  40  |     ['alpha', 'Projet Alpha'],
  41  |     ['beta',  'Projet Beta'],
  42  |     ['gamma', 'Projet Gamma']
  43  |   ].forEach(([id, title]) => {
  44  | 
  45  |     writeJson(
  46  |       path.join(projectsFolder, `${id}.json`),
  47  |       {
  48  |         id,
  49  |         scale: 'project',
  50  |         title,
  51  |         events: [],
  52  |         brins: [],
  53  |         persos: [],
  54  |         active: true
  55  |       }
  56  |     )
  57  | 
  58  |     writeJson(
  59  |       path.join(projectsFolder, id, '__events__.json'),
  60  |       []
  61  |     )
  62  | 
  63  |     writeJson(
  64  |       path.join(projectsFolder, id, '__brins__.json'),
  65  |       []
  66  |     )
  67  | 
  68  |     writeJson(
  69  |       path.join(projectsFolder, id, '__persos__.json'),
  70  |       []
  71  |     )
  72  |   })
  73  | }
  74  | 
  75  | test.describe('Réorganisation des projets', () => {
  76  | 
  77  |   test('Cmd + flèche haut/bas déplace le projet sélectionné', async ({ page }) => {
  78  | 
  79  |     prepareData()
  80  | 
  81  |     await page.goto('http://127.0.0.1:4567')
  82  | 
  83  |     const projects = page.locator('.event')
  84  | 
  85  |     await expect(projects).toHaveCount(3)
  86  | 
  87  |     const initialOrder = await projects.evaluateAll(nodes =>
  88  |       nodes.map(node => node.innerText.trim())
  89  |     )
  90  | 
  91  |     await page.keyboard.press('ArrowDown')
  92  | 
  93  |     await expect(projects.nth(1)).toHaveClass(/selected/)
  94  | 
  95  |     await page.keyboard.press('Meta+ArrowUp')
  96  | 
  97  |     await expect(projects.nth(0)).toHaveClass(/selected/)
  98  | 
  99  |     const orderAfterMoveUp = await projects.evaluateAll(nodes =>
  100 |       nodes.map(node => node.innerText.trim())
  101 |     )
  102 | 
> 103 |     expect(orderAfterMoveUp[0]).toBe(initialOrder[1])
      |                                 ^ Error: expect(received).toBe(expected) // Object.is equality
  104 |     expect(orderAfterMoveUp[1]).toBe(initialOrder[0])
  105 |     expect(orderAfterMoveUp[2]).toBe(initialOrder[2])
  106 | 
  107 |     await page.keyboard.press('Meta+ArrowDown')
  108 | 
  109 |     await expect(projects.nth(1)).toHaveClass(/selected/)
  110 | 
  111 |     const finalOrder = await projects.evaluateAll(nodes =>
  112 |       nodes.map(node => node.innerText.trim())
  113 |     )
  114 | 
  115 |     expect(finalOrder).toEqual(initialOrder)
  116 | 
  117 |   })
  118 | 
  119 | })
```