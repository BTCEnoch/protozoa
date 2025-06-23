/**
 * @fileoverview IPersistenceService Interface
 * @description Service contract for data persistence operations
 * @author Protozoa Development Team
 * @version 1.0.0
 */

/**
 * Storage operation result interface
 */
export interface StorageResult<T = any> {
  success: boolean;
  data?: T;
  error?: string;
}

/**
 * Persistence service interface for data storage operations
 * Provides abstraction layer over localStorage and IndexedDB
 */
export interface IPersistenceService {
  /**
   * Save data to storage with specified key
   * @param key - Storage key identifier
   * @param value - Data to store
   * @returns Promise resolving to storage result
   */
  save<T>(key: string, value: T): Promise<StorageResult<T>>;

  /**
   * Load data from storage by key
   * @param key - Storage key identifier
   * @returns Promise resolving to storage result with data
   */
  load<T = any>(key: string): Promise<StorageResult<T>>;

  /**
   * Remove data from storage by key
   * @param key - Storage key identifier
   * @returns Promise resolving to storage result
   */
  remove(key: string): Promise<StorageResult<boolean>>;

  /**
   * Clear all stored data
   * @returns Promise resolving to storage result
   */
  clear(): Promise<StorageResult<boolean>>;

  /**
   * Get storage statistics and usage information
   * @returns Promise resolving to storage statistics
   */
  getStats(): Promise<{
    localStorageUsed: number;
    indexedDBSupported: boolean;
    indexedDBConnected: boolean;
  }>;

  /**
   * Dispose of service resources
   */
  dispose(): void;
} 
