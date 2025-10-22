# GitHub Repository Variables 和 Secrets 配置指南

## Repository Variables 配置

在GitHub仓库中，进入 **Settings** → **Secrets and variables** → **Actions** → **Variables** 标签页，添加以下变量：

### 必需的 Repository Variables

| 变量名 | 默认值 | 描述 |
|--------|--------|------|
| `PROJECT_NAME` | `wordsmith` | 项目名称，用于镜像命名 |
| `BUILD_VERSION` | `1.0.0` | 构建版本号 |
| `REGISTRY_URL` | `docker.io` | Docker注册表URL |
| `IMAGE_TAG_SUFFIX` | (空) | 镜像标签后缀（可选） |

### 配置步骤

1. 进入GitHub仓库
2. 点击 **Settings** 标签
3. 在左侧菜单中找到 **Secrets and variables** → **Actions**
4. 点击 **Variables** 标签页
5. 点击 **New repository variable** 按钮
6. 输入变量名和值
7. 点击 **Add variable**

## Repository Secrets 配置

在GitHub仓库中，进入 **Settings** → **Secrets and variables** → **Actions** → **Secrets** 标签页，添加以下密钥：

### 必需的 Repository Secrets

| 密钥名 | 描述 | 示例 |
|--------|------|------|
| `DOCKER_USERNAME` | Docker Hub用户名 | `your-dockerhub-username` |
| `DOCKER_PASSWORD` | Docker Hub密码或访问令牌 | `your-dockerhub-password` |
| `NOTIFICATION_WEBHOOK` | 通知Webhook URL（可选） | `https://hooks.slack.com/services/...` |

### 配置步骤

1. 进入GitHub仓库
2. 点击 **Settings** 标签
3. 在左侧菜单中找到 **Secrets and variables** → **Actions**
4. 点击 **Secrets** 标签页
5. 点击 **New repository secret** 按钮
6. 输入密钥名和值
7. 点击 **Add secret**

## 工作流中的变量使用

### 1. Workflow级别变量
```yaml
env:
  PROJECT_NAME: ${{ vars.PROJECT_NAME || 'wordsmith' }}
  BUILD_VERSION: ${{ vars.BUILD_VERSION || '1.0.0' }}
  REGISTRY_URL: ${{ vars.REGISTRY_URL || 'docker.io' }}
```

### 2. Job级别变量
```yaml
jobs:
  build-and-push:
    env:
      DOCKER_USERNAME: ${{ secrets.DOCKER_USERNAME }}
      DOCKER_PASSWORD: ${{ secrets.DOCKER_PASSWORD }}
      NOTIFICATION_WEBHOOK: ${{ secrets.NOTIFICATION_WEBHOOK }}
      BUILD_ENVIRONMENT: ${{ github.event.inputs.environment || 'staging' }}
```

### 3. Step级别变量
```yaml
- name: Send notification
  env:
    WEBHOOK_URL: ${{ env.NOTIFICATION_WEBHOOK }}
    BUILD_STATUS: ${{ job.status }}
    STEP_NAME: "Build and Push Images"
```

## 变量优先级

1. **Step级别** - 最高优先级
2. **Job级别** - 中等优先级
3. **Workflow级别** - 最低优先级

## 安全注意事项

- **Secrets** 是加密存储的，不会在工作流日志中显示
- **Variables** 是明文存储的，可以在工作流日志中看到
- 敏感信息（如密码、API密钥）必须使用 **Secrets**
- 非敏感配置信息可以使用 **Variables**

## 触发方式

工作流支持两种触发方式：

1. **Pull Request标签触发**：当PR被标记为 `build-images` 标签时自动触发
2. **手动触发**：在Actions页面手动运行，可选择部署环境（staging/production）

## 镜像标签策略

构建的镜像会包含以下标签：
- `latest` - 主分支的最新版本
- `${{ github.sha }}` - 提交哈希
- `pr-${{ github.event.number }}` - PR编号
- `${{ env.BUILD_VERSION }}` - 版本号
- `${{ env.BUILD_ENVIRONMENT }}-${{ env.BUILD_VERSION }}` - 环境-版本组合
