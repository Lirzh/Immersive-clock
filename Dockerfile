# 预定义各架构的运行时镜像
FROM node:24-alpine AS builder-amd64
FROM node:24-alpine AS builder-arm64
FROM node:20-alpine AS builder-arm
FROM node:24-trixie-slim AS builder-s390x
FROM node:24-trixie-slim AS builder-ppc64le
# FROM ghcr.io/lirzh/nodejs-docker-image:386 AS builder-386
# FROM ghcr.io/lirzh/nodejs-docker-image:riscv64 AS builder-riscv64

# 根据 TARGETARCH 选择对应的构建时镜像
FROM builder-${TARGETARCH} AS builder

# Set working directory
WORKDIR /app

# Copy package files first for better caching
COPY package.json package-lock.json* ./

# Install dependencies
RUN npm ci || npm install

# Copy source code
COPY . .

# Build the application
RUN npm run build

# Stage 2: Serve with nginx
FROM nginx:alpine

# Copy built assets from builder
COPY --from=builder /app/dist /usr/share/nginx/html

# Copy nginx configuration
RUN rm /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
