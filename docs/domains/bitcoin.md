# Bitcoin Domain

Fetches block information and ordinals content from external APIs with caching and retry logic.

## Interface
```ts
export interface IBitcoinService {
  fetchBlockInfo(blockNumber: number): Promise<BlockInfo>;
  getCachedBlockInfo(blockNumber: number): BlockInfo | undefined;
  dispose(): void;
}
```

Example fetch using the dev API:
```ts
const url = `https://ordinals.com/r/blockinfo/${blockNumber}`;
const data = await (await fetch(url)).json();
```

Cached results are stored in a map keyed by block number. `dispose` clears the cache to free memory.
