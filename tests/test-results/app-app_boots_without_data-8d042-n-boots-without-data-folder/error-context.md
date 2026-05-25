# Instructions

- Following Playwright test failed.
- Explain why, be concise, respect Playwright best practices.
- Provide a snippet of code with the fix, if possible.

# Test info

- Name: app/app_boots_without_data_folder.spec.js >> app / bootstrap >> application boots without data folder
- Location: e2e/app/app_boots_without_data_folder.spec.js:36:3

# Error details

```
Error: Dossier data introuvable : /Users/philippeperret/Programmes/Eventer2/tests/data

expect(received).toBe(expected) // Object.is equality

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
  1   | import { test, expect } from '@playwright/test'
  2   | import fs from 'fs'
  3   | import path from 'path'
  4   | 
  5   | const DATA_FOLDER = path.join(process.cwd(), 'data')
  6   | 
  7   | function exists(pathname) {
  8   |   return fs.existsSync(pathname)
  9   | }
  10  | 
  11  | function readJson(pathname) {
  12  |   return JSON.parse(fs.readFileSync(pathname, 'utf8'))
  13  | }
  14  | 
  15  | function expectPathExists(pathname, label) {
  16  |   expect(
  17  |     exists(pathname),
  18  |     `${label} introuvable : ${pathname}`
> 19  |   ).toBe(true)
      |     ^ Error: Dossier data introuvable : /Users/philippeperret/Programmes/Eventer2/tests/data
  20  | }
  21  | 
  22  | function expectJsonArray(pathname, label) {
  23  |   expectPathExists(pathname, label)
  24  | 
  25  |   const data = readJson(pathname)
  26  | 
  27  |   expect(
  28  |     Array.isArray(data),
  29  |     `${label} doit contenir un tableau JSON. Contenu reçu : ${JSON.stringify(data)}`
  30  |   ).toBe(true)
  31  | 
  32  |   return data
  33  | }
  34  | 
  35  | test.describe('app / bootstrap', () => {
  36  |   test('application boots without data folder', async ({ page }) => {
  37  |     const pageLogs = []
  38  |     const pageErrors = []
  39  | 
  40  |     page.on('console', message => {
  41  |       pageLogs.push(`[${message.type()}] ${message.text()}`)
  42  |     })
  43  | 
  44  |     page.on('pageerror', error => {
  45  |       pageErrors.push(error.message)
  46  |     })
  47  | 
  48  |     if (exists(DATA_FOLDER)) {
  49  |       fs.rmSync(DATA_FOLDER, { recursive: true, force: true })
  50  |     }
  51  | 
  52  |     const response = await page.goto('http://localhost:4567')
  53  | 
  54  |     expect(response, 'GET / ne retourne aucune réponse HTTP').not.toBeNull()
  55  | 
  56  |     expect(
  57  |       response.status(),
  58  |       `GET / retourne HTTP ${response.status()} au lieu de 200`
  59  |     ).toBe(200)
  60  | 
  61  |     expect(
  62  |       pageErrors,
  63  |       `Erreurs JavaScript navigateur : ${pageErrors.join('\n')}`
  64  |     ).toEqual([])
  65  | 
  66  |     const projectsFile = path.join(DATA_FOLDER, '__projects__.json')
  67  |     const projectsFolder = path.join(DATA_FOLDER, '__projects__')
  68  |     const demoFolder = path.join(projectsFolder, 'demo')
  69  |     const demoEventerFile = path.join(demoFolder, '__projects__.json')
  70  |     const eventsFile = path.join(demoFolder, '__events__.json')
  71  |     const brinsFile = path.join(demoFolder, '__brins__.json')
  72  |     const persosFile = path.join(demoFolder, '__persos__.json')
  73  | 
  74  |     expectPathExists(DATA_FOLDER, 'Dossier data')
  75  |     expectPathExists(projectsFile, 'Index racine des projets')
  76  |     expectPathExists(projectsFolder, 'Dossier racine __projects__')
  77  |     expectPathExists(demoFolder, 'Dossier du projet demo')
  78  |     expectPathExists(demoEventerFile, 'Eventer projet demo')
  79  |     expectPathExists(eventsFile, 'Liste des events du projet demo')
  80  |     expectPathExists(brinsFile, 'Liste des brins du projet demo')
  81  |     expectPathExists(persosFile, 'Liste des personnages du projet demo')
  82  | 
  83  |     const projectIds = expectJsonArray(projectsFile, 'Index racine des projets')
  84  |     const demoEventer = readJson(demoEventerFile)
  85  |     const events = expectJsonArray(eventsFile, 'Liste des events du projet demo')
  86  |     const brins = expectJsonArray(brinsFile, 'Liste des brins du projet demo')
  87  |     const persos = expectJsonArray(persosFile, 'Liste des personnages du projet demo')
  88  | 
  89  |     expect(
  90  |       projectIds,
  91  |       `__projects__.json doit contenir uniquement ["demo"]. Reçu : ${JSON.stringify(projectIds)}`
  92  |     ).toEqual(['demo'])
  93  | 
  94  |     expect(
  95  |       demoEventer.scale,
  96  |       `Le projet demo doit être un Eventer de scale "project". Reçu : ${JSON.stringify(demoEventer)}`
  97  |     ).toBe('project')
  98  | 
  99  |     expect(
  100 |       demoEventer.title,
  101 |       `Le projet demo doit avoir un titre explicite. Reçu : ${JSON.stringify(demoEventer)}`
  102 |     ).toBe('Projet de démonstration')
  103 | 
  104 |     expect(
  105 |       demoEventer,
  106 |       `Propriété interdite "evenements" trouvée dans l'Eventer projet : ${JSON.stringify(demoEventer)}`
  107 |     ).not.toHaveProperty('evenements')
  108 | 
  109 |     expect(
  110 |       demoEventer,
  111 |       `Propriété obligatoire "events" absente de l'Eventer projet : ${JSON.stringify(demoEventer)}`
  112 |     ).toHaveProperty('events')
  113 | 
  114 |     expect(
  115 |       events.length,
  116 |       `${eventsFile} doit contenir au moins un event explicatif`
  117 |     ).toBeGreaterThan(0)
  118 | 
  119 |     expect(
```