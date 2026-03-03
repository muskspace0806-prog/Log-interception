# 快速开始指南 ⚡️

## 5 分钟快速集成

### 第一步：添加文件（2 分钟）

在 Xcode 中，将以下 7 个文件拖入项目：

```
✅ NetworkInterceptor.swift
✅ InterceptedRequest.swift  
✅ NetworkInterceptorManager.swift
✅ FloatingButton.swift
✅ NetworkLogViewController.swift
✅ NetworkLogCell.swift
✅ NetworkLogDetailViewController.swift
```

**提示：** 确保勾选 "Copy items if needed" 和你的 Target

---

### 第二步：更新 AppDelegate（1 分钟）

打开 `AppDelegate.swift`，在 `didFinishLaunchingWithOptions` 方法中添加：

```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
    // 👇 添加这两行
    NetworkInterceptorManager.shared.startIntercepting()
    print("✅ 网络拦截已启动")
    
    return true
}
```

---

### 第三步：更新 SceneDelegate（2 分钟）

打开 `SceneDelegate.swift`：

#### 3.1 添加属性
在类的顶部添加：
```swift
var floatingButton: FloatingButton?
```

#### 3.2 更新 scene 方法
```swift
func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let windowScene = (scene as? UIWindowScene) else { return }
    
    // 👇 添加这段代码
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        self.setupFloatingButton()
    }
}
```

#### 3.3 添加两个方法
在类的底部添加：
```swift
private func setupFloatingButton() {
    guard let window = window else { return }
    
    floatingButton = FloatingButton()
    
    floatingButton?.onTap = { [weak self] in
        self?.floatingButton?.hide()
    }
    
    floatingButton?.onLongPress = { [weak self] in
        self?.showNetworkLog()
    }
    
    floatingButton?.show(in: window)
}

private func showNetworkLog() {
    guard let rootVC = window?.rootViewController else { return }
    
    let logVC = NetworkLogViewController()
    logVC.modalPresentationStyle = .fullScreen
    
    var topVC = rootVC
    while let presented = topVC.presentedViewController {
        topVC = presented
    }
    
    topVC.present(logVC, animated: true) { [weak self] in
        if let button = self?.floatingButton, button.superview == nil {
            self?.setupFloatingButton()
        }
    }
}
```

---

### 第四步：运行测试 ✨

1. 按 `Cmd + B` 编译
2. 按 `Cmd + R` 运行
3. 看到右下角的蓝色悬浮按钮 📊
4. 长按按钮查看网络日志

---

## 验证安装

运行后检查：

- [ ] 控制台显示 "✅ 网络拦截已启动"
- [ ] 右下角有蓝色悬浮按钮
- [ ] 可以拖拽按钮
- [ ] 点击按钮会隐藏
- [ ] 长按按钮显示日志列表

---

## 测试网络拦截

在任意 ViewController 中发起网络请求：

```swift
// 测试 GET 请求
let url = URL(string: "https://api.github.com/users/apple")!
URLSession.shared.dataTask(with: url) { data, response, error in
    print("请求完成")
}.resume()
```

然后长按悬浮按钮，应该能看到这个请求！

---

## 常见问题

### ❌ 编译错误：Cannot find type 'NetworkInterceptor'
**解决：** 检查文件是否正确添加到 Target
- 选中文件 → 右侧面板 → Target Membership → 勾选你的 Target

### ❌ 看不到悬浮按钮
**解决：** 检查 SceneDelegate 是否正确更新
- 确保 `setupFloatingButton()` 被调用
- 在方法中添加 `print("创建悬浮按钮")` 调试

### ❌ 拦截不到请求
**解决：** 检查 AppDelegate 是否启动拦截
- 查看控制台是否有 "✅ 网络拦截已启动"
- 确保使用 URLSession 发起请求

---

## 下一步

✅ 安装完成后，可以：

1. 📖 阅读 [README.md](README.md) 了解完整功能
2. 🎨 自定义悬浮按钮样式和位置
3. 🔧 添加自定义过滤规则
4. 📱 集成到你的实际项目中

---

## 完整代码参考

如果不确定代码是否正确，可以参考：
- `AppDelegate_Updated.swift` - 完整的 AppDelegate
- `SceneDelegate_Updated.swift` - 完整的 SceneDelegate
- `ViewController_Updated.swift` - 测试页面示例

---

## 需要帮助？

- 📚 详细安装步骤：[INSTALLATION_GUIDE.md](INSTALLATION_GUIDE.md)
- 🏗️ 项目架构说明：[PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md)
- 📋 文件清单：[FILES_SUMMARY.txt](FILES_SUMMARY.txt)

---

**🎉 恭喜！你已经成功集成了 iOS 网络日志拦截工具！**

现在可以愉快地调试网络请求了！
