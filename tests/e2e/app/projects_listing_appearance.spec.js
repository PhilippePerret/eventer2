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

function resetDataWithTwoProjects() {
  log('préparation data avec 2 projets')

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

  for (const project of [
    { id: 'alpha', title: 'Projet Alpha', nature: 'roman' },
    { id: 'beta', title: 'Projet Beta', nature: 'film' }
  ]) {
    writeJson(
      path.join(projectsFolder, `${project.id}.json`),
      {
        id: project.id,
        scale: 'project',
        title: project.title,
        nature: project.nature,
        events: ['e1'],
        brins: [],
        persos: [],
        project_id: null,
        active: true,
        lasts_id: { event: 1, brin: 0, perso: 0 }
      }
    )

    writeJson(path.join(projectsFolder, project.id, '__events__.json'), [])
    writeJson(path.join(projectsFolder, project.id, '__brins__.json'), [])
    writeJson(path.join(projectsFolder, project.id, '__persos__.json'), [])
  }
}

test.describe('app / projects listing appearance', () => {
  test('root eventer uses the projects listing appearance', async ({ page }) => {
    resetDataWithTwoProjects()

    log('ouverture /')
    const response = await page.goto('http://localhost:4567')

    expect(response, 'GET / ne retourne aucune réponse HTTP').not.toBeNull()
    expect(response.status(), `GET / retourne HTTP ${response.status()} au lieu de 200`).toBe(200)

    log('vérification apparence listing projets')
    const panel = page.locator('#main-panel')

    await expect(
      panel,
      'Le panneau principal doit être marqué comme listing projets'
    ).toHaveClass(/projects-listing/)

    const items = panel.locator('.project-listing__item')

    await expect(
      items,
      'Le listing projets doit afficher exactement 2 lignes projet'
    ).toHaveCount(2)

    await expect(
      items.nth(0).locator('.project-listing__title'),
      'La première ligne doit afficher le titre du projet'
    ).toHaveText('Projet Alpha')

    await expect(
      items.nth(0).locator('.project-listing__id'),
      'La première ligne doit afficher l’identifiant du projet'
    ).toHaveText('alpha')

    await expect(
      items.nth(1).locator('.project-listing__title'),
      'La deuxième ligne doit afficher le titre du projet'
    ).toHaveText('Projet Beta')

    await expect(
      items.nth(1).locator('.project-listing__id'),
      'La deuxième ligne doit afficher l’identifiant du projet'
    ).toHaveText('beta')

    await expect(
      panel.locator('.event-line'),
      'Le listing racine des projets ne doit pas utiliser l’apparence des events'
    ).toHaveCount(0)
  })
})
