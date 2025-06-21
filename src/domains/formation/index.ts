/**
 * @fileoverview Formation Domain Exports
 * @module @/domains/formation
 * @version 1.0.0
 */

// Service exports
export { FormationService } from "./services/FormationService";
export { formationService } from "./services/FormationService";

// Interface exports
export type { IFormationService, IFormationPattern, IFormationConfig, IFormationResult } from "./interfaces/IFormationService";

// Data exports
export { FormationGeometry } from "./data/formationGeometry";
export { FormationPatterns } from "./data/formationPatterns";

// Type exports
export type * from "./types/IFormationService";
