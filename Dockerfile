# Stage 1: build
FROM node:20-alpine as builder
WORKDIR /app
COPY . .
RUN npm ci && npm run build

# Stage 2: runtime
FROM node:20-alpine
WORKDIR /app
ENV NODE_ENV=production
COPY --from=builder /app/dist ./dist
COPY package.json package-lock.json ./
RUN npm ci --only=production
CMD ["node","dist/index.js"]
