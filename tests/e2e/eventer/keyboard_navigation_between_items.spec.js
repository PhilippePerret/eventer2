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

function expectSelected(lines, index, label) {

  return expect(
    lines.nth(index),
    `${label} doit être sélectionné`
  ).toHaveClass(/selected/)
}

function expectNotSelected(lines, index, label) {

  return expect(
    lines.nth(index),
    `${label} ne doit pas être sélectionné`
  ).not.toHaveClass(/selected/)
}

test.describe('app / keyboard navigation', () => {

  test('up and down arrows move current selection in eventer', async ({ page }) => {

    prepareData()

    log('ouverture de la racine')
    await page.goto('http://localhost:4567')

    const lines = page.locator('.event')

    log('vérification sélection initiale')
    await expectSelected(lines, 0, 'Le premier projet')
    await expectNotSelected(lines, 1, 'Le deuxième projet')
    await expectNotSelected(lines, 2, 'Le troisième projet')

    log('flèche bas')
    await page.keyboard.press('ArrowDown')

    await expectNotSelected(lines, 0, 'Le premier projet')
    await expectSelected(lines, 1, 'Le deuxième projet')
    await expectNotSelected(lines, 2, 'Le troisième projet')

    log('deuxième flèche bas')
    await page.keyboard.press('ArrowDown')

    await expectNotSelected(lines, 0, 'Le premier projet')
    await expectNotSelected(lines, 1, 'Le deuxième projet')
    await expectSelected(lines, 2, 'Le troisième projet')

    log('flèche haut')
    await page.keyboard.press('ArrowUp')

    await expectNotSelected(lines, 0, 'Le premier projet')
    await expectSelected(lines, 1, 'Le deuxième projet')
    await expectNotSelected(lines, 2, 'Le troisième projet')
  })
})
