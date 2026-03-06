# 环境切换功能使用指南

## 功能概述

ZWB_LogTap 现在支持环境切换功能，可以在测试环境和正式环境之间快速切换。

## 特性

1. **入口按钮颜色区分**
   - 测试环境：蓝色按钮
   - 正式环境：红色按钮

2. **工具页面入口**
   - 在"调试工具"页面顶部新增"环境配置"分组
   - 显示当前环境状态
   - 点击可切换环境

3. **回调机制**
   - 提供闭包回调，用户可自定义切换后的逻辑
   - 支持在任何地方响应环境切换事件

## 使用方法

### 1. 启动时设置默认环境

```swift
// 方式一：使用默认配置（默认为测试环境）
ZWBLogTap.shared.start()

// 方式二：指定默认环境
ZWBLogTap.start(defaultEnvironment: .test)  // 测试环境
ZWBLogTap.start(defaultEnvironment: .production)  // 正式环境

// 方式三：使用完整配置
var config = ZWBLogTap.Configuration()
config.defaultEnvironment = .production
ZWBLogTap.shared.start(with: config)
```

### 2. 设置环境切换回调

```swift
// 在 AppDelegate 或启动时设置
ZWBLogTap.shared.setEnvironmentSwitchCallback { newEnvironment in
    print("环境已切换到: \(newEnvironment.name)")
    
    // 根据新环境执行相应操作
    switch newEnvironment {
    case .test:
        // 切换到测试环境的逻辑
        APIManager.shared.baseURL = "https://test-api.example.com"
        print("✅ 已切换到测试环境")
        
    case .production:
        // 切换到正式环境的逻辑
        APIManager.shared.baseURL = "https://api.example.com"
        print("✅ 已切换到正式环境")
        
    case .custom(let name):
        // 自定义环境
        print("✅ 已切换到自定义环境: \(name)")
    }
    
    // 可以在这里重新初始化网络层、清空缓存等
    // NetworkManager.shared.reinitialize()
    // CacheManager.shared.clearAll()
}
```

### 3. 用户操作流程

1. 点击悬浮按钮（蓝色=测试环境，红色=正式环境）
2. 进入"调试工具"页面
3. 点击"环境切换"选项
4. 确认切换
5. 悬浮按钮颜色自动更新
6. 回调函数被触发，执行自定义逻辑

### 4. 代码中主动切换环境

```swift
// 切换到相反的环境（测试↔正式）
ZWBLogTap.shared.switchEnvironment()

// 切换到指定环境
ZWBLogTap.shared.switchTo(environment: .test)
ZWBLogTap.shared.switchTo(environment: .production)

// 获取当前环境
let currentEnv = ZWBLogTap.shared.currentEnvironment
print("当前环境: \(currentEnv.name)")
```

## 环境类型

```swift
public enum Environment {
    case test           // 测试环境（蓝色按钮）
    case production     // 正式环境（红色按钮）
    case custom(String) // 自定义环境（橙色按钮）
}
```

## 完整示例

```swift
// AppDelegate.swift
import UIKit
import ZWB_LogTap

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, 
                    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        #if DEBUG
        // 启动调试工具，默认测试环境
        ZWBLogTap.start(defaultEnvironment: .test)
        
        // 设置环境切换回调
        ZWBLogTap.shared.setEnvironmentSwitchCallback { newEnvironment in
            self.handleEnvironmentSwitch(to: newEnvironment)
        }
        #endif
        
        return true
    }
    
    private func handleEnvironmentSwitch(to environment: EnvironmentManager.Environment) {
        switch environment {
        case .test:
            // 测试环境配置
            NetworkConfig.baseURL = "https://test-api.example.com"
            NetworkConfig.apiKey = "test_api_key"
            print("🔵 已切换到测试环境")
            
        case .production:
            // 正式环境配置
            NetworkConfig.baseURL = "https://api.example.com"
            NetworkConfig.apiKey = "production_api_key"
            print("🔴 已切换到正式环境")
            
        case .custom(let name):
            print("🟠 已切换到自定义环境: \(name)")
        }
        
        // 重新初始化网络层
        NetworkManager.shared.reinitialize()
        
        // 清空缓存
        CacheManager.shared.clearAll()
        
        // 显示提示
        showEnvironmentSwitchAlert(environment: environment)
    }
    
    private func showEnvironmentSwitchAlert(environment: EnvironmentManager.Environment) {
        DispatchQueue.main.async {
            guard let window = UIApplication.shared.windows.first,
                  let rootVC = window.rootViewController else { return }
            
            let alert = UIAlertController(
                title: "环境已切换",
                message: "当前环境: \(environment.name)\n\n应用将重新加载数据",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "确定", style: .default))
            
            var topVC = rootVC
            while let presented = topVC.presentedViewController {
                topVC = presented
            }
            topVC.present(alert, animated: true)
        }
    }
}
```

## 注意事项

1. **环境切换是全局的**：切换后会影响整个应用
2. **回调在主线程执行**：可以安全地更新 UI
3. **建议在回调中**：
   - 更新 API 基础 URL
   - 重新初始化网络层
   - 清空缓存数据
   - 重新加载必要的数据
4. **按钮颜色**：
   - 蓝色 = 测试环境
   - 红色 = 正式环境
   - 橙色 = 自定义环境

## 高级用法

### 自定义环境

```swift
// 定义自定义环境
let stagingEnv = EnvironmentManager.Environment.custom("预发布环境")

// 切换到自定义环境
ZWBLogTap.shared.switchTo(environment: stagingEnv)
```

### 环境持久化

```swift
// 保存当前环境到 UserDefaults
func saveCurrentEnvironment() {
    let env = ZWBLogTap.shared.currentEnvironment
    switch env {
    case .test:
        UserDefaults.standard.set("test", forKey: "app_environment")
    case .production:
        UserDefaults.standard.set("production", forKey: "app_environment")
    case .custom(let name):
        UserDefaults.standard.set(name, forKey: "app_environment")
    }
}

// 启动时恢复环境
func restoreEnvironment() {
    guard let envString = UserDefaults.standard.string(forKey: "app_environment") else {
        return
    }
    
    let environment: EnvironmentManager.Environment
    switch envString {
    case "test":
        environment = .test
    case "production":
        environment = .production
    default:
        environment = .custom(envString)
    }
    
    ZWBLogTap.shared.switchTo(environment: environment)
}
```

## 总结

环境切换功能提供了一个简单而强大的方式来管理不同环境的配置。通过可视化的按钮颜色和灵活的回调机制，开发者可以轻松地在测试和正式环境之间切换，提高开发和测试效率。
