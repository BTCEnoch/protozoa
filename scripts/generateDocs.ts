import { spawnSync } from 'child_process'
console.log('Generating TypeDoc...')
spawnSync('npx', ['typedoc'], { stdio: 'inherit' })
