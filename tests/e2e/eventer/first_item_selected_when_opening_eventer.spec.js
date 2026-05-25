import { test, expect } from '@playwright/test'
import fs from 'fs'
import path from 'path'

const PROJECT_ROOT = path.resolve(process.cwd(), '..')
const DATA_FOLDER  = path.join(PROJECT_ROOT, 'data')

function log(step) {
  console.log(`[TEST] ${step}`)
}

function writeJson(pathname, data) {
  fs.mkdirSync(path.dirname(pathname), { recursive: true })
  fs.writeFileSync(pathname, JSON.stringify(data, null, 2))
}

function prepareData() {
  log('préparation de 3 projets')

  if (fs.existsSync(DATA_FOLDER)) {
    fs.rmSync(DATA_FOLDER, { recursive: true, force: true })
  }

  const projectsFolder = path.join(DATA_FOLDER, '__projects__')

  writeJson(
    path.join(DATA_FOLDER, '__projects__.json'),
    {
      id: '__projects__',
      scale: 'eventer',
      events: ['alpha', 'beta', 'gamma'],
      brins: [],
      persos: [],
      active: true
    }
  )

  ;[
    ['alpha', 'Projet Alpha'],
    ['beta',  'Projet Beta'],
    ['gamma', 'Projet Gamma']
  ].forEach(([id, title]) => {

    writeJson(
      path.join(projectsFolder, `${id}.json`),
      {
        id,
        scale: 'project',
        title,
        events: [],
        brins: [],
        persos: [],
        active: true
      }
    )

    writeJson(
      path.join(projectsFolder, id, '__events__.json'),
      []
    )

    writeJson(
      path.join(projectsFolder, id, '__brins__.json'),
      []
    )

    writeJson(
      path.join(projectsFolder, id, '__persos__.json'),
      []
    )
  })
}

test.describe('app / selection', () => {

  test('first item is selected when an eventer opens', async ({ page }) => {

    prepareData()

    log('ouverture de la racine')
    await page.goto('http://localhost:4567')

    log('vérification présence de 3 lignes')
    const lines = page.locator('.project-listing__item')

    await expect(
      lines,
      'Le listing doit contenir exactement 3 lignes'
    ).toHaveCount(3)

    log('vérification sélection première ligne')
    const firstLine = lines.nth(0)

    await expect(
      firstLine,
      'La première ligne doit être sélectionnée automatiquement'
    ).toHaveClass(/selected|current|active/)

    log('vérification absence sélection autres lignes')

    await expect(
      lines.nth(1),
      'La deuxième ligne ne doit pas être sélectionnée'
    ).not.toHaveClass(/selected|current|active/)

    await expect(
      lines.nth(2),
      'La troisième ligne ne doit pas être sélectionnée'
    ).not.toHaveClass(/selected|current|active/)
  })
})
