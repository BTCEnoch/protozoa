# Phase 0 Restructure: npm-Only Consolidation Plan

## 🎯 **OBJECTIVE**

Convert the entire Protozoa automation suite from inconsistent pnpm/npm usage to a unified, reliable npm-only approach that aligns with our React/Vite/THREE.js technology stack.

## 📋 **COMPLETE ACTION CHECKLIST**

### 🗑️ **PHASE 0 SCRIPTS TO DELETE**

- [ ] `00-InitEnvironment.ps1` - Replace with npm-only version (394 lines, 18KB)
- [ ] `00c-UnifiedDependencyManagement.ps1` - Replace with npm-only version (433 lines, 16KB)
- [ ] `00d-AuditPackageJsonModifications.ps1` - Replace with npm-only version (306 lines, 11KB)
- [ ] `00e-InstallMonitor.ps1` - Replace with npm-only version (279 lines, 11KB)
- [ ] `00a-InstallDependenciesWithProgress.ps1` - Legacy pnpm script (10KB)

**Total Deletion:** ~5 scripts, ~66KB of pnpm-contaminated code

### ✅ **NEW PHASE 0 SCRIPTS TO CREATE**

- [ ] `00-NpmEnvironmentSetup.ps1` - Pure npm environment initialization
  - Node.js LTS installation via winget
  - npm verification and update
  - Global npm configuration
  - Environment validation
- [ ] `00a-NpmInstallWithProgress.ps1` - npm-only installation with enhanced monitoring
  - Real-time progress tracking
  - Stall detection and recovery
  - Network connectivity validation
  - Disk space monitoring
  - Comprehensive error handling
- [ ] `00b-ValidateNpmEnvironment.ps1` - npm environment validation
  - Node.js version validation
  - npm configuration verification
  - Package.json integrity checks
  - Lock file consistency validation
- [ ] `00c-CleanupLegacyPackageManagers.ps1` - Remove pnpm/yarn traces
  - Remove pnpm-lock.yaml files
  - Remove yarn.lock files
  - Clean global pnpm installations
  - Update .gitignore for npm-only

**Total Creation:** ~4 scripts, estimated ~50KB of clean npm-only code

### 🔧 **OTHER PHASE SCRIPTS TO MODIFY**

#### **Phase 0 (Foundation)**

- [ ] `01-ScaffoldProjectStructure.ps1` - Update to create npm-only structure
- [ ] `03-MoveAndCleanCodebase.ps1` - Remove pnpm legacy references
- [ ] `08-DeployToGitHub.ps1` - Update .gitignore to npm-only
- [ ] `20-SetupPreCommitValidation.ps1` - Remove pnpm fallback logic (243 lines)

#### **Phase 1 (Shared Infrastructure)**

- [ ] `07-BuildAndTest.ps1` - Replace `pnpm exec` with `npm exec` (117 lines)
- [ ] `06-DomainLint.ps1` - Replace `pnpm exec eslint` with `npm exec eslint`
- [ ] `15-ValidateSetupComplete.ps1` - Update instructions from pnpm to npm
- [ ] `29a-SetupOpenTelemetry.ps1` - Remove pnpm detection logic (490 lines)

#### **Phase 6 (Advanced Tooling)**

- [ ] `48-SetupAdvancedBundleAnalysis.ps1` - Update CI workflows to use npm
- [ ] `54-SetupPerformanceTesting.ps1` - Update CI workflows to use npm

#### **Phase 8 (TypeScript Fixes)**

- [ ] `58-RegenerateProjectConfig.ps1` - Update instructions to npm

**Total Modifications:** ~10 scripts across multiple phases

### 📄 **TEMPLATES TO CREATE/MODIFY**

#### **New Templates**

- [ ] `templates/.npmrc.template` - npm configuration template

  - Registry configuration
  - Cache settings
  - Security settings
  - Performance optimizations

- [ ] `templates/package.json.template` - Enhanced npm-only package.json

  - packageManager field set to npm
  - All required dependencies
  - Proper scripts section
  - Engine requirements

- [ ] `templates/.gitignore.template` - npm-only gitignore
  - Exclude pnpm-lock.yaml
  - Exclude yarn.lock
  - Include package-lock.json
  - Standard Node.js ignores

#### **Templates to Modify**

- [ ] `templates/.github/workflows/*.template` - Update all CI workflows to use npm
- [ ] `templates/README.md.template` - Update installation instructions to npm
- [ ] `templates/Dockerfile.template` - Update to use npm instead of pnpm

### 🔄 **RUNALL.PS1 PHASE 0 SEQUENCE UPDATE**

#### **Current Phase 0 (13 Scripts)**

```powershell
# === PHASE 0: ENVIRONMENT & FOUNDATION (13 Scripts) ===
@{ Phase = 0; Script = "00-InitEnvironment.ps1"; Description = "Node.js, pnpm, base environment" },
@{ Phase = 0; Script = "00c-UnifiedDependencyManagement.ps1"; Description = "Unified npm dependency management and package.json protection" },
@{ Phase = 0; Script = "00e-InstallMonitor.ps1"; Description = "Enhanced dependency installation monitor with stall detection (utility script)" },
# ... 10 more scripts
```

#### **New Phase 0 (12 Scripts - Streamlined)**

```powershell
# === PHASE 0: ENVIRONMENT & FOUNDATION (12 Scripts) ===
@{ Phase = 0; Script = "00-NpmEnvironmentSetup.ps1"; Description = "Node.js and npm-only environment setup" },
@{ Phase = 0; Script = "00a-NpmInstallWithProgress.ps1"; Description = "npm installation with enhanced monitoring and stall detection" },
@{ Phase = 0; Script = "00b-ValidateNpmEnvironment.ps1"; Description = "npm environment and package integrity validation" },
@{ Phase = 0; Script = "00c-CleanupLegacyPackageManagers.ps1"; Description = "Remove pnpm/yarn traces and ensure npm-only approach" },
# ... 8 remaining scripts (updated)
```

### 🎯 **BUILD GOALS ALIGNMENT VERIFICATION**

#### **✅ Maintained Goals**

- [ ] **Bitcoin Ordinals Integration** - No impact on blockchain functionality
- [ ] **Domain-Driven Architecture** - Enhanced consistency across domains
- [ ] **Template-First Approach** - Strengthened with npm-only templates
- [ ] **Performance Optimization** - Improved reliability and predictability
- [ ] **Enterprise-Grade Quality** - Enhanced through consistency

#### **✅ Enhanced Goals**

- [ ] **Package Manager Consistency** - Single npm approach eliminates conflicts
- [ ] **CI/CD Reliability** - npm works consistently across all environments
- [ ] **Developer Experience** - Simplified tooling and troubleshooting
- [ ] **Corporate Compatibility** - npm is universally supported

### 🚨 **POTENTIAL CONFLICT ANALYSIS**

#### **Scripts with pnpm References (Requiring Updates)**

1. `00a-InstallDependenciesWithProgress.ps1` - 17 pnpm references
2. `20-SetupPreCommitValidation.ps1` - 8 pnpm references
3. `00-InitEnvironment.ps1` - 25 pnpm references
4. `07-BuildAndTest.ps1` - 4 pnpm references
5. `06-DomainLint.ps1` - 2 pnpm references
6. `29a-SetupOpenTelemetry.ps1` - 3 pnpm references
7. `48-SetupAdvancedBundleAnalysis.ps1` - 3 pnpm references
8. `54-SetupPerformanceTesting.ps1` - 3 pnpm references

#### **Templates with pnpm References**

- [ ] CI/CD workflow templates
- [ ] Documentation templates
- [ ] Docker templates

### 📊 **IMPLEMENTATION PHASES**

#### **Phase A: Foundation Replacement (Chunk 1)**

- [ ] Create `00-NpmEnvironmentSetup.ps1`
- [ ] Create `00a-NpmInstallWithProgress.ps1`
- [ ] Create `00b-ValidateNpmEnvironment.ps1`
- [ ] Create `00c-CleanupLegacyPackageManagers.ps1`

#### **Phase B: Template Creation (Chunk 2)**

- [ ] Create `templates/.npmrc.template`
- [ ] Update `templates/package.json.template`
- [ ] Create `templates/.gitignore.template`
- [ ] Update CI/CD templates

#### **Phase C: Script Modifications (Chunk 3)**

- [ ] Update all Phase 0 scripts with pnpm references
- [ ] Update cross-phase scripts with pnpm references
- [ ] Update runAll.ps1 sequence

#### **Phase D: Legacy Cleanup (Chunk 4)**

- [ ] Delete old pnpm-based scripts
- [ ] Validate all pnpm references removed
- [ ] Test complete npm-only pipeline

#### **Phase E: Documentation & Validation (Chunk 5)**

- [ ] Update INSTALLATION-MONITORING-GUIDE.md
- [ ] Update README.md
- [ ] Run complete automation pipeline test
- [ ] Verify npm-only approach works end-to-end

### 🎉 **SUCCESS CRITERIA**

#### **Technical Validation**

- [ ] Zero pnpm references in any script
- [ ] All scripts use `npm exec` instead of `pnpm exec`
- [ ] Only package-lock.json exists (no pnpm-lock.yaml)
- [ ] All CI workflows use npm
- [ ] Complete automation pipeline runs successfully

#### **Functional Validation**

- [ ] `npm install` works reliably with progress monitoring
- [ ] `npm run dev` starts development server
- [ ] `npm run build` creates production build
- [ ] `npm test` runs test suite
- [ ] All domain services function correctly

#### **Quality Validation**

- [ ] Installation time improved (no pnpm overhead)
- [ ] Fewer package manager conflicts
- [ ] Simplified troubleshooting
- [ ] Better corporate environment compatibility
- [ ] Enhanced developer experience

### 📝 **EXECUTION NOTES**

#### **Why npm Over pnpm for Protozoa**

1. **React/Vite Compatibility** - Our stack expects npm's flat node_modules
2. **THREE.js Ecosystem** - Graphics libraries work better with npm structure
3. **Corporate Environments** - npm is universally supported
4. **Tooling Integration** - VS Code, TypeScript, bundlers expect npm
5. **Debugging Simplicity** - Standard structure is easier to troubleshoot
6. **Lock File Consistency** - Single package-lock.json approach

#### **Risk Mitigation**

- All changes will be made incrementally in manageable chunks
- Each chunk will be tested before proceeding to the next
- Original scripts will be backed up before deletion
- Complete rollback plan available if issues arise

---

**🎯 RESULT:** A unified, reliable npm-only automation suite that eliminates package manager inconsistencies and provides better compatibility with our React/Vite/THREE.js technology stack.
