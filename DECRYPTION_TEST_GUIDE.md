# 解密功能测试指南

## 问题排查步骤

### 1. 检查是否配置了解密

在你的 AppDelegate 中，确认是否配置了解密：

```swift
import ZWB_LogTap

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
    #if DEBUG
    // 创建解密配置
    let decryptionConfig = ZWBLogTap.ResponseDecryptionConfig(
        aesKey: "your_16_byte_key_",  // AES-128 需要 16 字节
        aesIV: "your_16_byte_iv__",   // IV 需要 16 字节
        encryptedFieldName: "ed",      // 加密字段名
        enabled: true                  // 确保启用
    )
    
    // 为正式环境配置解密
    ZWBLogTap.start(
        defaultEnvironment: .production,  // 设置为正式环境
        decryptionConfigs: [
            .production: decryptionConfig  // 为正式环境配置解密
        ]
    )
    
    // 打印当前配置
    print("✅ 当前环境: \(ZWBLogTap.shared.currentEnvironment.name)")
    if let config = EnvironmentManager.shared.getCurrentDecryptionConfig() {
        print("✅ 当前环境已配置解密")
        print("   - Key 长度: \(config.aesKey.count)")
        print("   - IV 长度: \(config.aesIV.count)")
        print("   - 字段名: \(config.encryptedFieldName)")
        print("   - 启用状态: \(config.enabled)")
    } else {
        print("⚠️ 当前环境未配置解密")
    }
    #endif
    
    return true
}
```

### 2. 检查控制台日志

运行应用后，在控制台搜索以下关键字：

#### 启动时的日志：
```
✅ 当前环境: 正式环境
✅ 当前环境已配置解密
🔐 [EnvironmentManager] 已为 正式环境 配置响应数据解密
```

#### 发起请求后的日志：
```
🔐 [EnvironmentManager] 检测到加密数据，字段名: ed
🔐 [EnvironmentManager] Base64 解码成功，加密数据大小: xxx 字节
🔐 [EnvironmentManager] Key 长度: 16, IV 长度: 16
🔐 [EnvironmentManager] AES 解密完成，解密数据大小: xxx 字节
✅ [EnvironmentManager] 解密成功，数据为有效的 JSON
```

### 3. 常见问题

#### 问题 1: 没有看到任何解密日志

**原因：** 当前环境没有配置解密

**解决：**
```swift
// 检查当前环境
print("当前环境: \(ZWBLogTap.shared.currentEnvironment)")

// 检查是否有解密配置
if let config = EnvironmentManager.shared.getCurrentDecryptionConfig() {
    print("有解密配置")
} else {
    print("没有解密配置 - 需要配置！")
}
```

#### 问题 2: 看到 "⚠️ 当前环境未配置解密"

**原因：** 配置的环境和当前环境不匹配

**解决：**
```swift
// 方案 1: 切换到配置了解密的环境
ZWBLogTap.shared.switchTo(environment: .production)

// 方案 2: 为当前环境配置解密
let config = ZWBLogTap.ResponseDecryptionConfig(
    aesKey: "your_key",
    aesIV: "your_iv"
)
EnvironmentManager.shared.setDecryptionConfig(for: .test, config: config)
```

#### 问题 3: 看到 "❌ 解密后的数据既不是 JSON 也不是有效的 UTF-8"

**原因：** Key 或 IV 不正确

**解决：**
1. 检查 Key 和 IV 是否正确
2. 确认 Key 长度为 16 字节（AES-128）
3. 确认 IV 长度为 16 字节

```swift
let key = "your_key"
let iv = "your_iv"

print("Key 长度: \(key.count) - 应该是 16")
print("IV 长度: \(iv.count) - 应该是 16")

// 如果不足 16 字节，需要补齐
let paddedKey = key.padding(toLength: 16, withPad: "\0", startingAt: 0)
let paddedIV = iv.padding(toLength: 16, withPad: "\0", startingAt: 0)
```

### 4. 完整测试代码

```swift
import ZWB_LogTap

class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        #if DEBUG
        setupDebugTools()
        #endif
        
        return true
    }
    
    func setupDebugTools() {
        // 你的 AES Key 和 IV（从 GMConst 或其他地方获取）
        let aesKey = "your_16_byte_key_"  // 替换为你的实际 Key
        let aesIV = "your_16_byte_iv__"   // 替换为你的实际 IV
        
        print("=== ZWB_LogTap 配置 ===")
        print("AES Key: \(aesKey)")
        print("AES IV: \(aesIV)")
        print("Key 长度: \(aesKey.count)")
        print("IV 长度: \(aesIV.count)")
        
        // 创建解密配置
        let decryptionConfig = ZWBLogTap.ResponseDecryptionConfig(
            aesKey: aesKey,
            aesIV: aesIV,
            encryptedFieldName: "ed",
            enabled: true
        )
        
        // 启动调试工具
        ZWBLogTap.start(
            defaultEnvironment: .production,  // 从正式环境开始
            decryptionConfigs: [
                .production: decryptionConfig  // 为正式环境配置解密
            ]
        )
        
        // 验证配置
        print("=== 配置验证 ===")
        print("当前环境: \(ZWBLogTap.shared.currentEnvironment.name)")
        
        if let config = EnvironmentManager.shared.getCurrentDecryptionConfig() {
            print("✅ 解密已配置")
            print("   - 启用: \(config.enabled)")
            print("   - 字段名: \(config.encryptedFieldName)")
        } else {
            print("❌ 解密未配置")
        }
        
        // 设置环境切换回调
        ZWBLogTap.shared.setEnvironmentSwitchCallback { env in
            print("🌍 环境已切换到: \(env.name)")
            if let config = EnvironmentManager.shared.getCurrentDecryptionConfig() {
                print("   ✅ 当前环境有解密配置")
            } else {
                print("   ⚠️ 当前环境无解密配置")
            }
        }
    }
}
```

### 5. 手动测试解密

如果还是不行，可以手动测试解密功能：

```swift
// 在某个地方添加测试代码
func testDecryption() {
    let testEncryptedJSON = """
    {"ed": "你的加密字符串"}
    """
    
    guard let data = testEncryptedJSON.data(using: .utf8) else {
        print("❌ 测试数据创建失败")
        return
    }
    
    let decrypted = EnvironmentManager.shared.decryptResponseData(data)
    
    if let string = String(data: decrypted, encoding: .utf8) {
        print("✅ 解密结果: \(string)")
    } else {
        print("❌ 解密失败")
    }
}
```

### 6. 检查响应格式

确认你的响应格式是否正确：

```json
{
  "ed": "base64_encoded_encrypted_string"
}
```

如果响应格式不是这样，需要修改 `encryptedFieldName` 参数。

### 7. 临时禁用解密测试

如果想确认是否是解密的问题，可以临时禁用：

```swift
let decryptionConfig = ZWBLogTap.ResponseDecryptionConfig(
    aesKey: "key",
    aesIV: "iv",
    enabled: false  // 禁用解密
)
```

这样会直接显示加密的原始数据。
