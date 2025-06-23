/**
 * @fileoverview PersistenceService Implementation
 * @description Multi-layer persistence service with localStorage and IndexedDB support
 * @author Protozoa Development Team  
 * @version 1.0.0
 */

import { IPersistenceService } from "@/shared/interfaces/IPersistenceService";
import { createServiceLogger } from "@/shared/lib/logger";

/**
 * Storage operation result interface
 */
interface StorageResult<T = any> {
  success: boolean;
  data?: T;
  error?: string;
}

/**
 * Storage configuration interface
 */
interface StorageConfig {
  useIndexedDB: boolean;
  dbName: string;
  dbVersion: number;
  fallbackToLocalStorage: boolean;
}

/**
 * PersistenceService implementing multi-layer data persistence
 * Supports both localStorage and IndexedDB with intelligent fallback
 * Follows singleton pattern for application-wide consistency
 */
export class PersistenceService implements IPersistenceService {
  private static instance: PersistenceService;
  private readonly logger = createServiceLogger('PersistenceService');
  private db: IDBDatabase | null = null;
  private readonly config: StorageConfig;
  private initializationPromise: Promise<void> | null = null;

  /**
   * Private constructor enforcing singleton pattern
   */
  private constructor(config: Partial<StorageConfig> = {}) {
    this.config = {
      useIndexedDB: true,
      dbName: 'ProtozooaDB',
      dbVersion: 1,
      fallbackToLocalStorage: true,
      ...config
    };
    
    this.logger.info('PersistenceService initialized', this.config);
    this.initializationPromise = this.initializeStorage();
  }

  /**
   * Get the singleton instance of PersistenceService
   */
  public static getInstance(config?: Partial<StorageConfig>): PersistenceService {
    if (!PersistenceService.instance) {
      PersistenceService.instance = new PersistenceService(config);
    }
    return PersistenceService.instance;
  }

  /**
   * Initialize storage systems
   */
  private async initializeStorage(): Promise<void> {
    if (this.config.useIndexedDB && this.isIndexedDBSupported()) {
      try {
        await this.initializeIndexedDB();
        this.logger.info('IndexedDB initialized successfully');
      } catch (error) {
        this.logger.warn('IndexedDB initialization failed, falling back to localStorage', error);
        if (!this.config.fallbackToLocalStorage) {
          throw error;
        }
      }
    }
  }

  /**
   * Check if IndexedDB is supported
   */
  private isIndexedDBSupported(): boolean {
    return typeof window !== 'undefined' && 'indexedDB' in window;
  }

  /**
   * Initialize IndexedDB connection
   */
  private async initializeIndexedDB(): Promise<void> {
    return new Promise((resolve, reject) => {
      const request = indexedDB.open(this.config.dbName, this.config.dbVersion);
      
      request.onerror = () => {
        reject(new Error(`IndexedDB open failed: ${request.error?.message}`));
      };

      request.onsuccess = () => {
        this.db = request.result;
        resolve();
      };

      request.onupgradeneeded = (event) => {
        const db = (event.target as IDBOpenDBRequest).result;
        
        // Create object store for general data
        if (!db.objectStoreNames.contains('data')) {
          db.createObjectStore('data', { keyPath: 'key' });
        }
        
        // Create object store for large objects
        if (!db.objectStoreNames.contains('largeData')) {
          db.createObjectStore('largeData', { keyPath: 'key' });
        }
      };
    });
  }

  /**
   * Save data to storage
   */
  public async save<T>(key: string, value: T): Promise<StorageResult<T>> {
    try {
      await this.ensureInitialized();
      
      const serializedValue = this.serialize(value);
      const dataSize = new Blob([serializedValue]).size;
      
      // Use IndexedDB for large data or if configured
      if (this.db && (dataSize > 5000 || this.config.useIndexedDB)) {
        return await this.saveToIndexedDB(key, value, dataSize > 50000);
      }
      
      // Fallback to localStorage
      return this.saveToLocalStorage(key, serializedValue);
      
    } catch (error) {
      this.logger.error(`Failed to save data for key: ${key}`, error);
      return { success: false, error: error instanceof Error ? error.message : 'Unknown error' };
    }
  }

  /**
   * Load data from storage
   */
  public async load<T = any>(key: string): Promise<StorageResult<T>> {
    try {
      await this.ensureInitialized();
      
      // Try IndexedDB first if available
      if (this.db) {
        const result = await this.loadFromIndexedDB<T>(key);
        if (result.success) {
          return result;
        }
      }
      
      // Fallback to localStorage
      return this.loadFromLocalStorage<T>(key);
      
    } catch (error) {
      this.logger.error(`Failed to load data for key: ${key}`, error);
      return { success: false, error: error instanceof Error ? error.message : 'Unknown error' };
    }
  }

  /**
   * Remove data from storage
   */
  public async remove(key: string): Promise<StorageResult<boolean>> {
    try {
      await this.ensureInitialized();
      
      let success = false;
      
      // Remove from IndexedDB if available
      if (this.db) {
        const idbResult = await this.removeFromIndexedDB(key);
        success = idbResult.success || success;
      }
      
      // Remove from localStorage
      const lsResult = this.removeFromLocalStorage(key);
      success = lsResult.success || success;
      
      return { success, data: success };
      
    } catch (error) {
      this.logger.error(`Failed to remove data for key: ${key}`, error);
      return { success: false, error: error instanceof Error ? error.message : 'Unknown error' };
    }
  }

  /**
   * Clear all stored data
   */
  public async clear(): Promise<StorageResult<boolean>> {
    try {
      await this.ensureInitialized();
      
      let success = false;
      
      // Clear IndexedDB if available
      if (this.db) {
        const idbResult = await this.clearIndexedDB();
        success = idbResult.success || success;
      }
      
      // Clear localStorage
      const lsResult = this.clearLocalStorage();
      success = lsResult.success || success;
      
      this.logger.info('Storage cleared successfully');
      return { success, data: success };
      
    } catch (error) {
      this.logger.error('Failed to clear storage', error);
      return { success: false, error: error instanceof Error ? error.message : 'Unknown error' };
    }
  }

  /**
   * Get storage statistics
   */
  public async getStats(): Promise<{
    localStorageUsed: number;
    indexedDBSupported: boolean;
    indexedDBConnected: boolean;
  }> {
    const stats = {
      localStorageUsed: this.getLocalStorageUsage(),
      indexedDBSupported: this.isIndexedDBSupported(),
      indexedDBConnected: this.db !== null
    };
    
    this.logger.debug('Storage statistics retrieved', stats);
    return stats;
  }

  /**
   * Ensure storage is initialized
   */
  private async ensureInitialized(): Promise<void> {
    if (this.initializationPromise) {
      await this.initializationPromise;
      this.initializationPromise = null;
    }
  }

  /**
   * Serialize data for storage
   */
  private serialize<T>(data: T): string {
    return JSON.stringify(data);
  }

  /**
   * Deserialize data from storage
   */
  private deserialize<T>(data: string): T {
    return JSON.parse(data);
  }

  /**
   * Get localStorage usage in bytes
   */
  private getLocalStorageUsage(): number {
    let total = 0;
    for (const key in localStorage) {
      if (localStorage.hasOwnProperty(key)) {
        total += localStorage.getItem(key)?.length || 0;
      }
    }
    return total;
  }

  /**
   * Save data to IndexedDB
   */
  private async saveToIndexedDB<T>(key: string, value: T, useLargeStore: boolean = false): Promise<StorageResult<T>> {
    if (!this.db) {
      return { success: false, error: 'IndexedDB not available' }
    }

    try {
      const transaction = this.db.transaction([useLargeStore ? 'largeData' : 'data'], 'readwrite')
      const store = transaction.objectStore(useLargeStore ? 'largeData' : 'data')
      
      await new Promise<void>((resolve, reject) => {
        const request = store.put({ key, value, timestamp: Date.now() })
        request.onsuccess = () => resolve()
        request.onerror = () => reject(request.error)
      })

      return { success: true, data: value }
    } catch (error) {
      return { success: false, error: error instanceof Error ? error.message : 'Unknown error' }
    }
  }

  /**
   * Save data to localStorage
   */
  private saveToLocalStorage<T>(key: string, serializedValue: string): StorageResult<T> {
    try {
      localStorage.setItem(key, serializedValue)
      return { success: true }
    } catch (error) {
      return { success: false, error: error instanceof Error ? error.message : 'Unknown error' }
    }
  }

  /**
   * Load data from IndexedDB
   */
  private async loadFromIndexedDB<T>(key: string): Promise<StorageResult<T>> {
    if (!this.db) {
      return { success: false, error: 'IndexedDB not available' }
    }

    try {
      const transaction = this.db.transaction(['data', 'largeData'], 'readonly')
      
      // Try regular store first
      let store = transaction.objectStore('data')
      let result = await new Promise<any>((resolve, reject) => {
        const request = store.get(key)
        request.onsuccess = () => resolve(request.result)
        request.onerror = () => reject(request.error)
      })

      // If not found, try large data store
      if (!result) {
        store = transaction.objectStore('largeData')
        result = await new Promise<any>((resolve, reject) => {
          const request = store.get(key)
          request.onsuccess = () => resolve(request.result)
          request.onerror = () => reject(request.error)
        })
      }

      if (result) {
        return { success: true, data: result.value }
      } else {
        return { success: false, error: 'Key not found' }
      }
    } catch (error) {
      return { success: false, error: error instanceof Error ? error.message : 'Unknown error' }
    }
  }

  /**
   * Load data from localStorage
   */
  private loadFromLocalStorage<T>(key: string): StorageResult<T> {
    try {
      const item = localStorage.getItem(key)
      if (item === null) {
        return { success: false, error: 'Key not found' }
      }
      const data = this.deserialize<T>(item)
      return { success: true, data }
    } catch (error) {
      return { success: false, error: error instanceof Error ? error.message : 'Unknown error' }
    }
  }

  /**
   * Remove data from IndexedDB
   */
  private async removeFromIndexedDB(key: string): Promise<StorageResult<boolean>> {
    if (!this.db) {
      return { success: false, error: 'IndexedDB not available' }
    }

    try {
      const transaction = this.db.transaction(['data', 'largeData'], 'readwrite')
      
      // Remove from both stores
      const dataStore = transaction.objectStore('data')
      const largeDataStore = transaction.objectStore('largeData')
      
      await Promise.all([
        new Promise<void>((resolve, reject) => {
          const request = dataStore.delete(key)
          request.onsuccess = () => resolve()
          request.onerror = () => reject(request.error)
        }),
        new Promise<void>((resolve, reject) => {
          const request = largeDataStore.delete(key)
          request.onsuccess = () => resolve()
          request.onerror = () => reject(request.error)
        })
      ])

      return { success: true, data: true }
    } catch (error) {
      return { success: false, error: error instanceof Error ? error.message : 'Unknown error' }
    }
  }

  /**
   * Remove data from localStorage
   */
  private removeFromLocalStorage(key: string): StorageResult<boolean> {
    try {
      localStorage.removeItem(key)
      return { success: true, data: true }
    } catch (error) {
      return { success: false, error: error instanceof Error ? error.message : 'Unknown error' }
    }
  }

  /**
   * Clear all data from IndexedDB
   */
  private async clearIndexedDB(): Promise<StorageResult<boolean>> {
    if (!this.db) {
      return { success: false, error: 'IndexedDB not available' }
    }

    try {
      const transaction = this.db.transaction(['data', 'largeData'], 'readwrite')
      
      await Promise.all([
        new Promise<void>((resolve, reject) => {
          const request = transaction.objectStore('data').clear()
          request.onsuccess = () => resolve()
          request.onerror = () => reject(request.error)
        }),
        new Promise<void>((resolve, reject) => {
          const request = transaction.objectStore('largeData').clear()
          request.onsuccess = () => resolve()
          request.onerror = () => reject(request.error)
        })
      ])

      return { success: true, data: true }
    } catch (error) {
      return { success: false, error: error instanceof Error ? error.message : 'Unknown error' }
    }
  }

  /**
   * Clear all data from localStorage
   */
  private clearLocalStorage(): StorageResult<boolean> {
    try {
      localStorage.clear()
      return { success: true, data: true }
    } catch (error) {
      return { success: false, error: error instanceof Error ? error.message : 'Unknown error' }
    }
  }

  /**
   * Dispose of resources
   */
  public dispose(): void {
    if (this.db) {
      this.db.close();
      this.db = null;
    }
    this.logger.info('PersistenceService disposed');
  }
}

// Export factory function for consistency
export function createPersistenceService(config?: Partial<StorageConfig>): PersistenceService {
  return PersistenceService.getInstance(config);
} 
