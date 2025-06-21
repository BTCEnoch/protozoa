/**
 * @fileoverview EventBus Service Implementation
 * @description High-performance event bus for cross-domain communication
 * @author Protozoa Development Team
 * @version 1.0.0
 */

import {
  IEventBus,
  IBaseEvent,
  EventHandler,
  DomainEvent
} from "@/shared/types/eventTypes";
import { createServiceLogger } from "@/shared/lib/logger";

/**
 * EventBus Service implementing domain event communication
 * Uses Map-based storage for high performance event handling
 * Follows singleton pattern for application-wide consistency
 */
export class EventBus implements IEventBus {
  private static instance: EventBus;
  private readonly logger = createServiceLogger('EventBus');
  private readonly eventHandlers = new Map<string, Set<EventHandler>>();
  private readonly eventHistory: IBaseEvent[] = [];
  private readonly maxHistorySize = 1000;

  /**
   * Private constructor enforcing singleton pattern
   */
  private constructor() {
    this.logger.info('EventBus initialized');
  }

  /**
   * Get the singleton instance of EventBus
   */
  public static getInstance(): EventBus {
    if (!EventBus.instance) {
      EventBus.instance = new EventBus();
    }
    return EventBus.instance;
  }

  /**
   * Subscribe to events of a specific type
   */
  public subscribe<T extends IBaseEvent>(
    eventType: string,
    handler: EventHandler<T>
  ): void {
    try {
      if (!this.eventHandlers.has(eventType)) {
        this.eventHandlers.set(eventType, new Set());
      }
      
      this.eventHandlers.get(eventType)!.add(handler as EventHandler);
      
      this.logger.debug(`Subscribed to event type: ${eventType}`, {
        totalHandlers: this.eventHandlers.get(eventType)!.size
      });
    } catch (error) {
      this.logger.error(`Failed to subscribe to event type: ${eventType}`, error);
      throw error;
    }
  }

  /**
   * Unsubscribe from events of a specific type
   */
  public unsubscribe<T extends IBaseEvent>(
    eventType: string,
    handler: EventHandler<T>
  ): void {
    try {
      const handlers = this.eventHandlers.get(eventType);
      if (handlers) {
        handlers.delete(handler as EventHandler);
        
        if (handlers.size === 0) {
          this.eventHandlers.delete(eventType);
        }
        
        this.logger.debug(`Unsubscribed from event type: ${eventType}`, {
          remainingHandlers: handlers.size
        });
      }
    } catch (error) {
      this.logger.error(`Failed to unsubscribe from event type: ${eventType}`, error);
      throw error;
    }
  }

  /**
   * Emit an event to all subscribed handlers
   */
  public async emit<T extends IBaseEvent>(event: T): Promise<void> {
    try {
      const startTime = performance.now();
      
      // Add to event history
      this.addToHistory(event);
      
      const handlers = this.eventHandlers.get(event.type);
      if (!handlers || handlers.size === 0) {
        this.logger.debug(`No handlers for event type: ${event.type}`);
        return;
      }

      // Execute all handlers concurrently
      const handlerPromises = Array.from(handlers).map(async (handler) => {
        try {
          await handler(event);
        } catch (error) {
          this.logger.error(`Event handler failed for type: ${event.type}`, error, {
            eventId: event.correlationId,
            source: event.source
          });
        }
      });

      await Promise.all(handlerPromises);
      
      const duration = performance.now() - startTime;
      this.logger.info(`Event emitted successfully: ${event.type}`, {
        duration: Math.round(duration * 100) / 100,
        handlerCount: handlers.size,
        source: event.source,
        correlationId: event.correlationId
      });
      
    } catch (error) {
      this.logger.error(`Failed to emit event: ${event.type}`, error);
      throw error;
    }
  }

  /**
   * Remove all event listeners
   */
  public removeAllListeners(): void {
    try {
      const totalHandlers = Array.from(this.eventHandlers.values())
        .reduce((sum, handlers) => sum + handlers.size, 0);
      
      this.eventHandlers.clear();
      
      this.logger.info(`All event listeners removed`, {
        totalHandlersRemoved: totalHandlers
      });
    } catch (error) {
      this.logger.error('Failed to remove all listeners', error);
      throw error;
    }
  }

  /**
   * Get event statistics
   */
  public getStats(): {
    totalEventTypes: number;
    totalHandlers: number;
    historySize: number;
  } {
    const totalHandlers = Array.from(this.eventHandlers.values())
      .reduce((sum, handlers) => sum + handlers.size, 0);
    
    return {
      totalEventTypes: this.eventHandlers.size,
      totalHandlers,
      historySize: this.eventHistory.length
    };
  }

  /**
   * Get recent event history
   */
  public getRecentEvents(limit: number = 10): IBaseEvent[] {
    return this.eventHistory.slice(-limit);
  }

  /**
   * Add event to history with size management
   */
  private addToHistory(event: IBaseEvent): void {
    this.eventHistory.push(event);
    
    // Trim history if it exceeds maximum size
    if (this.eventHistory.length > this.maxHistorySize) {
      this.eventHistory.splice(0, this.eventHistory.length - this.maxHistorySize);
    }
  }

  /**
   * Dispose of resources
   */
  public dispose(): void {
    this.removeAllListeners();
    this.eventHistory.length = 0;
    this.logger.info('EventBus disposed');
  }
}

// Export factory function for consistency
export function createEventBus(): EventBus {
  return EventBus.getInstance();
} 
