# 构建阶段
FROM node:18-alpine AS builder

# 设置工作目录
WORKDIR /app

# 复制依赖文件
COPY package.json yarn.lock ./

# 安装所有依赖（包括开发依赖）
RUN yarn install --frozen-lockfile

# 复制项目源代码
COPY . .

# 执行构建命令（编译TypeScript和前端资源）
RUN yarn run build


# 运行阶段
FROM node:18-alpine

# 设置工作目录
WORKDIR /app

# 复制依赖文件
COPY package.json yarn.lock ./

# 仅安装生产依赖
RUN yarn install --production

# 从构建阶段复制编译结果
COPY --from=builder /app/js ./js
COPY --from=builder /app/public ./public

# 创建数据库文件并设置权限
RUN touch filelist.db && \
    chmod 666 filelist.db && \
    # 确保工作目录和子目录权限正确
    chmod -R 755 /app && \
    chmod -R 777 /app/public

# 暴露应用端口
EXPOSE 3000

# 启动命令
CMD ["node", "js/src/app.js"]
