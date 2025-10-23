# PowerShell 脚本 - 使用 GitHub CLI 配置 Repository Secrets 和 Variables

# 检查是否安装了 GitHub CLI
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Host "❌ GitHub CLI 未安装。请先安装: https://cli.github.com/" -ForegroundColor Red
    exit 1
}

# 检查是否已登录
$authStatus = gh auth status 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "🔐 请先登录 GitHub CLI:" -ForegroundColor Yellow
    Write-Host "gh auth login" -ForegroundColor Cyan
    exit 1
}

Write-Host "🚀 开始配置 Repository Secrets 和 Variables..." -ForegroundColor Green

# 获取仓库信息
$repo = gh repo view --json nameWithOwner -q .nameWithOwner
Write-Host "📦 目标仓库: $repo" -ForegroundColor Blue

# 配置 Repository Variables
Write-Host "📝 配置 Repository Variables..." -ForegroundColor Yellow

# PROJECT_NAME
$projectName = Read-Host "请输入项目名称 (默认: wordsmith)"
if ([string]::IsNullOrEmpty($projectName)) { $projectName = "wordsmith" }
gh variable set PROJECT_NAME --body $projectName

# BUILD_VERSION
$buildVersion = Read-Host "请输入构建版本 (默认: 1.0.0)"
if ([string]::IsNullOrEmpty($buildVersion)) { $buildVersion = "1.0.0" }
gh variable set BUILD_VERSION --body $buildVersion

# REGISTRY_URL
$registryUrl = Read-Host "请输入Docker注册表URL (默认: docker.io)"
if ([string]::IsNullOrEmpty($registryUrl)) { $registryUrl = "docker.io" }
gh variable set REGISTRY_URL --body $registryUrl

# IMAGE_TAG_SUFFIX (可选)
$imageTagSuffix = Read-Host "请输入镜像标签后缀 (可选，直接回车跳过)"
if (-not [string]::IsNullOrEmpty($imageTagSuffix)) {
    gh variable set IMAGE_TAG_SUFFIX --body $imageTagSuffix
}

Write-Host "✅ Repository Variables 配置完成!" -ForegroundColor Green

# 配置 Repository Secrets
Write-Host "🔐 配置 Repository Secrets..." -ForegroundColor Yellow

# DOCKER_USERNAME
$dockerUsername = Read-Host "请输入Docker Hub用户名"
if (-not [string]::IsNullOrEmpty($dockerUsername)) {
    gh secret set DOCKER_USERNAME --body $dockerUsername
}

# DOCKER_PASSWORD
$dockerPassword = Read-Host "请输入Docker Hub密码/访问令牌" -AsSecureString
$dockerPasswordPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($dockerPassword))
if (-not [string]::IsNullOrEmpty($dockerPasswordPlain)) {
    gh secret set DOCKER_PASSWORD --body $dockerPasswordPlain
}

# NOTIFICATION_WEBHOOK (可选)
$notificationWebhook = Read-Host "请输入通知Webhook URL (可选，直接回车跳过)"
if (-not [string]::IsNullOrEmpty($notificationWebhook)) {
    gh secret set NOTIFICATION_WEBHOOK --body $notificationWebhook
}

Write-Host "✅ Repository Secrets 配置完成!" -ForegroundColor Green

# 显示配置摘要
Write-Host ""
Write-Host "🎉 配置完成! 摘要:" -ForegroundColor Green
Write-Host "📝 Variables:" -ForegroundColor Blue
gh variable list

Write-Host ""
Write-Host "🔐 Secrets:" -ForegroundColor Blue
gh secret list

Write-Host ""
Write-Host "💡 提示:" -ForegroundColor Yellow
Write-Host "- Variables 是明文存储的，可以在工作流日志中看到"
Write-Host "- Secrets 是加密存储的，不会在工作流日志中显示"
Write-Host "- 您的工作流现在可以使用这些配置了!"
