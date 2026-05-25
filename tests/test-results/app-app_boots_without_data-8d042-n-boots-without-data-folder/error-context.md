# Instructions

- Following Playwright test failed.
- Explain why, be concise, respect Playwright best practices.
- Provide a snippet of code with the fix, if possible.

# Test info

- Name: app/app_boots_without_data_folder.spec.js >> app / bootstrap >> application boots without data folder
- Location: e2e/app/app_boots_without_data_folder.spec.js:44:3

# Error details

```
Error: Le projet demo doit être visible dans l’interface. Logs page : [log] -> app.js
[log] Je vais afficher les projets :  [Object]

expect(locator).toContainText(expected) failed

Locator: locator('body')
Timeout: 5000ms
- Expected substring  -  1
+ Received string     + 15

- Projet de démonstration
+
+
+   __e2e__
+
+   
+
+
+   
+     
+   
+
+   
+   
+
+

Call log:
  - Le projet demo doit être visible dans l’interface. Logs page : [log] -> app.js
[log] Je vais afficher les projets :  [Object] with timeout 5000ms
  - waiting for locator('body')
    14 × locator resolved to <body>…</body>
       - unexpected value "

  __e2e__

  


  
    
  

  
  

"

```

```yaml
- main: __e2e__
- contentinfo "Raccourcis clavier"
```

# Test source

```ts
  47  | 
  48  |     page.on('console', message => {
  49  |       pageLogs.push(`[${message.type()}] ${message.text()}`)
  50  |     })
  51  | 
  52  |     page.on('pageerror', error => {
  53  |       pageErrors.push(error.message)
  54  |     })
  55  | 
  56  |     if (exists(DATA_FOLDER)) {
  57  |       fs.rmSync(DATA_FOLDER, { recursive: true, force: true })
  58  |     }
  59  | 
  60  |     const response = await page.goto('http://localhost:4567')
  61  | 
  62  |     expect(response, 'GET / ne retourne aucune réponse HTTP').not.toBeNull()
  63  | 
  64  |     expect(
  65  |       response.status(),
  66  |       `GET / retourne HTTP ${response.status()} au lieu de 200`
  67  |     ).toBe(200)
  68  | 
  69  |     expect(
  70  |       pageErrors,
  71  |       `Erreurs JavaScript navigateur : ${pageErrors.join('\n')}`
  72  |     ).toEqual([])
  73  | 
  74  |     const projectsFile = path.join(DATA_FOLDER, '__projects__.json')
  75  |     const projectsFolder = path.join(DATA_FOLDER, '__projects__')
  76  |     const demoEventerFile = path.join(projectsFolder, 'demo.json')
  77  |     const wrongDemoEventerFile = path.join(projectsFolder, 'demo', '__projects__.json')
  78  |     const demoFolder = path.join(projectsFolder, 'demo')
  79  |     const eventsFile = path.join(demoFolder, '__events__.json')
  80  |     const brinsFile = path.join(demoFolder, '__brins__.json')
  81  |     const persosFile = path.join(demoFolder, '__persos__.json')
  82  | 
  83  |     expectPathExists(DATA_FOLDER, 'Dossier data')
  84  |     expectPathExists(projectsFile, 'Eventer racine des projets')
  85  |     expectPathExists(projectsFolder, 'Dossier de l’eventer racine __projects__')
  86  |     expectPathExists(demoEventerFile, 'Fichier eventer du projet demo')
  87  |     expectPathExists(demoFolder, 'Dossier du projet demo')
  88  |     expectPathExists(eventsFile, 'Liste des events du projet demo')
  89  |     expectPathExists(brinsFile, 'Liste des brins du projet demo')
  90  |     expectPathExists(persosFile, 'Liste des personnages du projet demo')
  91  |     expectPathMissing(wrongDemoEventerFile, 'Ancien mauvais fichier eventer demo')
  92  | 
  93  |     const rootEventer = readJson(projectsFile)
  94  |     const demoEventer = readJson(demoEventerFile)
  95  |     const events = expectJsonArray(eventsFile, 'Liste des events du projet demo')
  96  |     const brins = expectJsonArray(brinsFile, 'Liste des brins du projet demo')
  97  |     const persos = expectJsonArray(persosFile, 'Liste des personnages du projet demo')
  98  | 
  99  |     expect(
  100 |       rootEventer.events,
  101 |       `L’eventer racine doit lister le projet demo dans events. Reçu : ${JSON.stringify(rootEventer)}`
  102 |     ).toEqual(['demo'])
  103 | 
  104 |     expect(
  105 |       rootEventer,
  106 |       `Propriété interdite "evenements" trouvée dans l’eventer racine : ${JSON.stringify(rootEventer)}`
  107 |     ).not.toHaveProperty('evenements')
  108 | 
  109 |     expect(
  110 |       demoEventer.scale,
  111 |       `Le projet demo doit être un Eventer de scale "project". Reçu : ${JSON.stringify(demoEventer)}`
  112 |     ).toBe('project')
  113 | 
  114 |     expect(
  115 |       demoEventer.title,
  116 |       `Le projet demo doit avoir un titre explicite. Reçu : ${JSON.stringify(demoEventer)}`
  117 |     ).toBe('Projet de démonstration')
  118 | 
  119 |     expect(
  120 |       demoEventer,
  121 |       `Propriété interdite "evenements" trouvée dans l'Eventer projet : ${JSON.stringify(demoEventer)}`
  122 |     ).not.toHaveProperty('evenements')
  123 | 
  124 |     expect(
  125 |       demoEventer,
  126 |       `Propriété obligatoire "events" absente de l'Eventer projet : ${JSON.stringify(demoEventer)}`
  127 |     ).toHaveProperty('events')
  128 | 
  129 |     expect(
  130 |       events.length,
  131 |       `${eventsFile} doit contenir au moins un event explicatif`
  132 |     ).toBeGreaterThan(0)
  133 | 
  134 |     expect(
  135 |       brins.length,
  136 |       `${brinsFile} doit contenir au moins un brin explicatif`
  137 |     ).toBeGreaterThan(0)
  138 | 
  139 |     expect(
  140 |       persos.length,
  141 |       `${persosFile} doit contenir au moins un personnage explicatif`
  142 |     ).toBeGreaterThan(0)
  143 | 
  144 |     await expect(
  145 |       page.locator('body'),
  146 |       `Le projet demo doit être visible dans l’interface. Logs page : ${pageLogs.join('\n')}`
> 147 |     ).toContainText('Projet de démonstration')
      |       ^ Error: Le projet demo doit être visible dans l’interface. Logs page : [log] -> app.js
  148 |   })
  149 | })
  150 | 
```