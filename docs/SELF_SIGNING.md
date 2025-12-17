# macOS 应用自签名指南

本指南介绍如何在没有 Apple 开发者证书的情况下自签名 CopyPathFinder 应用。

## 快速开始

### 1. 简单自签名（推荐）

最简单的方法，使用 ad-hoc 签名：

```bash
# 简单签名（推荐）
./scripts/self-sign-simple.sh

# 或者构建时签名
./scripts/build.sh release simple
```

### 2. 完整证书签名

创建自定义证书：

```bash
# 创建证书并签名应用
./scripts/self-sign.sh

# 或者分别执行
./scripts/self-sign.sh --create-cert  # 只创建证书
./scripts/self-sign.sh --sign-only    # 只签名应用

# 或者构建时签名
./scripts/build.sh release full
```

### 3. 构建选项

```bash
# 不签名
./scripts/build.sh release

# 简单签名
./scripts/build.sh release simple

# 完整证书签名
./scripts/build.sh release full
```

## 详细说明

### 自签名证书特点

✅ **优点：**
- 完全免费
- 可以在自己的 Mac 上运行应用
- 避免 Gatekeeper 阻止

⚠️ **限制：**
- 只在当前机器受信任
- 其他用户运行时会看到安全警告
- 无法通过 App Store 分发
- 无法进行公证

### 使用场景

- **个人使用：** 在自己设备上运行
- **内部测试：** 在开发团队内部测试
- **开源项目：** 让用户了解如何绕过安全限制

### 解决安全警告

当其他用户运行自签名应用时，可能会看到安全警告：

```
"CopyPathFinder.app" 无法打开，因为来自身份不明的开发者
```

**解决方法：**

1. **临时允许：**
   ```bash
   xattr -d com.apple.quarantine CopyPathFinder.app
   ```

2. **系统设置允许：**
   - 系统设置 > 隐私与安全性
   - 找到被阻止的应用，点击"仍要打开"

3. **右键点击：**
   - 右键点击应用 > 打开
   - 在弹出的警告中点击"打开"

### 证书文件位置

自签名证书和相关文件存储在：
```
.build/
├── CopyPathFinder.p12      # PKCS12 证书文件
├── certificate.crt         # X.509 证书
├── private.key             # 私钥
└── self-sign.keychain-db   # 临时钥匙串
```

### 生产环境建议

对于正式发布的应用，建议：

1. **注册 Apple Developer 账户**
   - 年费 $99
   - 获得有效的开发者证书
   - 可以进行应用公证

2. **使用 Notarization（公证）**
   ```bash
   xcrun altool --notarize-app \
     --primary-bundle-id "cn.tekin.copypathfinder" \
     --username "your@email.com" \
     --password "app-specific-password" \
     --file "CopyPathFinder.dmg"
   ```

3. **分发公证过的应用**
   - 通过官网或 GitHub Releases 分发
   - 用户下载后不会看到安全警告

### 故障排除

**问题：** `codesign` 命令失败
```bash
# 解决方案：检查证书是否存在
security find-identity -v -p codesigning
```

**问题：** 应用启动被阻止
```bash
# 解决方案：移除隔离属性
xattr -d com.apple.quarantine /path/to/CopyPathFinder.app
```

**问题：** 信任证书
```bash
# 解决方案：添加证书到登录钥匙串并信任
security add-trusted-cert -d -r trustRoot -k ~/Library/Keychains/login.keychain-db certificate.crt
```

### 技术细节

自签名过程使用以下技术：

1. **OpenSSL** - 生成证书和私钥
2. **Keychain** - 存储和管理证书
3. **codesign** - 签名应用程序
4. **PKCS#12** - 证书格式转换

### 自动化集成

可以将自签名集成到 CI/CD 流程中：

```yaml
# GitHub Actions 示例
- name: Self-sign app
  run: |
    ./scripts/self-sign.sh --create-cert
    ./scripts/self-sign.sh --sign-only
    xattr -d com.apple.quarantine CopyPathFinder.app
```

## 总结

自签名是一个很好的开发工具，但限于个人使用场景。对于公开发布的应用，建议使用 Apple Developer 证书以确保更好的用户体验。

