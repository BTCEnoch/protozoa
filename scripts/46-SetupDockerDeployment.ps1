# 46-SetupDockerDeployment.ps1 - Phase 7 Automation
# Generates Dockerfile, .dockerignore and GH Actions deploy workflow
# Reference: script_checklist.md lines 1410-1450
#Requires -Version 5.1

[CmdletBinding()]
param([string]$ProjectRoot=(Split-Path $PSScriptRoot -Parent))

try{Import-Module "$PSScriptRoot\utils.psm1" -Force -ErrorAction Stop}catch{Write-Error $_;exit 1}
$ErrorActionPreference='Stop'

try{
 Write-StepHeader "Docker Deployment Setup"
 # Dockerfile
 $docker=@'
# Stage 1: build
'@
FROM node:20-alpine as builder
WORKDIR /app
COPY . .
RUN corepack enable && pnpm install --frozen-lockfile && pnpm build

# Stage 2: runtime
FROM node:20-alpine
WORKDIR /app
ENV NODE_ENV=production
COPY --from=builder /app/dist ./dist
COPY package.json pnpm-lock.yaml ./
RUN corepack enable && pnpm install --prod --frozen-lockfile
CMD ["node","dist/index.js"]
'@
 Set-Content -Path (Join-Path $ProjectRoot 'Dockerfile') -Value $docker -Encoding UTF8
 # dockerignore
 $ignore=@'
node_modules
'@
.git
.github
scripts
src
*.md
'@
 Set-Content -Path (Join-Path $ProjectRoot '.dockerignore') -Value $ignore -Encoding UTF8

 # GH Actions workflow
 $wfPath=Join-Path $ProjectRoot '.github/workflows'
 New-Item -Path $wfPath -ItemType Directory -Force | Out-Null
 $deploy=@'
name: Docker Publish
'@
on:
  push:
    tags: ['v*']
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Build and push
        uses: docker/build-push-action@v5
        with:
          context: .
          push: true
          tags: myregistry/protozoa:
            \
              \
              \
              \
              \
              \
              ${{ github.ref_name }}
'@
 Set-Content -Path (Join-Path $wfPath 'docker-publish.yml') -Value $deploy -Encoding UTF8
 Write-SuccessLog "Docker deployment artifacts generated"
 exit 0
}catch{Write-ErrorLog "Docker setup failed: $($_.Exception.Message)";exit 1}
