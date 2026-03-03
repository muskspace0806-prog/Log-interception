# 安装指南

## 快速安装步骤

### 步骤 1: 将新文件添加到 Xcode 项目

1. 打开 Xcode 项目
2. 在项目导航器中，右键点击"日志拦截工具"文件夹
3. 选择 "Add Files to '日志拦截工具'..."
4. 选择以下文件并添加：
   - `NetworkInterceptor.swift`
   - `InterceptedRequest.swift`
   - `NetworkInterceptorManager.swift`
   - `FloatingButton.swift`
   - `NetworkLogViewController.swift`
   - `NetworkLogCell.swift`
   - `NetworkLogDetailViewController.swift`

### 步骤 2: 更新现有文件

#### 2.1 更新 AppDelegate.swift

打开 `AppDelegate.swift`，将 `didFinishLaunchingWithOptions` 方法替换为：

```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // 启动网络拦截
    NetworkInterceptorManager.shared.startIntercepting()
    print("✅ 网络拦截已启动")
    
    return true
}
```

#### 2.2 更新 SceneDelegate.swift

打开 `SceneDelegate.swift`，添加以下内容：

1. 在类中添加属性：
```swift
var floatingButton: FloatingButton?
```

2. 更新 `scene(_:willConnectTo:options:)` 方法：
```swift
func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let windowScene = (scene as? UIWindowScene) else { return }
    
    // 延迟显示悬浮按钮（等待视图层级建立）
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        self.setupFloatingButton()
    }
}
```

3. 添加以下方法：
```swift
private func setupFloatingButton() {
    guard let window = window else { return }
    
    // 创建悬浮按钮
    floatingButton = FloatingButton()
    
    // 点击事件 - 隐藏按钮
    floatingButton?.onTap = { [weak self] in
        self?.floatingButton?.hide()
    }
    
    // 长按事件 - 显示日志页面
    floatingButton?.onLongPress = { [weak self] in
        self?.showNetworkLog()
    }
    
    // 显示按钮
    floatingButton?.show(in: window)
}

private func showNetworkLog() {
    guard let rootVC = window?.rootViewController else { return }
    
    let logVC = NetworkLogViewController()
    logVC.modalPresentationStyle = .fullScreen
    
    // 找到最顶层的 ViewController
    var topVC = rootVC
    while let presented = topVC.presentedViewController {
        topVC = presented
    }
    
    topVC.present(logVC, animated: true) { [weak self] in
        // 显示日志页面后，重新显示悬浮按钮
        if let button = self?.floatingButton, button.superview == nil {
            self?.setupFloatingButton()
        }
    }
}
```

#### 2.3 更新 ViewController.swift（可选 - 用于测试）

打开 `ViewController.swift`，可以参考 `ViewController_Updated.swift` 添加测试按钮。

### 步骤 3: 编译和运行

1. 按 `Cmd + B` 编译项目
2. 如果有编译错误，检查：
   - 所有文件是否正确添加到 Target
   - 文件名是否正确
   - 代码是否完整复制

3. 按 `Cmd + R` 运行项目

### 步骤 4: 测试功能

1. 应用启动后，应该能看到右下角的蓝色悬浮按钮（📊）
2. 尝试拖拽按钮到不同位置
3. 点击按钮 → 按钮应该隐藏
4. 长按按钮 → 应该显示网络日志列表
5. 如果有测试按钮，点击"测试网络请求"
6. 长按悬浮按钮查看拦截到的请求

## 常见问题排查

### 问题 1: 编译错误 "Cannot find type 'NetworkInterceptor'"

**解决方案：**
- 确保所有 `.swift` 文件都添加到了项目中
- 在 Xcode 左侧项目导航器中检查文件是否有正确的 Target 成员关系
- 右键点击文件 → "Show File Inspector" → 确保 "Target Membership" 中勾选了你的 Target

### 问题 2: 看不到悬浮按钮

**解决方案：**
- 检查 SceneDelegate 是否正确更新
- 确保 `setupFloatingButton()` 方法被调用
- 在 `setupFloatingButton()` 中添加断点调试
- 检查 window 是否为 nil

### 问题 3: 拦截不到网络请求

**解决方案：**
- 检查 AppDelegate 中是否调用了 `NetworkInterceptorManager.shared.startIntercepting()`
- 在控制台查看是否有 "✅ 网络拦截已启动" 的日志
- 确保使用的是 URLSession 发起的请求

### 问题 4: 悬浮按钮无法拖拽

**解决方案：**
- 检查 FloatingButton.swift 是否完整添加
- 确保手势识别器正确设置
- 检查是否有其他视图遮挡了按钮

### 问题 5: 点击/长按没有反应

**解决方案：**
- 检查 SceneDelegate 中的回调是否正确设置
- 在回调方法中添加 print 语句调试
- 确保 `onTap` 和 `onLongPress` 闭包被正确赋值

## 手动复制代码方式

如果你更喜欢手动复制代码，可以：

1. 在 Xcode 中创建新的 Swift 文件（Cmd + N）
2. 选择 "Swift File"
3. 命名为对应的文件名（如 NetworkInterceptor）
4. 打开生成的文件，删除所有内容
5. 从对应的 `.swift` 文件中复制完整代码
6. 粘贴到新创建的文件中
7. 保存（Cmd + S）

对以下文件重复此过程：
- NetworkInterceptor.swift
- InterceptedRequest.swift
- NetworkInterceptorManager.swift
- FloatingButton.swift
- NetworkLogViewController.swift
- NetworkLogCell.swift
- NetworkLogDetailViewController.swift

## 验证安装

安装完成后，运行以下检查：

### ✅ 检查清单

- [ ] 所有 7 个新文件已添加到项目
- [ ] AppDelegate.swift 已更新
- [ ] SceneDelegate.swift 已更新
- [ ] 项目可以成功编译（无错误）
- [ ] 运行后能看到悬浮按钮
- [ ] 悬浮按钮可以拖拽
- [ ] 点击悬浮按钮可以隐藏
- [ ] 长按悬浮按钮显示日志列表
- [ ] 控制台显示 "✅ 网络拦截已启动"

## 下一步

安装完成后，可以：

1. 阅读 `README.md` 了解详细功能
2. 自定义悬浮按钮的样式和位置
3. 添加自定义过滤规则
4. 集成到你的实际项目中

## 需要帮助？

如果遇到问题：
1. 检查 Xcode 控制台的错误信息
2. 确保所有代码完整复制
3. 重新检查安装步骤
4. 清理项目（Cmd + Shift + K）后重新编译

祝你使用愉快！🎉
