import type { IPersistenceService } from '@/shared/interfaces/IPersistenceService';
import { createServiceLogger } from '@/shared/lib/logger';
import { DBSchema, openDB } from 'idb';

interface PersistDB extends DBSchema{ kv:{ key:string; value:any } }

class PersistenceService implements IPersistenceService{
 static #instance:PersistenceService|null=null
 #log=createServiceLogger('PERSISTENCE')
 #dbPromise = openDB<PersistDB>('protozoa-db',1,{upgrade(db){db.createObjectStore('kv')}})
 private constructor(){}
 static getInstance(){return this.#instance??(this.#instance=new PersistenceService())}
 async save(key:string,value:unknown){ const db=await this.#dbPromise; await db.put('kv',value,key); this.#log.info('saved',{key}) }
 async load<T=unknown>(key:string){ const db=await this.#dbPromise; return db.get('kv',key) as Promise<T|null> }
 dispose(){PersistenceService.#instance=null}
}
export const persistenceService=PersistenceService.getInstance()
