import { test, expect } from '@playwright/test'
import fs from 'fs'
import path from 'path'

const PROJECT_ROOT = path.resolve(process.cwd(), '..')
const DATA_FOLDER  = path.join(PROJECT_ROOT, 'data')

function log(step, data = null) {
  if (data) {
    console.log(`[TEST] ${step}`, data)
  } else {
    console.log(`[TEST] ${step}`)
  }
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

test.describe('Persistance de réorganisation des projets', () => {

  test('la position des projets est conservée après reload', async ({ page }) => {

    prepareData()

    await page.goto('http://127.0.0.1:4567')

    const projects = page.locator('.event')

    await expect(projects).toHaveCount(3)

    const initialOrder = await projects.evaluateAll(nodes =>
      nodes.map(node => node.innerText.trim())
    )

    log('ordre initial', initialOrder)

    await page.keyboard.press('ArrowDown')

    await expect(projects.nth(1)).toHaveClass(/selected/)

    await page.keyboard.press('Meta+ArrowUp')

    const movedOrder = await projects.evaluateAll(nodes =>
      nodes.map(node => node.innerText.trim())
    )

    log('ordre après déplacement', movedOrder)

    expect(movedOrder[0]).toBe(initialOrder[1])
    expect(movedOrder[1]).toBe(initialOrder[0])

    await page.reload()

    const projectsAfterReload = page.locator('.event')

    await expect(projectsAfterReload).toHaveCount(3)

    const persistedOrder = await projectsAfterReload.evaluateAll(nodes =>
      nodes.map(node => node.innerText.trim())
    )

    log('ordre après reload', persistedOrder)

    expect(persistedOrder).toEqual(movedOrder)

  })

})
