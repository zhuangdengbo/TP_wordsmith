#!/bin/bash
# GitHub CLI 脚本 - 自动配置 Repository Secrets 和 Variables

# 检查是否安装了 GitHub CLI
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI 未安装。请先安装: https://cli.github.com/"
    exit 1
fi

# 检查是否已登录
if ! gh auth status &> /dev/null; then
    echo "🔐 请先登录 GitHub CLI:"
    echo "gh auth login"
    exit 1
fi

echo "🚀 开始配置 Repository Secrets 和 Variables..."

# 获取仓库信息
REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner)
echo "📦 目标仓库: $REPO"

# 配置 Repository Variables
echo "📝 配置 Repository Variables..."

# PROJECT_NAME
read -p "请输入项目名称 (默认: wordsmith): " PROJECT_NAME
PROJECT_NAME=${PROJECT_NAME:-wordsmith}
gh variable set PROJECT_NAME --body "$PROJECT_NAME"

# BUILD_VERSION
read -p "请输入构建版本 (默认: 1.0.0): " BUILD_VERSION
BUILD_VERSION=${BUILD_VERSION:-1.0.0}
gh variable set BUILD_VERSION --body "$BUILD_VERSION"

# REGISTRY_URL
read -p "请输入Docker注册表URL (默认: docker.io): " REGISTRY_URL
REGISTRY_URL=${REGISTRY_URL:-docker.io}
gh variable set REGISTRY_URL --body "$REGISTRY_URL"

# IMAGE_TAG_SUFFIX (可选)
read -p "请输入镜像标签后缀 (可选，直接回车跳过): " IMAGE_TAG_SUFFIX
if [ -n "$IMAGE_TAG_SUFFIX" ]; then
    gh variable set IMAGE_TAG_SUFFIX --body "$IMAGE_TAG_SUFFIX"
fi

echo "✅ Repository Variables 配置完成!"

# 配置 Repository Secrets
echo "🔐 配置 Repository Secrets..."

# DOCKER_USERNAME
read -p "请输入Docker Hub用户名: " DOCKER_USERNAME
if [ -n "$DOCKER_USERNAME" ]; then
    gh secret set DOCKER_USERNAME --body "$DOCKER_USERNAME"
fi

# DOCKER_PASSWORD
read -s -p "请输入Docker Hub密码/访问令牌: " DOCKER_PASSWORD
echo
if [ -n "$DOCKER_PASSWORD" ]; then
    gh secret set DOCKER_PASSWORD --body "$DOCKER_PASSWORD"
fi

# NOTIFICATION_WEBHOOK (可选)
read -p "请输入通知Webhook URL (可选，直接回车跳过): " NOTIFICATION_WEBHOOK
if [ -n "$NOTIFICATION_WEBHOOK" ]; then
    gh secret set NOTIFICATION_WEBHOOK --body "$NOTIFICATION_WEBHOOK"
fi

echo "✅ Repository Secrets 配置完成!"

# 显示配置摘要
echo ""
echo "🎉 配置完成! 摘要:"
echo "📝 Variables:"
gh variable list
echo ""
echo "🔐 Secrets:"
gh secret list

echo ""
echo "💡 提示:"
echo "- Variables 是明文存储的，可以在工作流日志中看到"
echo "- Secrets 是加密存储的，不会在工作流日志中显示"
echo "- 您的工作流现在可以使用这些配置了!"
