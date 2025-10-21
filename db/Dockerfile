# 使用更小的PostgreSQL镜像
FROM postgres:12-alpine

# 复制初始化SQL脚本
COPY words.sql /docker-entrypoint-initdb.d/

# 设置环境变量
ENV POSTGRES_HOST_AUTH_METHOD=trust

# 暴露端口5432
EXPOSE 5432
