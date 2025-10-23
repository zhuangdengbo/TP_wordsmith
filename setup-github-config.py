#!/usr/bin/env python3
"""
GitHub Repository Secrets 和 Variables 配置脚本
使用 GitHub API 自动配置仓库的 secrets 和 variables
"""

import os
import sys
import json
import base64
import requests
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.asymmetric import padding
from cryptography.hazmat.primitives.serialization import load_pem_public_key

class GitHubConfigManager:
    def __init__(self, token, owner, repo):
        self.token = token
        self.owner = owner
        self.repo = repo
        self.base_url = f"https://api.github.com/repos/{owner}/{repo}"
        self.headers = {
            "Accept": "application/vnd.github+json",
            "Authorization": f"Bearer {token}",
            "X-GitHub-Api-Version": "2022-11-28"
        }
    
    def set_variable(self, name, value):
        """设置 Repository Variable"""
        url = f"{self.base_url}/actions/variables/{name}"
        data = {"name": name, "value": value}
        
        try:
            response = requests.patch(url, headers=self.headers, json=data)
            response.raise_for_status()
            print(f"✅ 变量 {name} 设置成功")
            return True
        except requests.exceptions.RequestException as e:
            print(f"❌ 设置变量 {name} 失败: {e}")
            return False
    
    def get_public_key(self):
        """获取仓库公钥"""
        url = f"{self.base_url}/actions/secrets/public-key"
        
        try:
            response = requests.get(url, headers=self.headers)
            response.raise_for_status()
            return response.json()
        except requests.exceptions.RequestException as e:
            print(f"❌ 获取公钥失败: {e}")
            return None
    
    def encrypt_secret(self, value, public_key):
        """使用公钥加密密钥值"""
        try:
            # 解码公钥
            key_data = base64.b64decode(public_key)
            public_key_obj = load_pem_public_key(key_data)
            
            # 加密值
            encrypted = public_key_obj.encrypt(
                value.encode('utf-8'),
                padding.OAEP(
                    mgf=padding.MGF1(algorithm=hashes.SHA256()),
                    algorithm=hashes.SHA256(),
                    label=None
                )
            )
            
            return base64.b64encode(encrypted).decode('utf-8')
        except Exception as e:
            print(f"❌ 加密失败: {e}")
            return None
    
    def set_secret(self, name, value):
        """设置 Repository Secret"""
        # 获取公钥
        key_info = self.get_public_key()
        if not key_info:
            return False
        
        # 加密值
        encrypted_value = self.encrypt_secret(value, key_info['key'])
        if not encrypted_value:
            return False
        
        # 设置密钥
        url = f"{self.base_url}/actions/secrets/{name}"
        data = {
            "encrypted_value": encrypted_value,
            "key_id": key_info['key_id']
        }
        
        try:
            response = requests.put(url, headers=self.headers, json=data)
            response.raise_for_status()
            print(f"✅ 密钥 {name} 设置成功")
            return True
        except requests.exceptions.RequestException as e:
            print(f"❌ 设置密钥 {name} 失败: {e}")
            return False

def main():
    print("🚀 GitHub Repository Secrets 和 Variables 配置工具")
    print("=" * 50)
    
    # 获取配置信息
    token = os.getenv('GITHUB_TOKEN')
    if not token:
        token = input("请输入 GitHub Personal Access Token: ").strip()
    
    owner = input("请输入仓库所有者: ").strip()
    repo = input("请输入仓库名称: ").strip()
    
    if not all([token, owner, repo]):
        print("❌ 缺少必要信息")
        sys.exit(1)
    
    # 创建配置管理器
    manager = GitHubConfigManager(token, owner, repo)
    
    print(f"\n📦 目标仓库: {owner}/{repo}")
    
    # 配置 Variables
    print("\n📝 配置 Repository Variables...")
    variables = {
        "PROJECT_NAME": input("请输入项目名称 (默认: wordsmith): ").strip() or "wordsmith",
        "BUILD_VERSION": input("请输入构建版本 (默认: 1.0.0): ").strip() or "1.0.0",
        "REGISTRY_URL": input("请输入Docker注册表URL (默认: docker.io): ").strip() or "docker.io"
    }
    
    # 可选的 IMAGE_TAG_SUFFIX
    image_tag_suffix = input("请输入镜像标签后缀 (可选): ").strip()
    if image_tag_suffix:
        variables["IMAGE_TAG_SUFFIX"] = image_tag_suffix
    
    for name, value in variables.items():
        manager.set_variable(name, value)
    
    # 配置 Secrets
    print("\n🔐 配置 Repository Secrets...")
    
    docker_username = input("请输入Docker Hub用户名: ").strip()
    if docker_username:
        manager.set_secret("DOCKER_USERNAME", docker_username)
    
    docker_password = input("请输入Docker Hub密码/访问令牌: ").strip()
    if docker_password:
        manager.set_secret("DOCKER_PASSWORD", docker_password)
    
    webhook_url = input("请输入通知Webhook URL (可选): ").strip()
    if webhook_url:
        manager.set_secret("NOTIFICATION_WEBHOOK", webhook_url)
    
    print("\n🎉 配置完成!")
    print("💡 提示:")
    print("- Variables 是明文存储的，可以在工作流日志中看到")
    print("- Secrets 是加密存储的，不会在工作流日志中显示")
    print("- 您的工作流现在可以使用这些配置了!")

if __name__ == "__main__":
    main()
