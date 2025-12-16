# GitHub 发布流程指南

## 🚀 自动发布流程

### 触发条件

发布流程由 Git 标签触发：
```bash
# 创建版本标签
git tag v1.0.0
git push origin v1.0.0
```

### 构建流程

1. **环境准备**
   - macOS 11 环境
   - 最新稳定版 Xcode
   - Swift Package Manager 缓存

2. **编译构建**
   - Release 模式编译
   - 创建 App Bundle
   - 复制资源文件（图标等）

3. **代码签名**
   - 自动应用 ad-hoc 签名
   - 如果配置了开发者证书，使用证书签名
   - 验证签名有效性

4. **打包分发**
   - 创建 DMG 安装包
   - 创建 ZIP 压缩包
   - 生成 SHA256 校验和

5. **自动发布**
   - 生成发布说明
   - 上传所有文件到 GitHub Release
   - 自动生成发布说明

## 📦 发布文件

每次发布会包含以下文件：

| 文件名 | 描述 | 用途 |
|--------|------|------|
| `CopyPathFinder.dmg` | DMG 安装包 | 推荐的安装方式 |
| `CopyPathFinder.dmg.sha256` | DMG 校验和 | 验证文件完整性 |
| `CopyPathFinder.zip` | ZIP 压缩包 | 备用安装方式 |
| `CopyPathFinder.zip.sha256` | ZIP 校验和 | 验证文件完整性 |

## 🔐 签名策略

### 默认：自签名 (Ad-hoc)

- 无需证书
- 自动应用到所有 CI 构建
- 在用户设备上可能显示安全警告

### 可选：开发者证书

如需使用正式开发者证书：

1. 在 GitHub Secrets 中添加：
   - `APPLE_SIGNING_IDENTITY`: 开发者身份（如 "Developer ID Application: Your Name"）
   - `APPLE_CERTIFICATE_BASE64`: P12 证书的 base64 编码
   - `APPLE_CERTIFICATE_PASSWORD`: 证书密码

2. 证书将用于覆盖默认的自签名

## 📋 发布说明模板

发布说明自动生成，包含：

- ✨ 功能特性介绍
- 🔧 安装指南
- 🔐 安全提示和解决方案
- 🖥️ 系统要求
- 📝 使用方法
- 🔗 相关链接
- 📊 文件校验说明

## 🛠️ 本地测试发布

在推送标签前，可以本地测试：

```bash
# 构建应用
./scripts/build.sh release simple

# 测试签名
codesign --verify --verbose .build/CopyPathFinder.app

# 创建测试 DMG
./scripts/build.sh release simple
```

## 🔄 CI/CD 集成

### 主分支构建

每次推送到 `main` 分支会触发 CI 构建：
- 编译测试
- 创建构建产物
- 应用自签名
- 保存构建产物 30 天

### 发布构建

推送版本标签时：
- 完整的发布流程
- 创建 GitHub Release
- 生成发布说明
- 上传所有分发文件

## 📝 版本管理

### 版本号格式

遵循语义化版本控制：
```
v{MAJOR}.{MINOR}.{PATCH}
```

- `MAJOR`: 重大更新，不兼容的 API 变更
- `MINOR`: 新功能，向后兼容
- `PATCH`: 修复 bug，向后兼容

### 发布类型

1. **正式发布** (无前缀)
   - 如 `v1.0.0`
   - 稳定版本，推荐生产使用

2. **预发布** (预发布标识)
   - 如 `v1.0.0-beta.1`
   - 测试版本，尝鲜使用

3. **开发版本** (开发标识)
   - 如 `v1.0.0-dev.20231201`
   - 开发快照，仅限测试

## 🔧 自定义配置

### 修改发布模板

编辑 `.github/release_template.md` 文件来自定义发布说明内容。

### 修改签名配置

编辑 `.github/workflows/release.yml` 中的签名步骤：

```yaml
- name: Code Sign (Custom)
  run: |
    # 自定义签名逻辑
    codesign --options runtime --sign "$IDENTITY" App.app
```

### 添加构建步骤

在构建过程中添加自定义步骤：

```yaml
- name: Custom Step
  run: |
    # 你的自定义命令
    echo "Custom build step"
```

## 🚨 故障排除

### 构建失败

1. **检查 Swift 版本兼容性**
2. **验证依赖项是否正确**
3. **检查资源文件路径**

### 签名失败

1. **确保 codesign 工具可用**
2. **检查应用权限设置**
3. **验证临时钥匙串访问权限**

### 发布失败

1. **检查 GitHub Token 权限**
2. **验证标签格式正确**
3. **确保网络连接正常**

## 📊 监控和分析

### 下载统计

GitHub 提供 Release 下载统计：
- 访问 Repository 的 Releases 页面
- 查看每个版本的下载次数
- 分析用户下载偏好

### 错误追踪

通过 Issues 追踪用户反馈：
1. 创建 "bug" 标签
2. 设置问题模板
3. 定期整理和修复

## 🎯 最佳实践

1. **版本管理**
   - 保持版本号一致
   - 使用有意义的提交信息
   - 维护 CHANGELOG

2. **发布质量**
   - 本地测试后再发布
   - 验证所有文件完整性
   - 确保发布说明准确

3. **用户体验**
   - 提供清晰的安装指南
   - 及时响应用户反馈
   - 保持文档更新

## 📚 相关资源

- [GitHub Actions 文档](https://docs.github.com/en/actions)
- [Apple 代码签名指南](https://developer.apple.com/documentation/code-distribution)
- [语义化版本控制](https://semver.org/)
- [CopyPathFinder 项目](https://github.com/tekintian/CopyPathFinder)

---

通过这套自动化发布流程，可以确保每次发布的一致性和可靠性，同时减少手动操作的错误。