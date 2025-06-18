import { expect, test } from '@playwright/test'

test('organism creation flow',async({ page })=>{
  await page.goto('http://localhost:3000')
  await page.waitForSelector('canvas')
  expect(await page.locator('canvas').count()).toBe(1)
})
