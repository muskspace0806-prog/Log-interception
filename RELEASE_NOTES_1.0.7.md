# ZWB_LogTap 1.0.7 发布说明

## 🎉 新功能

### 1. 响应数据解密功能
- ✅ 支持 AES-128-CBC 解密
- ✅ 多环境解密配置（测试/正式环境可配置不同的 Key 和 IV）
- ✅ HTTP 响应 Body 自动解密
- ✅ WebSocket (IM) 消息自动解密
- ✅ 解密失败时安全回退到原始数据
- ✅ 默认不解密，按需配置
- ✅ 向后兼容，不影响未配置解密的项目

### 2. URL 过滤功能
- ✅ 支持添加 URL 过滤规则（模糊匹配）
- ✅ 过滤的 URL 请求不会显示在日志面板
- ✅ 支持 HTTP 和 WebSocket 消息过滤
- ✅ 过滤规则持久化存储
- ✅ 可随时添加/删除过滤规则

### 3. UI 优化
- ✅ URL 参数从"URL 信息"标签迁移到"请求 Body"标签显示
- ✅ HTTP 详情页默认显示"响应 Body"标签
- ✅ 优化按钮布局，"过滤"按钮移至左侧
- ✅ 调整浮动按钮底部距离，避免与 tabBar 重叠

## 📝 使用示例

### 配置解密功能

```swift
import ZWB_LogTap

// 配置多环境解密
let testConfig = ZWBLogTap.ResponseDecryptionConfig(
    aesKey: "your_test_aes_key_16bytes",
    aesIV: "your_test_iv_16bytes",
    encryptedFieldName: "ed",
    enabled: true
)

let prodConfig = ZWBLogTap.ResponseDecryptionConfig(
    aesKey: "your_prod_aes_key_16bytes",
    aesIV: "your_prod_iv_16bytes",
    encryptedFieldName: "ed",
    enabled: true
)

ZWBLogTap.start(
    defaultEnvironment: .test,
    decryptionConfigs: [
        .test: testConfig,
        .production: prodConfig
    ]
)
```

### 使用 URL 过滤

1. 点击日志面板顶部的"过滤"按钮
2. 点击"添加"输入要过滤的 URL（支持部分匹配）
3. 匹配的 URL 请求将不再显示在日志列表中
4. 点击规则右侧的 ✕ 可删除过滤规则

## 🔧 技术细节

### 新增文件
- `ZWB_LogTap/Classes/Core/AESCrypto.swift` - AES 加解密实现
- `ZWB_LogTap/Classes/Core/URLFilterManager.swift` - URL 过滤管理器
- `ZWB_LogTap/Classes/UI/URLFilterViewController.swift` - URL 过滤设置页面

### 修改文件
- `ZWB_LogTap/Classes/Core/EnvironmentManager.swift` - 支持多环境解密配置
- `ZWB_LogTap/Classes/Models/InterceptedRequest.swift` - 支持响应解密
- `ZWB_LogTap/Classes/Models/WebSocketMessage.swift` - 支持消息解密
- `ZWB_LogTap/Classes/UI/NetworkLogViewController.swift` - 添加过滤功能和过滤逻辑
- `ZWB_LogTap/Classes/UI/NetworkLogDetailViewController.swift` - UI 优化
- `ZWB_LogTap/Classes/UI/FloatingButton.swift` - 调整底部距离
- `ZWB_LogTap/Classes/ZWBLogTap.swift` - 支持解密配置

## 📦 安装

### CocoaPods

```ruby
pod 'ZWB_LogTap', '~> 1.0.7'
```

然后运行：
```bash
pod install
```

## ⚠️ 注意事项

1. 解密功能默认关闭，需要手动配置才会启用
2. 请求 Body 和 URL 参数不会被解密，保持原样
3. 解密失败时会自动回退到原始数据，不会影响正常使用
4. URL 过滤规则使用模糊匹配（不区分大小写）

## 🐛 Bug 修复

- 修复了浮动按钮可能与 tabBar 重叠的问题
- 优化了按钮布局，避免拥挤

## 📚 文档

详细文档请参考：
- [解密功能测试指南](DECRYPTION_TEST_GUIDE.md)
- [环境切换功能说明](ENVIRONMENT_FEATURE_SUMMARY.md)
- [快速开始](QUICK_START.md)

---

**发布日期**: 2024-01-XX
**版本**: 1.0.7
