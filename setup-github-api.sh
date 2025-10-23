#!/bin/bash
# GitHub API 脚本 - 通过 REST API 配置 Repository Secrets 和 Variables

# 配置信息
GITHUB_TOKEN=""  # 需要 Personal Access Token
REPO_OWNER=""    # 仓库所有者
REPO_NAME=""     # 仓库名称

# 检查必要的参数
if [ -z "$GITHUB_TOKEN" ] || [ -z "$REPO_OWNER" ] || [ -z "$REPO_NAME" ]; then
    echo "❌ 请先配置脚本中的变量:"
    echo "   GITHUB_TOKEN - GitHub Personal Access Token"
    echo "   REPO_OWNER   - 仓库所有者"
    echo "   REPO_NAME    - 仓库名称"
    exit 1
fi

API_BASE="https://api.github.com/repos/$REPO_OWNER/$REPO_NAME"

echo "🚀 开始配置 Repository Secrets 和 Variables..."
echo "📦 目标仓库: $REPO_OWNER/$REPO_NAME"

# 函数：设置 Repository Variable
set_variable() {
    local name=$1
    local value=$2
    
    echo "📝 设置变量: $name"
    curl -X PATCH \
        -H "Accept: application/vnd.github+json" \
        -H "Authorization: Bearer $GITHUB_TOKEN" \
        -H "X-GitHub-Api-Version: 2022-11-28" \
        "$API_BASE/actions/variables/$name" \
        -d "{\"name\":\"$name\",\"value\":\"$value\"}"
}

# 函数：设置 Repository Secret
set_secret() {
    local name=$1
    local value=$2
    
    echo "🔐 设置密钥: $name"
    
    # 获取仓库公钥
    PUBLIC_KEY_RESPONSE=$(curl -s \
        -H "Accept: application/vnd.github+json" \
        -H "Authorization: Bearer $GITHUB_TOKEN" \
        -H "X-GitHub-Api-Version: 2022-11-28" \
        "$API_BASE/actions/secrets/public-key")
    
    PUBLIC_KEY=$(echo $PUBLIC_KEY_RESPONSE | jq -r '.key')
    KEY_ID=$(echo $PUBLIC_KEY_RESPONSE | jq -r '.key_id')
    
    # 使用公钥加密值
    ENCRYPTED_VALUE=$(echo -n "$value" | openssl rsautl -encrypt -pubin -inkey <(echo "$PUBLIC_KEY" | base64 -d) | base64 -w 0)
    
    # 设置加密的密钥
    curl -X PUT \
        -H "Accept: application/vnd.github+json" \
        -H "Authorization: Bearer $GITHUB_TOKEN" \
        -H "X-GitHub-Api-Version: 2022-11-28" \
        "$API_BASE/actions/secrets/$name" \
        -d "{\"encrypted_value\":\"$ENCRYPTED_VALUE\",\"key_id\":\"$KEY_ID\"}"
}

# 配置 Repository Variables
echo "📝 配置 Repository Variables..."

# 设置默认变量
set_variable "PROJECT_NAME" "wordsmith"
set_variable "BUILD_VERSION" "1.0.0"
set_variable "REGISTRY_URL" "docker.io"

echo "✅ Repository Variables 配置完成!"

# 配置 Repository Secrets
echo "🔐 配置 Repository Secrets..."

# 提示用户输入敏感信息
read -p "请输入Docker Hub用户名: " DOCKER_USERNAME
if [ -n "$DOCKER_USERNAME" ]; then
    set_secret "DOCKER_USERNAME" "$DOCKER_USERNAME"
fi

read -s -p "请输入Docker Hub密码/访问令牌: " DOCKER_PASSWORD
echo
if [ -n "$DOCKER_PASSWORD" ]; then
    set_secret "DOCKER_PASSWORD" "$DOCKER_PASSWORD"
fi

read -p "请输入通知Webhook URL (可选): " NOTIFICATION_WEBHOOK
if [ -n "$NOTIFICATION_WEBHOOK" ]; then
    set_secret "NOTIFICATION_WEBHOOK" "$NOTIFICATION_WEBHOOK"
fi

echo "✅ Repository Secrets 配置完成!"

echo ""
echo "🎉 配置完成!"
echo "💡 提示: 您的工作流现在可以使用这些配置了!"
