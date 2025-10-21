# GitHub Actions Workflow - Build Wordsmith Images

## 配置说明

### 1. Docker Hub 配置

在GitHub仓库中设置以下Secrets：

1. 进入仓库 → Settings → Secrets and variables → Actions
2. 添加以下secrets：
   - `DOCKER_USERNAME`: 你的Docker Hub用户名
   - `DOCKER_PASSWORD`: 你的Docker Hub密码或访问令牌

### 2. 工作流触发

工作流会在以下情况下触发：
- 当Pull Request被添加了 `build-images` 标签时

### 3. 构建的镜像

工作流会构建并推送以下三个镜像到Docker Hub：

#### Web Service
- `{DOCKER_USERNAME}/wordsmith-web:latest`
- `{DOCKER_USERNAME}/wordsmith-web:{SHA}`
- `{DOCKER_USERNAME}/wordsmith-web:pr-{PR_NUMBER}`

#### Words Service  
- `{DOCKER_USERNAME}/wordsmith-words:latest`
- `{DOCKER_USERNAME}/wordsmith-words:{SHA}`
- `{DOCKER_USERNAME}/wordsmith-words:pr-{PR_NUMBER}`

#### Database Service
- `{DOCKER_USERNAME}/wordsmith-db:latest`
- `{DOCKER_USERNAME}/wordsmith-db:{SHA}`
- `{DOCKER_USERNAME}/wordsmith-db:pr-{PR_NUMBER}`

### 4. 使用方法

1. 创建Pull Request
2. 在PR上添加 `build-images` 标签
3. 工作流会自动触发并构建镜像
4. 查看Actions页面确认构建成功

### 5. 特性

- ✅ 并行构建三个镜像
- ✅ Docker Buildx支持多平台构建
- ✅ GitHub Actions缓存加速构建
- ✅ 自动标签管理
- ✅ 构建摘要报告

## 示例

```bash
# 使用构建的镜像
docker run -p 80:80 your-username/wordsmith-web:latest
docker run -p 8080:8080 your-username/wordsmith-words:latest  
docker run -p 5432:5432 your-username/wordsmith-db:latest
```
