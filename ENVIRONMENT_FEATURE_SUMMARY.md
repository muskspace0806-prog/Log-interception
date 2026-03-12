# 环境切换与响应解密功能说明

## 功能概述

ZWB_LogTap 现在支持：

1. **环境切换** - 测试环境 / 正式环境
2. **响应数据解密** - 为任意环境配置解密（灵活配置）

## 核心特性

✅ **默认不解密** - 不配置就不解密，简单直接  
✅ **按需配置** - 只为需要的环境配置解密  
✅ **多环境支持** - 可以为一个或多个环境配置不同的解密参数  
✅ **动态切换** - 切换环境时自动使用对应的解密配置

## 使用方法

### 1. 基础配置（不需要解密）

```swift
import ZWB_LogTap

// 在 AppDelegate 中启动
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
    // 默认测试环境，不配置解密
    ZWBLogTap.start(defaultEnvironment: .test)
    
    return true
}
```

### 2. 仅为正式环境配置解密

```swift
import ZWB_LogTap

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
    // 创建正式环境的解密配置
    let productionDecryption = ZWBLogTap.ResponseDecryptionConfig(
        aesKey: "your_production_aes_key",
        aesIV: "your_production_iv",
        encryptedFieldName: "ed"
    )
    
    // 启动时配置（只为正式环境配置解密）
    ZWBLogTap.start(
        defaultEnvironment: .test,
        decryptionConfigs: [
            .production: productionDecryption  // 只有正式环境需要解密
        ]
    )
    
    return true
}
```

### 3. 为多个环境配置不同的解密参数

```swift
import ZWB_LogTap

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
    // 测试环境的解密配置
    let testDecryption = ZWBLogTap.ResponseDecryptionConfig(
        aesKey: "test_aes_key_12345678901234567890",
        aesIV: "test_iv_16bytes_",
        encryptedFieldName: "ed"
    )
    
    // 正式环境的解密配置（不同的 Key 和 IV）
    let productionDecryption = ZWBLogTap.ResponseDecryptionConfig(
        aesKey: "prod_aes_key_12345678901234567890",
        aesIV: "prod_iv_16bytes_",
        encryptedFieldName: "ed"
    )
    
    // 启动时配置（两个环境都配置解密）
    ZWBLogTap.start(
        defaultEnvironment: .test,
        decryptionConfigs: [
            .test: testDecryption,           // 测试环境解密配置
            .production: productionDecryption // 正式环境解密配置
        ]
    )
    
    return true
}
```

### 4. 使用 Configuration 方式配置

```swift
import ZWB_LogTap

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
    // 创建配置
    var config = ZWBLogTap.Configuration()
    config.showFloatingButton = true
    config.interceptHTTP = true
    config.maxRecords = 1000
    config.defaultEnvironment = .test
    
    // 配置解密（可以为任意环境配置）
    config.decryptionConfigs = [
        .production: ZWBLogTap.ResponseDecryptionConfig(
            aesKey: GMConst.AES_DECRYPT_KEY.rawValue,
            aesIV: GMConst.AES_DECRYPT_IV.rawValue,
            encryptedFieldName: "ed"
        )
    ]
    
    // 启动
    ZWBLogTap.shared.start(with: config)
    
    return true
}
```

### 5. 动态添加或移除解密配置

```swift
import ZWB_LogTap

// 为正式环境添加解密配置
let config = ZWBLogTap.ResponseDecryptionConfig(
    aesKey: "your_key",
    aesIV: "your_iv"
)
EnvironmentManager.shared.setDecryptionConfig(for: .production, config: config)

// 移除测试环境的解密配置
EnvironmentManager.shared.setDecryptionConfig(for: .test, config: nil)

// 批量设置多个环境的解密配置
EnvironmentManager.shared.setDecryptionConfigs([
    .test: testConfig,
    .production: prodConfig
])
```

## 工作原理

### 环境切换

- **测试环境（蓝色按钮）** - 如果配置了解密则解密，否则显示原始响应
- **正式环境（红色按钮）** - 如果配置了解密则解密，否则显示原始响应

### 响应数据解密流程

1. **检查配置** - 查看当前环境是否配置了解密
2. **识别加密格式** - 检查响应是否为 `{"ed": "加密字符串"}` 格式
3. **Base64 解码** - 将加密字符串进行 Base64 解码
4. **AES-256-CBC 解密** - 使用配置的 Key 和 IV 进行解密
5. **显示结果** - 在日志面板中显示解密后的 JSON

### 加密响应格式示例

```json
{
  "ed": "mdlIOnMCcscqcn4biCloPy1d7cl+LHM5Jq299gHUwaC..."
}
```

解密后显示为：

```json
{
  "code": 200,
  "message": "success",
  "data": {
    "userId": "12345",
    "userName": "张三",
    "balance": 1000.50
  }
}
```

## 配置场景示例

### 场景 1: 默认不解密（最简单）

```swift
// 两个环境都不解密，直接显示原始响应
ZWBLogTap.start()
```

### 场景 2: 只有正式环境需要解密

```swift
// 测试环境不加密，正式环境加密
ZWBLogTap.start(
    decryptionConfigs: [
        .production: ZWBLogTap.ResponseDecryptionConfig(
            aesKey: "prod_key",
            aesIV: "prod_iv"
        )
    ]
)
```

### 场景 3: 两个环境都加密，但密钥不同

```swift
// 测试环境和正式环境使用不同的密钥
ZWBLogTap.start(
    decryptionConfigs: [
        .test: ZWBLogTap.ResponseDecryptionConfig(
            aesKey: "test_key",
            aesIV: "test_iv"
        ),
        .production: ZWBLogTap.ResponseDecryptionConfig(
            aesKey: "prod_key",
            aesIV: "prod_iv"
        )
    ]
)
```

### 场景 4: 临时禁用某个环境的解密

```swift
// 创建配置但禁用
let config = ZWBLogTap.ResponseDecryptionConfig(
    aesKey: "key",
    aesIV: "iv",
    enabled: false  // 禁用解密
)

ZWBLogTap.start(
    decryptionConfigs: [
        .production: config
    ]
)
```

## 示例项目配置

```swift
// GMConst.swift
enum GMConst: String {
    // 测试环境密钥
    case TEST_AES_KEY = "test_key_32_bytes_long_string"
    case TEST_AES_IV = "test_iv_16bytes_"
    
    // 正式环境密钥
    case PROD_AES_KEY = "prod_key_32_bytes_long_string"
    case PROD_AES_IV = "prod_iv_16bytes_"
}

// AppDelegate.swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
    #if DEBUG
    // Debug 模式下启动日志工具
    ZWBLogTap.start(
        defaultEnvironment: .test,
        decryptionConfigs: [
            .test: ZWBLogTap.ResponseDecryptionConfig(
                aesKey: GMConst.TEST_AES_KEY.rawValue,
                aesIV: GMConst.TEST_AES_IV.rawValue
            ),
            .production: ZWBLogTap.ResponseDecryptionConfig(
                aesKey: GMConst.PROD_AES_KEY.rawValue,
                aesIV: GMConst.PROD_AES_IV.rawValue
            )
        ]
    )
    #endif
    
    return true
}
```

## 常见问题

### Q: 为什么某个环境看不到解密后的数据？

A: 检查是否为该环境配置了解密参数。如果没有配置，会显示原始响应。

### Q: 可以只为一个环境配置解密吗？

A: 可以！你可以只为需要的环境配置解密，其他环境不配置。

### Q: 解密失败怎么办？

A: 检查以下几点：
- AES Key 和 IV 是否正确
- 加密字段名是否匹配（默认 "ed"）
- 响应数据格式是否正确
- Key 长度是否为 32 字节，IV 长度是否为 16 字节

### Q: 可以自定义加密字段名吗？

A: 可以，在创建 `ResponseDecryptionConfig` 时指定：

```swift
let config = ZWBLogTap.ResponseDecryptionConfig(
    aesKey: "your_key",
    aesIV: "your_iv",
    encryptedFieldName: "encrypted_data"  // 自定义字段名
)
```

### Q: 可以临时禁用解密吗？

A: 可以，使用 `enabled` 参数：

```swift
let config = ZWBLogTap.ResponseDecryptionConfig(
    aesKey: "your_key",
    aesIV: "your_iv",
    enabled: false  // 临时禁用
)
```
