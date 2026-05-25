import { test, expect } from '@playwright/test'
import fs from 'fs'
import path from 'path'

const PROJECT_ROOT = path.resolve(process.cwd(), '..')
const DATA_FOLDER = path.join(PROJECT_ROOT, 'data')

function log(message) {
  console.log(`[TEST] ${message}`)
}

function writeJson(pathname, data) {
  fs.mkdirSync(path.dirname(pathname), { recursive: true })
  fs.writeFileSync(pathname, JSON.stringify(data, null, 2))
}

function readJson(pathname) {
  return JSON.parse(fs.readFileSync(pathname, 'utf8'))
}

function expectFile(pathname, label) {
  expect(
    fs.existsSync(pathname),
    `${label} introuvable : ${pathname}`
  ).toBe(true)
}

function resetDataWithTwoProjects() {
  log(`préparation data : ${DATA_FOLDER}`)

  if (fs.existsSync(DATA_FOLDER)) {
    fs.rmSync(DATA_FOLDER, { recursive: true, force: true })
  }

  const projectsFolder = path.join(DATA_FOLDER, '__projects__')

  writeJson(
    path.join(DATA_FOLDER, '__projects__.json'),
    {
      id: '__projects__',
      scale: 'eventer',
      events: ['alpha', 'beta'],
      brins: [],
      persos: [],
      project_id: null,
      active: true,
      lasts_id: { event: 2, brin: 0, perso: 0 }
    }
  )

  writeJson(
    path.join(projectsFolder, 'alpha.json'),
    {
      id: 'alpha',
      scale: 'project',
      title: 'Projet Alpha',
      nature: 'roman',
      events: ['e1'],
      brins: [],
      persos: [],
      project_id: null,
      active: true,
      lasts_id: { event: 1, brin: 0, perso: 0 }
    }
  )

  writeJson(
    path.join(projectsFolder, 'beta.json'),
    {
      id: 'beta',
      scale: 'project',
      title: 'Projet Beta',
      nature: 'film',
      events: ['e1'],
      brins: [],
      persos: [],
      project_id: null,
      active: true,
      lasts_id: { event: 1, brin: 0, perso: 0 }
    }
  )

  for (const projectId of ['alpha', 'beta']) {
    const projectFolder = path.join(projectsFolder, projectId)

    writeJson(
      path.join(projectFolder, '__events__.json'),
      [
        {
          id: 'e1',
          title: `Premier évènement ${projectId}`,
          brins: [],
          persos: [],
          type: [],
          nature: [],
          duration: null,
          file: '',
          state: 1,
          child: false
        }
      ]
    )

    writeJson(path.join(projectFolder, '__brins__.json'), [])
    writeJson(path.join(projectFolder, '__persos__.json'), [])
  }

  log('data préparé avec 2 projets : alpha, beta')
}

test.describe('app / projects listing', () => {
  test('existing data with two projects displays exactly those projects', async ({ page, request }) => {
    const pageErrors = []

    page.on('pageerror', error => {
      pageErrors.push(error.message)
    })

    resetDataWithTwoProjects()

    log('ouverture /')
    const response = await page.goto('http://localhost:4567')

    expect(response, 'GET / ne retourne aucune réponse HTTP').not.toBeNull()
    expect(response.status(), `GET / retourne HTTP ${response.status()} au lieu de 200`).toBe(200)

    expect(
      pageErrors,
      `Erreurs JavaScript navigateur : ${pageErrors.join('\n')}`
    ).toEqual([])

    log('vérification fichiers eventers')
    const rootFile = path.join(DATA_FOLDER, '__projects__.json')
    const projectsFolder = path.join(DATA_FOLDER, '__projects__')
    const alphaFile = path.join(projectsFolder, 'alpha.json')
    const betaFile = path.join(projectsFolder, 'beta.json')
    const demoFile = path.join(projectsFolder, 'demo.json')

    expectFile(rootFile, 'Eventer racine')
    expectFile(projectsFolder, 'Dossier racine __projects__')
    expectFile(alphaFile, 'Eventer alpha')
    expectFile(betaFile, 'Eventer beta')

    log('vérification API /projects')
    const projectsResponse = await request.get('http://localhost:4567/projects')
    const projectsText = await projectsResponse.text()

    expect(
      projectsResponse.status(),
      `/projects retourne HTTP ${projectsResponse.status()} avec body : ${projectsText}`
    ).toBe(200)

    const projects = JSON.parse(projectsText)

    expect(
      projects,
      `/projects doit retourner uniquement les propriétés publiques attendues : id, scale, title, active. Reçu : ${JSON.stringify(projects)}`
    ).toEqual([
      {
        id: 'alpha',
        scale: 'project',
        title: 'Projet Alpha',
        active: true
      },
      {
        id: 'beta',
        scale: 'project',
        title: 'Projet Beta',
        active: true
      }
    ])

    log('vérification rendu UI')
    const bodyText = await page.locator('body').innerText()

    expect(
      bodyText,
      `Projet Alpha absent du rendu. Body reçu : ${bodyText}`
    ).toContain('Projet Alpha')

    expect(
      bodyText,
      `Projet Beta absent du rendu. Body reçu : ${bodyText}`
    ).toContain('Projet Beta')

    expect(
      bodyText,
      `Projet codé en dur "__e2e__" trouvé dans le rendu. Body reçu : ${bodyText}`
    ).not.toContain('__e2e__')

    expect(
      bodyText,
      `Projet demo affiché alors que data existait déjà. Body reçu : ${bodyText}`
    ).not.toContain('Projet de démonstration')

    log('vérification non-écrasement data')
    const rootEventer = readJson(rootFile)

    expect(
      rootEventer,
      `L’eventer racine doit rester celui préparé par le test. Reçu : ${JSON.stringify(rootEventer)}`
    ).toMatchObject({
      id: '__projects__',
      scale: 'eventer',
      events: ['alpha', 'beta']
    })

    expect(
      fs.existsSync(demoFile),
      `demo.json ne doit pas être créé quand data existe déjà. Chemin : ${demoFile}`
    ).toBe(false)
  })
})
