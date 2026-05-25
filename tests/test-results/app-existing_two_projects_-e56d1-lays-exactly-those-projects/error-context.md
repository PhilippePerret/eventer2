# Instructions

- Following Playwright test failed.
- Explain why, be concise, respect Playwright best practices.
- Provide a snippet of code with the fix, if possible.

# Test info

- Name: app/existing_two_projects_display.spec.js >> app / projects listing >> existing data with two projects displays exactly those projects
- Location: e2e/app/existing_two_projects_display.spec.js:112:3

# Error details

```
Error: /projects doit retourner uniquement les propriétés publiques attendues : id, scale, title, active. Reçu : [{"id":"alpha","file":"alpha.json","title":"Projet Alpha","active":true},{"id":"beta","file":"beta.json","title":"Projet Beta","active":true}]

expect(received).toEqual(expected) // deep equality

- Expected  - 2
+ Received  + 2

  Array [
    Object {
      "active": true,
+     "file": "alpha.json",
      "id": "alpha",
-     "scale": "project",
      "title": "Projet Alpha",
    },
    Object {
      "active": true,
+     "file": "beta.json",
      "id": "beta",
-     "scale": "project",
      "title": "Projet Beta",
    },
  ]
```

# Page snapshot

```yaml
- generic [active] [ref=e1]:
  - main [ref=e2]:
    - generic [ref=e3]: Projet Alpha
    - generic [ref=e4]: Projet Beta
  - contentinfo "Raccourcis clavier" [ref=e5]
```

# Test source

```ts
  58  |       events: ['e1'],
  59  |       brins: [],
  60  |       persos: [],
  61  |       project_id: null,
  62  |       active: true,
  63  |       lasts_id: { event: 1, brin: 0, perso: 0 }
  64  |     }
  65  |   )
  66  | 
  67  |   writeJson(
  68  |     path.join(projectsFolder, 'beta.json'),
  69  |     {
  70  |       id: 'beta',
  71  |       scale: 'project',
  72  |       title: 'Projet Beta',
  73  |       nature: 'film',
  74  |       events: ['e1'],
  75  |       brins: [],
  76  |       persos: [],
  77  |       project_id: null,
  78  |       active: true,
  79  |       lasts_id: { event: 1, brin: 0, perso: 0 }
  80  |     }
  81  |   )
  82  | 
  83  |   for (const projectId of ['alpha', 'beta']) {
  84  |     const projectFolder = path.join(projectsFolder, projectId)
  85  | 
  86  |     writeJson(
  87  |       path.join(projectFolder, '__events__.json'),
  88  |       [
  89  |         {
  90  |           id: 'e1',
  91  |           title: `Premier évènement ${projectId}`,
  92  |           brins: [],
  93  |           persos: [],
  94  |           type: [],
  95  |           nature: [],
  96  |           duration: null,
  97  |           file: '',
  98  |           state: 1,
  99  |           child: false
  100 |         }
  101 |       ]
  102 |     )
  103 | 
  104 |     writeJson(path.join(projectFolder, '__brins__.json'), [])
  105 |     writeJson(path.join(projectFolder, '__persos__.json'), [])
  106 |   }
  107 | 
  108 |   log('data préparé avec 2 projets : alpha, beta')
  109 | }
  110 | 
  111 | test.describe('app / projects listing', () => {
  112 |   test('existing data with two projects displays exactly those projects', async ({ page, request }) => {
  113 |     const pageErrors = []
  114 | 
  115 |     page.on('pageerror', error => {
  116 |       pageErrors.push(error.message)
  117 |     })
  118 | 
  119 |     resetDataWithTwoProjects()
  120 | 
  121 |     log('ouverture /')
  122 |     const response = await page.goto('http://localhost:4567')
  123 | 
  124 |     expect(response, 'GET / ne retourne aucune réponse HTTP').not.toBeNull()
  125 |     expect(response.status(), `GET / retourne HTTP ${response.status()} au lieu de 200`).toBe(200)
  126 | 
  127 |     expect(
  128 |       pageErrors,
  129 |       `Erreurs JavaScript navigateur : ${pageErrors.join('\n')}`
  130 |     ).toEqual([])
  131 | 
  132 |     log('vérification fichiers eventers')
  133 |     const rootFile = path.join(DATA_FOLDER, '__projects__.json')
  134 |     const projectsFolder = path.join(DATA_FOLDER, '__projects__')
  135 |     const alphaFile = path.join(projectsFolder, 'alpha.json')
  136 |     const betaFile = path.join(projectsFolder, 'beta.json')
  137 |     const demoFile = path.join(projectsFolder, 'demo.json')
  138 | 
  139 |     expectFile(rootFile, 'Eventer racine')
  140 |     expectFile(projectsFolder, 'Dossier racine __projects__')
  141 |     expectFile(alphaFile, 'Eventer alpha')
  142 |     expectFile(betaFile, 'Eventer beta')
  143 | 
  144 |     log('vérification API /projects')
  145 |     const projectsResponse = await request.get('http://localhost:4567/projects')
  146 |     const projectsText = await projectsResponse.text()
  147 | 
  148 |     expect(
  149 |       projectsResponse.status(),
  150 |       `/projects retourne HTTP ${projectsResponse.status()} avec body : ${projectsText}`
  151 |     ).toBe(200)
  152 | 
  153 |     const projects = JSON.parse(projectsText)
  154 | 
  155 |     expect(
  156 |       projects,
  157 |       `/projects doit retourner uniquement les propriétés publiques attendues : id, scale, title, active. Reçu : ${JSON.stringify(projects)}`
> 158 |     ).toEqual([
      |       ^ Error: /projects doit retourner uniquement les propriétés publiques attendues : id, scale, title, active. Reçu : [{"id":"alpha","file":"alpha.json","title":"Projet Alpha","active":true},{"id":"beta","file":"beta.json","title":"Projet Beta","active":true}]
  159 |       {
  160 |         id: 'alpha',
  161 |         scale: 'project',
  162 |         title: 'Projet Alpha',
  163 |         active: true
  164 |       },
  165 |       {
  166 |         id: 'beta',
  167 |         scale: 'project',
  168 |         title: 'Projet Beta',
  169 |         active: true
  170 |       }
  171 |     ])
  172 | 
  173 |     log('vérification rendu UI')
  174 |     const bodyText = await page.locator('body').innerText()
  175 | 
  176 |     expect(
  177 |       bodyText,
  178 |       `Projet Alpha absent du rendu. Body reçu : ${bodyText}`
  179 |     ).toContain('Projet Alpha')
  180 | 
  181 |     expect(
  182 |       bodyText,
  183 |       `Projet Beta absent du rendu. Body reçu : ${bodyText}`
  184 |     ).toContain('Projet Beta')
  185 | 
  186 |     expect(
  187 |       bodyText,
  188 |       `Projet codé en dur "__e2e__" trouvé dans le rendu. Body reçu : ${bodyText}`
  189 |     ).not.toContain('__e2e__')
  190 | 
  191 |     expect(
  192 |       bodyText,
  193 |       `Projet demo affiché alors que data existait déjà. Body reçu : ${bodyText}`
  194 |     ).not.toContain('Projet de démonstration')
  195 | 
  196 |     log('vérification non-écrasement data')
  197 |     const rootEventer = readJson(rootFile)
  198 | 
  199 |     expect(
  200 |       rootEventer,
  201 |       `L’eventer racine doit rester celui préparé par le test. Reçu : ${JSON.stringify(rootEventer)}`
  202 |     ).toMatchObject({
  203 |       id: '__projects__',
  204 |       scale: 'eventer',
  205 |       events: ['alpha', 'beta']
  206 |     })
  207 | 
  208 |     expect(
  209 |       fs.existsSync(demoFile),
  210 |       `demo.json ne doit pas être créé quand data existe déjà. Chemin : ${demoFile}`
  211 |     ).toBe(false)
  212 |   })
  213 | })
  214 | 
```