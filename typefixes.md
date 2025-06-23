# TypeScript Fixes Action Plan

**Systematic Template & Script-Level Fixes for Protozoa Automation Suite**

## 🎯 **STRATEGY: Template-First Resolution**

All fixes will be applied at the **template and script level** to ensure permanent resolution and maintain the automation architecture integrity.

---

## 📊 **ERROR ANALYSIS SUMMARY**

**Total Errors:** 76 TypeScript errors across 16 files  
**Error Categories:**

1. **React Integration Issues** (12 errors)
2. **Store Interface Mismatches** (18 errors)
3. **OpenTelemetry Dependencies** (11 errors)
4. **Service Method Mismatches** (15 errors)
5. **Component Interface Issues** (10 errors)
6. **Import/Export Problems** (10 errors)

---

## 🔧 **ACTION PLAN - PRIORITY ORDER**

### **PHASE 1: CRITICAL FOUNDATION FIXES**

#### **1.1 Fix React Type System (12 errors)**

**Files:** `main.tsx`, `hooks.ts`, `ParticleSystem.tsx`  
**Root Cause:** React 18 type configuration and import issues

**Template Fixes Required:**

- `templates/tsconfig.json.template` - Add proper React 18 type configuration
- `templates/src/main.tsx.template` - Fix React import patterns
- `templates/components/r3f/hooks.ts.template` - Fix useFrame and Three.js types
- `templates/components/r3f/ParticleSystem.tsx.template` - Fix ref typing

**Script Updates:**

- `scripts/19-ConfigureAdvancedTypeScript.ps1` - Enhanced React 18 support
- `scripts/59-GenerateMainEntryPoint.ps1` - Proper React import generation

**Actions:**

```typescript
// Fix tsconfig.json.template
{
  "compilerOptions": {
    "jsx": "react-jsx",
    "types": ["node", "vite/client", "@types/react", "@types/react-dom"],
    "moduleResolution": "bundler",
    "allowSyntheticDefaultImports": true,
    "esModuleInterop": true
  }
}

// Fix main.tsx.template React imports
import React, { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
```

#### **1.2 Fix Store Interface Exports (18 errors)**

**Files:** `useSimulationStore.ts`, `useParticleStore.ts`, `index.ts`  
**Root Cause:** Interface types not properly exported from store files

**Template Fixes Required:**

- `templates/shared/state/useSimulationStore.ts.template` - Export SimulationState interface
- `templates/shared/state/useParticleStore.ts.template` - Export ParticleState interface
- `templates/shared/state/index.ts.template` - Fix type re-exports

**Script Updates:**

- `scripts/33a-GenerateStores.ps1` - Ensure proper type exports
- `scripts/51-SetupGlobalStateManagement.ps1` - Validate store interfaces

**Actions:**

```typescript
// Fix useSimulationStore.ts.template
export interface SimulationState {
  isRunning: boolean
  isPaused: boolean
  speed: number
  timeScale: number
  backgroundColor: string
  ambientLight: number
  worldSize: number
  showWireframe: boolean
  startSimulation: () => void
  pauseSimulation: () => void
  stopSimulation: () => void
  setSpeed: (speed: number) => void
  setTimeScale: (scale: number) => void
  updateFrameRate: (fps: number) => void
  updateRenderTime: (time: number) => void
}

// Fix useParticleStore.ts.template
export interface ParticleState {
  particles: ParticleInstance[]
  particleSize: number
  particleColor: string
  particleOpacity: number
  isInitialized: boolean
  addParticle: (particle: ParticleInstance) => void
  removeParticle: (id: string) => void
  updateParticle: (id: string, updates: Partial<ParticleInstance>) => void
  clearParticles: () => void
}
```

---

### **PHASE 2: DEPENDENCY & IMPORT RESOLUTION**

#### **2.1 Fix OpenTelemetry Type Dependencies (11 errors)**

**Files:** `tracing.ts`, `monitoring.ts`  
**Root Cause:** OpenTelemetry packages installed but @opentelemetry/api types missing

**Template Fixes Required:**

- `templates/shared/observability/tracing.ts.template` - Add missing type imports
- `templates/package.json.template` - Add @opentelemetry/api dependency

**Script Updates:**

- `scripts/29a-SetupOpenTelemetry.ps1` - Install missing type packages

**Actions:**

```powershell
# Add to 29a-SetupOpenTelemetry.ps1
$otPackages = @(
    "@opentelemetry/api@^1.7.0",  # Add missing API types
    "@opentelemetry/sdk-node@^0.49.1",
    # ... existing packages
)
```

#### **2.2 Fix Service Method Interfaces (15 errors)**

**Files:** `ParticleService.ts`, `TraitService.ts`, `BitcoinService.ts`  
**Root Cause:** Components calling methods that don't exist on service interfaces

**Template Fixes Required:**

- `templates/domains/particle/services/ParticleService.ts.template` - Add missing methods
- `templates/domains/trait/services/TraitService.ts.template` - Add dependency injection methods
- `templates/domains/bitcoin/services/BitcoinService.ts.template` - Add configuration methods

**Script Updates:**

- `scripts/31-GenerateParticleService.ps1` - Enhanced method generation
- `scripts/27-GenerateTraitService.ps1` - Add missing method stubs

**Actions:**

```typescript
// Add to ParticleService.ts.template
export class ParticleService implements IParticleService {
  // Add missing methods expected by components
  spawnParticle(systemId: string, config: ParticleCreationData): string
  getSystems(): Map<string, ParticleSystem>
  setParticleStore(store: any): void
  setSimulationStore(store: any): void
  setStateLoggingEnabled(enabled: boolean): void
  setStorePersistenceEnabled(enabled: boolean): void
}
```

---

### **PHASE 3: COMPONENT INTERFACE ALIGNMENT**

#### **3.1 Fix Component Type Interfaces (10 errors)**

**Files:** `SimulationCanvas.tsx`, `ParticleSystem.tsx`, `Scene.tsx`  
**Root Cause:** Components expecting different interfaces than services provide

**Template Fixes Required:**

- `templates/components/SimulationCanvas.tsx.template` - Align with actual service interfaces
- `templates/components/r3f/ParticleSystem.tsx.template` - Fix Three.js ref types
- `templates/components/r3f/Scene.tsx.template` - Fix store property access

**Script Updates:**

- `scripts/52-SetupReactIntegration.ps1` - Validate component-service interfaces
- `scripts/41a-SetupR3FIntegration.ps1` - Enhanced Three.js type support

**Actions:**

```typescript
// Fix SimulationCanvas.tsx.template
import { RenderingService } from '@/domains/rendering/services/RenderingService'
// Change to:
import { renderingService } from '@/domains/rendering/services/RenderingService'

// Fix ParticleSystem.tsx.template ref typing
const materialRef = useRef<THREE.MeshStandardMaterial>(null)
```

#### **3.2 Fix Three.js Integration Types (8 errors)**

**Files:** `ParticleSystem.tsx`, `Scene.tsx`, `effect.types.ts`  
**Root Cause:** Three.js type mismatches and deprecated imports

**Template Fixes Required:**

- `templates/domains/effect/types/effect.types.ts.template` - Remove deprecated Geometry import
- `templates/components/r3f/ParticleSystem.tsx.template` - Fix Material ref typing

**Actions:**

```typescript
// Fix effect.types.ts.template
// Remove: import { Geometry } from 'three'
// Replace with: import { BufferGeometry } from 'three'
```

---

### **PHASE 4: LOGGER & UTILITY FIXES**

#### **4.1 Fix Logger Method Calls (8 errors)**

**Files:** Multiple service files  
**Root Cause:** Services calling `logger.success()` which doesn't exist on Winston logger

**Template Fixes Required:**

- `templates/shared/lib/logger.ts.template` - Add success method or change calls to info
- All service templates - Update logger calls

**Script Updates:**

- `scripts/18a-SetupLoggingService.ps1` - Ensure logger interface consistency

**Actions:**

```typescript
// Fix logger.ts.template - Add success method
export interface Logger {
  debug(message: string, meta?: any): void
  info(message: string, meta?: any): void
  warn(message: string, meta?: any): void
  error(message: string, meta?: any): void
  success(message: string, meta?: any): void // Add this method
}

// Or update all service templates to use logger.info instead of logger.success
```

---

## 🛠 **IMPLEMENTATION SCRIPT SEQUENCE**

### **Step 1: Update Templates**

```powershell
# Run these scripts to update templates with fixes
scripts/19-ConfigureAdvancedTypeScript.ps1 -Enhanced
scripts/18a-SetupLoggingService.ps1 -FixLoggerInterface
scripts/33a-GenerateStores.ps1 -ExportTypes
scripts/29a-SetupOpenTelemetry.ps1 -AddMissingTypes
```

### **Step 2: Regenerate Services**

```powershell
# Regenerate services with fixed templates
scripts/31-GenerateParticleService.ps1 -AddMissingMethods
scripts/27-GenerateTraitService.ps1 -AddDependencyInjection
scripts/35-GenerateRenderingService.ps1 -FixExports
```

### **Step 3: Regenerate Components**

```powershell
# Regenerate components with fixed interfaces
scripts/52-SetupReactIntegration.ps1 -FixTypeInterfaces
scripts/41a-SetupR3FIntegration.ps1 -EnhanceThreeJsTypes
scripts/59-GenerateMainEntryPoint.ps1 -FixReactImports
```

### **Step 4: Validation**

```powershell
# Validate all fixes
scripts/57-FixCriticalTypeScriptIssues.ps1 -ComprehensiveValidation
npm run type-check
```

---

## 🎯 **SUCCESS METRICS**

**Target:** 0 TypeScript errors  
**Current:** 76 errors across 16 files  
**Expected Reduction Per Phase:**

- Phase 1: -30 errors (React + Store fixes)
- Phase 2: -26 errors (Dependencies + Service methods)
- Phase 3: -18 errors (Components + Three.js)
- Phase 4: -2 errors (Logger cleanup)

---

## 📝 **TEMPLATE FILES TO UPDATE**

### **Critical Templates:**

1. `templates/tsconfig.json.template`
2. `templates/src/main.tsx.template`
3. `templates/shared/state/useSimulationStore.ts.template`
4. `templates/shared/state/useParticleStore.ts.template`
5. `templates/shared/lib/logger.ts.template`
6. `templates/domains/particle/services/ParticleService.ts.template`
7. `templates/components/r3f/ParticleSystem.tsx.template`
8. `templates/domains/effect/types/effect.types.ts.template`

### **Scripts to Enhance:**

1. `scripts/19-ConfigureAdvancedTypeScript.ps1`
2. `scripts/33a-GenerateStores.ps1`
3. `scripts/29a-SetupOpenTelemetry.ps1`
4. `scripts/31-GenerateParticleService.ps1`
5. `scripts/52-SetupReactIntegration.ps1`

---

## ✅ **VALIDATION CHECKLIST**

- [ ] React 18 types properly configured
- [ ] All store interfaces exported correctly
- [ ] OpenTelemetry dependencies resolved
- [ ] Service methods match component expectations
- [ ] Three.js types align with R3F usage
- [ ] Logger interface consistent across services
- [ ] All imports/exports resolve correctly
- [ ] `npm run type-check` passes with 0 errors

---

**Next Action:** Execute Phase 1 template fixes and test TypeScript compilation
