# ZWB_LogTap 1.0.7 使用指南

## 安装

```ruby
pod 'ZWB_LogTap', '~> 1.0.7'
```

## 新功能 1: 响应数据解密

### 配置解密（可选）

```swift
import ZWB_LogTap

// 配置测试环境解密
let testConfig = ZWBLogTap.ResponseDecryptionConfig(
    aesKey: "your_test_key_16",
    aesIV: "your_test_iv_16",
    encryptedFieldName: "ed",
    enabled: true
)

// 配置正式环境解密
let prodConfig = ZWBLogTap.ResponseDecryptionConfig(
    aesKey: "your_prod_key_16",
    aesIV: "your_prod_iv_16",
    encryptedFieldName: "ed",
    enabled: true
)

// 启动时配置
ZWBLogTap.start(
    defaultEnvironment: .test,
    decryptionConfigs: [
        .test: testConfig,
        .production: prodConfig
    ]
)
```

### 解密说明
- 支持 AES-128-CBC 解密
- 自动解密 HTTP 响应 Body 和 WebSocket 消息
- 解密格式: `{"ed": "base64_encrypted_data"}`
- 解密失败时自动回退到原始数据


## 新功能 2: URL 过滤

### 使用方法

1. 点击日志面板顶部的"过滤"按钮
2. 点击右上角"添加"按钮
3. 输入要过滤的 URL（支持部分匹配）
4. 匹配的请求将不再显示在日志列表中

### 删除过滤规则

- 在过滤列表中，点击规则右侧的 ✕ 按钮

### 特性

- 支持模糊匹配（不区分大小写）
- 同时过滤 HTTP 和 WebSocket 消息
- 规则持久化保存

## UI 优化

### 1. URL 参数显示位置
- URL 参数已从"URL 信息"标签移到"请求 Body"标签
- 先显示 URL 参数，再显示请求 Body

### 2. 默认显示标签
- HTTP 详情页默认显示"响应 Body"标签
- 更快查看响应数据

### 3. 按钮布局
- "过滤"按钮位于左侧"关闭"按钮右边
- 浮动按钮距离底部更高，避免与 tabBar 重叠

## 向后兼容

- 不配置解密时，所有功能保持原样
- 不添加过滤规则时，显示所有请求
- 完全向后兼容 1.0.6 及之前版本
