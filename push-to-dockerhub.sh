#!/bin/bash

# Docker Hub用户名（请替换为你的用户名）
DOCKER_USERNAME="your-username"

# 版本标签
VERSION="v1.0.0"

echo "🐳 开始标记和推送Wordsmith镜像到Docker Hub..."

# 登录Docker Hub
echo "📝 登录Docker Hub..."
docker login

# Web服务
echo "🏷️  标记Web服务镜像..."
docker tag tp_wordsmith-web:latest $DOCKER_USERNAME/wordsmith-web:latest
docker tag tp_wordsmith-web:latest $DOCKER_USERNAME/wordsmith-web:$VERSION
docker tag tp_wordsmith-web:latest $DOCKER_USERNAME/wordsmith-web:dev

echo "📤 推送Web服务镜像..."
docker push $DOCKER_USERNAME/wordsmith-web:latest
docker push $DOCKER_USERNAME/wordsmith-web:$VERSION
docker push $DOCKER_USERNAME/wordsmith-web:dev

# Words服务
echo "🏷️  标记Words服务镜像..."
docker tag tp_wordsmith-words:latest $DOCKER_USERNAME/wordsmith-words:latest
docker tag tp_wordsmith-words:latest $DOCKER_USERNAME/wordsmith-words:$VERSION
docker tag tp_wordsmith-words:latest $DOCKER_USERNAME/wordsmith-words:dev

echo "📤 推送Words服务镜像..."
docker push $DOCKER_USERNAME/wordsmith-words:latest
docker push $DOCKER_USERNAME/wordsmith-words:$VERSION
docker push $DOCKER_USERNAME/wordsmith-words:dev

# DB服务
echo "🏷️  标记DB服务镜像..."
docker tag tp_wordsmith-db:latest $DOCKER_USERNAME/wordsmith-db:latest
docker tag tp_wordsmith-db:latest $DOCKER_USERNAME/wordsmith-db:$VERSION
docker tag tp_wordsmith-db:latest $DOCKER_USERNAME/wordsmith-db:dev

echo "📤 推送DB服务镜像..."
docker push $DOCKER_USERNAME/wordsmith-db:latest
docker push $DOCKER_USERNAME/wordsmith-db:$VERSION
docker push $DOCKER_USERNAME/wordsmith-db:dev

echo "✅ 所有镜像已成功推送到Docker Hub!"
echo ""
echo "📋 推送的镜像列表："
echo "  - $DOCKER_USERNAME/wordsmith-web:latest, $VERSION, dev"
echo "  - $DOCKER_USERNAME/wordsmith-words:latest, $VERSION, dev"
echo "  - $DOCKER_USERNAME/wordsmith-db:latest, $VERSION, dev"

