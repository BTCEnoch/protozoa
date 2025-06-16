# Testing Strategy

This document outlines the testing approach for the Beast Import project, focusing on ensuring the application works correctly with immutable on-chain resources.

## Testing Philosophy

Since the final application will rely on immutable, static resources on the Bitcoin blockchain, our testing strategy focuses on:

1. **Pre-deployment Validation**: Thorough testing before inscription to ensure everything works correctly
2. **Deterministic Behavior**: Verifying that the same inputs always produce the same outputs
3. **Resource Independence**: Testing that the application works with the expected immutable resources
4. **Performance Verification**: Ensuring the application meets performance targets

## Testing Layers

### 1. Unit Testing

Unit tests focus on individual functions and components to ensure they work as expected in isolation.

#### Core Functions to Test

- **RNG System**:
  - Deterministic output for the same seed
  - Chain RNG consistency
  - Purpose-specific RNG isolation

- **Trait Generation**:
  - Correct trait assignment based on RNG
  - Rarity distribution accuracy
  - Role-appropriate trait selection

- **Physics Calculations**:
  - Force calculations
  - Particle movement
  - Collision detection
  - Force field containment

- **Mutation System**:
  - Milestone detection
  - Mutation chance calculation
  - Mutation application

#### Implementation Approach

```typescript
// Example unit test for deterministic RNG
describe('RNG System', () => {
  test('produces the same sequence for the same seed', () => {
    const rng1 = mulberry32(12345);
    const rng2 = mulberry32(12345);
    
    // Generate 100 values from each RNG
    const sequence1 = Array.from({ length: 100 }, () => rng1());
    const sequence2 = Array.from({ length: 100 }, () => rng2());
    
    // Sequences should be identical
    expect(sequence1).toEqual(sequence2);
  });
  
  test('produces different sequences for different seeds', () => {
    const rng1 = mulberry32(12345);
    const rng2 = mulberry32(67890);
    
    // Generate values from each RNG
    const value1 = rng1();
    const value2 = rng2();
    
    // Values should be different
    expect(value1).not.toEqual(value2);
  });
});
```

### 2. Integration Testing

Integration tests verify that different parts of the system work together correctly.

#### Key Integration Points to Test

- **RNG to Trait System**: Verify traits are correctly generated from RNG
- **Trait System to Particle System**: Verify particles correctly apply traits
- **Particle System to Physics**: Verify physics calculations correctly use particle properties
- **Bitcoin API to Application**: Verify block data is correctly fetched and processed

#### Implementation Approach

```typescript
// Example integration test for trait generation from RNG
describe('Trait Generation Integration', () => {
  test('generates consistent traits from the same block data', () => {
    const blockData = { nonce: 12345, confirmations: 0 };
    
    // Generate traits twice with the same block data
    const traits1 = generateTraits(blockData);
    const traits2 = generateTraits(blockData);
    
    // Traits should be identical
    expect(traits1).toEqual(traits2);
  });
  
  test('applies traits correctly to particle groups', () => {
    const blockData = { nonce: 12345, confirmations: 0 };
    const traits = generateTraits(blockData);
    
    // Create particle groups with these traits
    const groups = createParticleGroups(traits);
    
    // Verify each group has the correct traits applied
    Object.entries(groups).forEach(([groupId, group]) => {
      const expectedTraits = traits[groupId];
      expect(group.visualTraits).toEqual(expectedTraits.visualTraits);
      expect(group.formationTraits).toEqual(expectedTraits.formationTraits);
      // ... other trait verifications
    });
  });
});
```

### 3. Visual Testing

Visual testing ensures that the application renders correctly and that visual traits are applied as expected.

#### Visual Aspects to Test

- **Particle Rendering**: Verify particles render with correct shapes, colors, and effects
- **Formation Visualization**: Verify formations are correctly applied
- **Animation Smoothness**: Verify animations run at the target frame rate
- **Visual Effects**: Verify effects render correctly

#### Implementation Approach

```typescript
// Example visual test using screenshot comparison
describe('Visual Rendering', () => {
  test('renders particles with correct visual traits', async () => {
    // Set up a controlled environment with known traits
    const blockData = { nonce: 12345, confirmations: 0 };
    const traits = generateTraits(blockData);
    
    // Render the scene
    const { container } = render(<ParticleScene blockData={blockData} />);
    
    // Wait for rendering to complete
    await waitFor(() => expect(screen.getByTestId('scene-ready')).toBeInTheDocument());
    
    // Take a screenshot
    const screenshot = await takeScreenshot(container);
    
    // Compare with reference image
    expect(screenshot).toMatchImageSnapshot();
  });
});
```

### 4. Performance Testing

Performance testing ensures the application meets performance targets and runs smoothly.

#### Performance Aspects to Test

- **Frame Rate**: Verify the application maintains 60 FPS with 500 particles
- **Memory Usage**: Verify memory usage remains within acceptable limits
- **CPU Usage**: Verify CPU usage remains within acceptable limits
- **Loading Time**: Verify the application loads within acceptable time

#### Implementation Approach

```typescript
// Example performance test
describe('Performance', () => {
  test('maintains 60 FPS with 500 particles', async () => {
    // Set up the application with 500 particles
    const { container } = render(<ParticleScene particleCount={500} />);
    
    // Wait for rendering to complete
    await waitFor(() => expect(screen.getByTestId('scene-ready')).toBeInTheDocument());
    
    // Measure FPS over 10 seconds
    const fpsReadings = await measureFPS(10000);
    
    // Calculate average FPS
    const averageFPS = fpsReadings.reduce((sum, fps) => sum + fps, 0) / fpsReadings.length;
    
    // Verify average FPS is at least 58 (allowing for small variations)
    expect(averageFPS).toBeGreaterThanOrEqual(58);
  });
  
  test('memory usage remains stable', async () => {
    // Set up the application
    render(<ParticleScene />);
    
    // Wait for rendering to complete
    await waitFor(() => expect(screen.getByTestId('scene-ready')).toBeInTheDocument());
    
    // Measure memory usage over time
    const initialMemory = performance.memory.usedJSHeapSize;
    
    // Run for 30 seconds
    await new Promise(resolve => setTimeout(resolve, 30000));
    
    const finalMemory = performance.memory.usedJSHeapSize;
    
    // Verify memory growth is within acceptable limits (e.g., less than 10%)
    expect(finalMemory - initialMemory).toBeLessThan(initialMemory * 0.1);
  });
});
```

### 5. Bitcoin Integration Testing

Bitcoin integration testing ensures the application correctly interacts with Bitcoin block data.

#### Bitcoin Integration Aspects to Test

- **Block Data Fetching**: Verify block data is correctly fetched from the API
- **Nonce Processing**: Verify the nonce is correctly used for RNG
- **Confirmation Handling**: Verify confirmation count is correctly used for mutations
- **Error Handling**: Verify the application handles API errors gracefully

#### Implementation Approach

```typescript
// Example Bitcoin integration test
describe('Bitcoin Integration', () => {
  // Mock the Bitcoin API
  beforeEach(() => {
    jest.spyOn(global, 'fetch').mockImplementation((url) => {
      if (url.includes('/blockinfo/')) {
        return Promise.resolve({
          ok: true,
          json: () => Promise.resolve({
            nonce: 12345,
            confirmations: 1000,
            timestamp: Date.now()
          })
        });
      }
      return Promise.reject(new Error('Not found'));
    });
  });
  
  afterEach(() => {
    jest.restoreAllMocks();
  });
  
  test('fetches and processes block data correctly', async () => {
    // Call the function that fetches block data
    const blockData = await fetchBlockInfo(123456);
    
    // Verify the data is correctly processed
    expect(blockData).toEqual({
      nonce: 12345,
      confirmations: 1000,
      timestamp: expect.any(Number)
    });
    
    // Verify the fetch was called with the correct URL
    expect(fetch).toHaveBeenCalledWith(expect.stringContaining('/blockinfo/123456'));
  });
  
  test('handles API errors gracefully', async () => {
    // Make fetch return an error
    global.fetch.mockImplementationOnce(() => Promise.reject(new Error('API error')));
    
    // Call the function that fetches block data
    const result = await fetchBlockInfo(123456).catch(e => e);
    
    // Verify the error is handled
    expect(result).toBeInstanceOf(Error);
    expect(result.message).toContain('API error');
  });
});
```

## Testing Tools

### Unit and Integration Testing
- **Vitest**: Fast, Jest-compatible testing framework for Vite
- **React Testing Library**: For testing React components
- **MSW (Mock Service Worker)**: For mocking API requests

### Visual Testing
- **Storybook**: For developing and testing UI components in isolation
- **Chromatic**: For visual regression testing
- **Playwright**: For end-to-end testing with visual comparisons

### Performance Testing
- **Lighthouse**: For performance metrics
- **React Profiler**: For component performance analysis
- **Custom FPS Monitor**: For measuring frame rate

## Testing Environment

### Local Development
- **Development Mode**: Tests run against local resources
- **Mock Bitcoin API**: Simulated responses for development

### Pre-Deployment
- **Production Build**: Tests run against the production build
- **Simulated Inscription Environment**: Tests run with resources loaded as they would be from inscriptions

## Test Automation

### Continuous Integration
- **GitHub Actions**: Automated test runs on pull requests
- **Performance Benchmarks**: Automated performance testing

### Pre-Inscription Checklist
- **Full Test Suite**: All tests must pass
- **Performance Verification**: Performance tests must meet targets
- **Visual Verification**: Visual tests must pass
- **Manual Testing**: Final manual verification

## Implementation Plan

1. **Set Up Testing Framework**:
   - Configure Vitest with React Testing Library
   - Set up testing utilities and helpers

2. **Implement Core Unit Tests**:
   - RNG system tests
   - Trait generation tests
   - Physics calculation tests

3. **Implement Integration Tests**:
   - Component integration tests
   - System integration tests

4. **Implement Visual Tests**:
   - Set up Storybook for component development
   - Implement visual regression tests

5. **Implement Performance Tests**:
   - Create custom performance monitoring tools
   - Set up performance benchmarks

6. **Implement Bitcoin Integration Tests**:
   - Mock Bitcoin API
   - Test block data processing

7. **Create Pre-Inscription Test Suite**:
   - Comprehensive test suite for final verification
   - Automated and manual testing checklist
