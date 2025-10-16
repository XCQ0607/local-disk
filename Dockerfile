# 第一阶段：构建阶段
FROM node:18-alpine AS builder

# 设置工作目录
WORKDIR /app

# 复制package.json和package-lock.json
COPY package*.json ./

# 安装所有依赖（包括开发依赖）
RUN npm ci

# 复制项目源代码
COPY . .

# 编译TypeScript代码
RUN npm run build

# 第二阶段：生产阶段
FROM node:18-alpine

# 设置工作目录
WORKDIR /app

# 复制package.json和package-lock.json
COPY package*.json ./

# 只安装生产依赖
RUN npm ci --only=production

# 从构建阶段复制编译后的文件
COPY --from=builder /app/js ./js
COPY --from=builder /app/public ./public

# 暴露项目运行的3000端口
EXPOSE 3000

# 启动应用
CMD ["node", "js/src/app.js"]
