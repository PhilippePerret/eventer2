import { test, expect } from '@playwright/test'
import fs from 'fs'
import path from 'path'

const DATA_FOLDER = path.join(process.cwd(), 'data')

function exists(pathname) {
  return fs.existsSync(pathname)
}

function readJson(pathname) {
  return JSON.parse(fs.readFileSync(pathname, 'utf8'))
}

function expectPathExists(pathname, label) {
  expect(
    exists(pathname),
    `${label} introuvable : ${pathname}`
  ).toBe(true)
}

function expectJsonArray(pathname, label) {
  expectPathExists(pathname, label)

  const data = readJson(pathname)

  expect(
    Array.isArray(data),
    `${label} doit contenir un tableau JSON. Contenu reçu : ${JSON.stringify(data)}`
  ).toBe(true)

  return data
}

test.describe('app / bootstrap', () => {
  test('application boots without data folder', async ({ page }) => {
    const pageLogs = []
    const pageErrors = []

    page.on('console', message => {
      pageLogs.push(`[${message.type()}] ${message.text()}`)
    })

    page.on('pageerror', error => {
      pageErrors.push(error.message)
    })

    if (exists(DATA_FOLDER)) {
      fs.rmSync(DATA_FOLDER, { recursive: true, force: true })
    }

    const response = await page.goto('http://localhost:4567')

    expect(response, 'GET / ne retourne aucune réponse HTTP').not.toBeNull()

    expect(
      response.status(),
      `GET / retourne HTTP ${response.status()} au lieu de 200`
    ).toBe(200)

    expect(
      pageErrors,
      `Erreurs JavaScript navigateur : ${pageErrors.join('\n')}`
    ).toEqual([])

    const projectsFile = path.join(DATA_FOLDER, '__projects__.json')
    const projectsFolder = path.join(DATA_FOLDER, '__projects__')
    const demoFolder = path.join(projectsFolder, 'demo')
    const demoEventerFile = path.join(demoFolder, '__projects__.json')
    const eventsFile = path.join(demoFolder, '__events__.json')
    const brinsFile = path.join(demoFolder, '__brins__.json')
    const persosFile = path.join(demoFolder, '__persos__.json')

    expectPathExists(DATA_FOLDER, 'Dossier data')
    expectPathExists(projectsFile, 'Index racine des projets')
    expectPathExists(projectsFolder, 'Dossier racine __projects__')
    expectPathExists(demoFolder, 'Dossier du projet demo')
    expectPathExists(demoEventerFile, 'Eventer projet demo')
    expectPathExists(eventsFile, 'Liste des events du projet demo')
    expectPathExists(brinsFile, 'Liste des brins du projet demo')
    expectPathExists(persosFile, 'Liste des personnages du projet demo')

    const projectIds = expectJsonArray(projectsFile, 'Index racine des projets')
    const demoEventer = readJson(demoEventerFile)
    const events = expectJsonArray(eventsFile, 'Liste des events du projet demo')
    const brins = expectJsonArray(brinsFile, 'Liste des brins du projet demo')
    const persos = expectJsonArray(persosFile, 'Liste des personnages du projet demo')

    expect(
      projectIds,
      `__projects__.json doit contenir uniquement ["demo"]. Reçu : ${JSON.stringify(projectIds)}`
    ).toEqual(['demo'])

    expect(
      demoEventer.scale,
      `Le projet demo doit être un Eventer de scale "project". Reçu : ${JSON.stringify(demoEventer)}`
    ).toBe('project')

    expect(
      demoEventer.title,
      `Le projet demo doit avoir un titre explicite. Reçu : ${JSON.stringify(demoEventer)}`
    ).toBe('Projet de démonstration')

    expect(
      demoEventer,
      `Propriété interdite "evenements" trouvée dans l'Eventer projet : ${JSON.stringify(demoEventer)}`
    ).not.toHaveProperty('evenements')

    expect(
      demoEventer,
      `Propriété obligatoire "events" absente de l'Eventer projet : ${JSON.stringify(demoEventer)}`
    ).toHaveProperty('events')

    expect(
      events.length,
      `${eventsFile} doit contenir au moins un event explicatif`
    ).toBeGreaterThan(0)

    expect(
      brins.length,
      `${brinsFile} doit contenir au moins un brin explicatif`
    ).toBeGreaterThan(0)

    expect(
      persos.length,
      `${persosFile} doit contenir au moins un personnage explicatif`
    ).toBeGreaterThan(0)

    await expect(
      page.locator('body'),
      `Le projet demo doit être visible dans l’interface. Logs page : ${pageLogs.join('\n')}`
    ).toContainText('Projet de démonstration')
  })
})
