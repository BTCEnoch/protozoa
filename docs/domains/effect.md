# Effect Domain

Manages visual effects such as nebula clouds or explosions. The service stores predefined effect presets and allows triggering them at runtime.

## Interface
```ts
export interface IEffectService {
  triggerEffect(name: string, options?: any): void;
  registerEffectPreset(name: string, config: EffectConfig): void;
  dispose(): void;
}
```

Use `triggerEffect` to start an effect by name. Presets can be registered via `registerEffectPreset`. Errors are logged with `createErrorLogger` if a preset is missing.
