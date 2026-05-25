import { test, expect } from '@playwright/test'
import fs from 'fs'
import path from 'path'

test('application boots without data folder', async ({ page }) => {

  const dataFolder = path.join(process.cwd(), 'data')

  if (fs.existsSync(dataFolder)) {
    fs.rmSync(dataFolder, { recursive: true, force: true })
  }

  await page.goto('http://localhost:4567')

  expect(fs.existsSync(dataFolder)).toBe(true)

  const projectsFolder = path.join(dataFolder, '__projects__')
  const demoFolder     = path.join(projectsFolder, 'demo')

  expect(fs.existsSync(projectsFolder)).toBe(true)
  expect(fs.existsSync(demoFolder)).toBe(true)

  expect(
    fs.existsSync(
      path.join(dataFolder, '__projects__.json')
    )
  ).toBe(true)

  expect(
    fs.existsSync(
      path.join(demoFolder, '__events__.json')
    )
  ).toBe(true)

  expect(
    fs.existsSync(
      path.join(demoFolder, '__brins__.json')
    )
  ).toBe(true)

  expect(
    fs.existsSync(
      path.join(demoFolder, '__persos__.json')
    )
  ).toBe(true)

  await expect(page.locator('body')).toContainText(
    'Projet de démonstration'
  )

})
