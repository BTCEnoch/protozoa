// src/domains/formation/services/FormationService.ts
// FormationService implementation - Auto-generated stub
// Referenced from build_design.md Section 4

import { IFormationService } from '../types';
import { createServiceLogger } from '@/shared/lib/logger';

/**
 * FormationService – manages formation domain operations.
 * Auto-generated stub following .cursorrules singleton pattern.
 * TODO: Implement actual logic in Phase 4.
 */
class FormationService implements IFormationService {
  static #instance: FormationService | null = null;
  #log = createServiceLogger('FORMATION_SERVICE');

  /**
   * Private constructor enforces singleton pattern.
   */
  private constructor() {
    this.#log.info('FormationService initialized');
  }

  /**
   * Singleton accessor - returns existing instance or creates new one.
   */
  public static getInstance(): FormationService {
    if (!FormationService.#instance) {
      FormationService.#instance = new FormationService();
    }
    return FormationService.#instance;
  }

  // TODO: Implement interface methods here

  /**
   * Disposes of service resources and resets singleton instance.
   */
  public dispose(): void {
    this.#log.info('FormationService disposed');
    FormationService.#instance = null;
  }
}

// Singleton export as required by .cursorrules
export const formationService = FormationService.getInstance();
