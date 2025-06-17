# Trait Domain

Generates and mutates organism traits using deterministic randomness. Traits can be seeded from Bitcoin block data.

## Interface
```ts
export interface ITraitService {
  generateTraitsForOrganism(id: string, blockNonce?: number): OrganismTraits;
  mutateTrait(traitType: string, currentValue: any): any;
  applyTraitsToOrganism(organismId: string, traits: OrganismTraits): void;
  dispose(): void;
}
```

`generateTraitsForOrganism` creates a full trait map, optionally using a block nonce as a seed. `mutateTrait` produces a new trait value ensuring variation from the current value. Logging reports trait assignments and mutations.
