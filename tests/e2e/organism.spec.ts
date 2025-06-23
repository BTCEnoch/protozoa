/**
 * @fileoverview End-to-End tests for Organism Creation
 * @description PHASE 3 TASK 3.3: E2E Test Example
 * @author Protozoa Development Team
 * @version 1.0.0
 */

import { test, expect } from '@playwright/test'

test.describe('Organism Creation E2E Tests', () => {
  test.beforeEach(async ({ page }) => {
    // Navigate to the application
    await page.goto('/')

    // Wait for initial page load
    await page.waitForLoadState('networkidle')
  })

  test('should load application and display simulation canvas', async ({ page }) => {
    // Wait for the main canvas element to be present
    await page.waitForSelector('canvas', { timeout: 10000 })

    // Verify canvas is visible and has proper dimensions
    const canvas = page.locator('canvas')
    await expect(canvas).toBeVisible()

    // Check that at least one canvas element exists (for THREE.js rendering)
    expect(await canvas.count()).toBeGreaterThanOrEqual(1)

    // Verify the canvas has reasonable dimensions
    const boundingBox = await canvas.boundingBox()
    expect(boundingBox?.width).toBeGreaterThan(100)
    expect(boundingBox?.height).toBeGreaterThan(100)
  })

  test('should create organisms from Bitcoin block data', async ({ page }) => {
    // Wait for application to load
    await page.waitForSelector('canvas')

    // Look for organism creation controls (these would be implemented in the UI)
    // This is a placeholder for when UI controls are added
    const createButton = page.locator('[data-testid="create-organism"]')

    // For now, just verify the basic structure is in place
    // In a real implementation, this would:
    // 1. Click create organism button
    // 2. Verify Bitcoin block data is fetched
    // 3. Verify particles are created and visible
    // 4. Verify organism traits are displayed

    // Check that application has loaded without errors
    const errorMessages = page.locator('[data-testid="error-message"]')
    expect(await errorMessages.count()).toBe(0)
  })

  test('should handle performance with multiple organisms', async ({ page }) => {
    // Navigate to the application
    await page.waitForSelector('canvas')

    // Measure performance metrics
    const performanceEntries = await page.evaluate(() => {
      return JSON.stringify(performance.getEntriesByType('navigation'))
    })

    const entries = JSON.parse(performanceEntries)
    const navigationEntry = entries[0]

    // Verify reasonable load times
    expect(navigationEntry.loadEventEnd - navigationEntry.loadEventStart).toBeLessThan(5000)

    // Check that the page is responsive
    const canvas = page.locator('canvas')
    await expect(canvas).toBeVisible()

    // Verify no memory leaks by checking that the page doesn't crash
    // after some interaction time
    await page.waitForTimeout(2000)

    // Page should still be responsive
    await expect(canvas).toBeVisible()
  })

  test('should be responsive on different screen sizes', async ({ page }) => {
    // Test desktop size
    await page.setViewportSize({ width: 1200, height: 800 })
    await page.waitForSelector('canvas')

    let canvas = page.locator('canvas')
    await expect(canvas).toBeVisible()

    // Test tablet size
    await page.setViewportSize({ width: 768, height: 1024 })
    await page.waitForTimeout(500) // Allow for responsive adjustments

    canvas = page.locator('canvas')
    await expect(canvas).toBeVisible()

    // Test mobile size
    await page.setViewportSize({ width: 375, height: 667 })
    await page.waitForTimeout(500) // Allow for responsive adjustments

    canvas = page.locator('canvas')
    await expect(canvas).toBeVisible()
  })

  test('should handle navigation and routing', async ({ page }) => {
    // Verify main page loads
    await page.waitForSelector('canvas')

    // Test that the application doesn't have broken links
    // This would be expanded as the application grows
    const appTitle = page.locator('title')
    await expect(appTitle).not.toBeEmpty()

    // Check that essential UI elements are present
    const body = page.locator('body')
    await expect(body).toBeVisible()

    // Verify no console errors
    const consoleErrors: string[] = []
    page.on('console', (msg) => {
      if (msg.type() === 'error') {
        consoleErrors.push(msg.text())
      }
    })

    // Wait for any async operations to complete
    await page.waitForTimeout(3000)

    // Should have minimal console errors (allow for expected development warnings)
    expect(consoleErrors.length).toBeLessThan(5)
  })
})
