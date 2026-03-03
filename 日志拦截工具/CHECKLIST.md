# ✅ 安装检查清单

使用这个清单确保正确安装了所有组件。

---

## 📦 第一步：文件添加检查

### 核心功能文件（必须全部添加）

- [ ] NetworkInterceptor.swift (5.2K)
- [ ] InterceptedRequest.swift (3.1K)
- [ ] NetworkInterceptorManager.swift (3.4K)
- [ ] FloatingButton.swift (6.4K)
- [ ] NetworkLogViewController.swift (9.5K)
- [ ] NetworkLogCell.swift (5.5K)
- [ ] NetworkLogDetailViewController.swift (8.5K)

**验证方法：**
1. 在 Xcode 项目导航器中能看到这 7 个文件
2. 每个文件右侧的 Target Membership 已勾选
3. 文件图标是蓝色的（不是灰色）

---

## 🔧 第二步：配置文件更新检查

### AppDelegate.swift

- [ ] 已添加 `NetworkInterceptorManager.shared.startIntercepting()`
- [ ] 在 `didFinishLaunchingWithOptions` 方法中
- [ ] 在 `return true` 之前

**验证代码：**
```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    NetworkInterceptorManager.shared.startIntercepting()
    print("✅ 网络拦截已启动")
    return true
}
```

### SceneDelegate.swift

- [ ] 已添加属性 `var floatingButton: FloatingButton?`
- [ ] 已添加 `setupFloatingButton()` 方法
- [ ] 已添加 `showNetworkLog()` 方法
- [ ] 在 `scene(_:willConnectTo:options:)` 中调用 `setupFloatingButton()`

**验证代码：**
```swift
// 1. 属性
var floatingButton: FloatingButton?

// 2. scene 方法中
DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
    self.setupFloatingButton()
}

// 3. 两个新方法
private func setupFloatingButton() { ... }
private func showNetworkLog() { ... }
```

### ViewController.swift（可选）

- [ ] 已添加测试按钮（如果需要测试）
- [ ] 已添加测试网络请求方法

---

## 🔨 第三步：编译检查

### 编译测试

- [ ] 按 `Cmd + B` 编译项目
- [ ] 没有编译错误（红色）
- [ ] 没有严重警告（黄色）

**常见编译错误：**

❌ "Cannot find type 'NetworkInterceptor'"
→ 检查文件是否添加到 Target

❌ "Use of unresolved identifier 'NetworkInterceptorManager'"
→ 检查文件名是否正确

❌ "Missing return in a function expected to return 'Bool'"
→ 检查 AppDelegate 代码是否完整

---

## 🚀 第四步：运行检查

### 启动测试

- [ ] 按 `Cmd + R` 运行项目
- [ ] 应用成功启动
- [ ] 没有崩溃

### 控制台检查

- [ ] 控制台显示 "✅ 网络拦截已启动"
- [ ] 没有错误日志

**如果没有看到日志：**
1. 检查 AppDelegate 是否正确更新
2. 确保 print 语句存在
3. 查看控制台过滤器设置

---

## 🎯 第五步：功能检查

### 悬浮按钮检查

- [ ] 右下角能看到蓝色悬浮按钮 📊
- [ ] 按钮显示正常（不是空白）
- [ ] 按钮在最上层（不被遮挡）

**如果看不到按钮：**
1. 检查 SceneDelegate 是否正确更新
2. 在 `setupFloatingButton()` 中添加 print 调试
3. 确保 window 不为 nil

### 拖拽功能检查

- [ ] 可以拖拽按钮移动
- [ ] 松手后自动吸附到边缘
- [ ] 拖拽时有放大效果
- [ ] 移动流畅无卡顿

**如果无法拖拽：**
1. 检查 FloatingButton.swift 是否完整
2. 确保手势识别器正确添加
3. 检查是否有其他视图遮挡

### 点击功能检查

- [ ] 点击按钮后按钮隐藏
- [ ] 点击时有缩小动画
- [ ] 隐藏动画流畅

**如果点击无反应：**
1. 检查 `onTap` 回调是否设置
2. 在回调中添加 print 调试
3. 确保按钮的 isUserInteractionEnabled 为 true

### 长按功能检查

- [ ] 长按按钮（0.5 秒）
- [ ] 有震动反馈
- [ ] 显示日志列表页面
- [ ] 页面全屏显示

**如果长按无反应：**
1. 检查 `onLongPress` 回调是否设置
2. 确保长按时间足够（至少 0.5 秒）
3. 在回调中添加 print 调试

---

## 📋 第六步：日志列表检查

### 界面检查

- [ ] 顶部有工具栏（关闭、清空、导出）
- [ ] 有搜索框
- [ ] 有过滤器（全部、GET、POST、成功、失败）
- [ ] 有列表区域

### 功能检查

- [ ] 点击"关闭"按钮可以关闭页面
- [ ] 点击"清空"按钮弹出确认对话框
- [ ] 点击"导出"按钮显示分享菜单

---

## 🌐 第七步：网络拦截检查

### 发起测试请求

方式 1：使用测试按钮（如果添加了 ViewController_Updated）
- [ ] 点击"测试网络请求"按钮
- [ ] 等待 1-2 秒

方式 2：手动发起请求
```swift
let url = URL(string: "https://api.github.com/users/apple")!
URLSession.shared.dataTask(with: url) { _, _, _ in }.resume()
```

### 查看拦截结果

- [ ] 长按悬浮按钮打开日志列表
- [ ] 能看到刚才的请求
- [ ] 显示请求方法（GET/POST）
- [ ] 显示状态码（200）
- [ ] 显示 URL
- [ ] 显示时间和耗时

**如果看不到请求：**
1. 检查控制台是否有 "✅ 网络拦截已启动"
2. 确保使用 URLSession 发起请求
3. 检查 NetworkInterceptor 的 canInit 方法

---

## 📱 第八步：详情页面检查

### 打开详情

- [ ] 点击列表中的某个请求
- [ ] 显示详情页面
- [ ] 页面全屏显示

### 标签页检查

- [ ] 有 7 个标签页
- [ ] 默认显示"基本信息"
- [ ] 可以切换标签页
- [ ] 每个标签页显示对应内容

### 内容检查

- [ ] 基本信息：显示时间、状态码、耗时等
- [ ] URL 信息：显示完整 URL 和参数
- [ ] 请求 Headers：显示所有请求头
- [ ] 请求 Body：显示请求体（如果有）
- [ ] 响应 Headers：显示所有响应头
- [ ] 响应 Body：显示响应体，JSON 自动格式化
- [ ] 异常信息：显示错误（如果有）

---

## 🔍 第九步：搜索过滤检查

### 搜索功能

- [ ] 在搜索框输入关键词
- [ ] 列表实时过滤
- [ ] 显示匹配的结果
- [ ] 清空搜索框恢复所有结果

### 过滤功能

- [ ] 选择"GET"过滤器，只显示 GET 请求
- [ ] 选择"POST"过滤器，只显示 POST 请求
- [ ] 选择"成功"过滤器，只显示 2xx 状态码
- [ ] 选择"失败"过滤器，只显示 4xx/5xx 状态码
- [ ] 选择"全部"恢复所有结果

### 组合过滤

- [ ] 搜索 + 过滤器可以同时使用
- [ ] 结果正确

---

## 📤 第十步：导出功能检查

### 导出测试

- [ ] 点击"导出"按钮
- [ ] 显示分享菜单
- [ ] 可以选择分享方式
- [ ] 导出的是 JSON 格式

### JSON 格式检查

导出的 JSON 应该包含：
- [ ] 请求 URL
- [ ] 请求方法
- [ ] 请求 Headers
- [ ] 响应状态码
- [ ] 响应 Headers
- [ ] 请求和响应 Body

---

## 🎨 第十一步：UI 检查

### 颜色检查

- [ ] GET 请求显示蓝色
- [ ] POST 请求显示绿色
- [ ] 2xx 状态码显示绿色
- [ ] 4xx 状态码显示红色
- [ ] 5xx 状态码显示紫色

### 动画检查

- [ ] 悬浮按钮拖拽有动画
- [ ] 点击按钮有动画
- [ ] 页面切换有动画
- [ ] 所有动画流畅

### 深色模式检查

- [ ] 切换到深色模式
- [ ] 界面正常显示
- [ ] 文字清晰可读
- [ ] 颜色对比度合适

---

## ⚡ 第十二步：性能检查

### 内存检查

- [ ] 打开 Xcode 的 Memory Debug
- [ ] 拦截 100 个请求
- [ ] 内存占用正常（< 50MB）
- [ ] 没有内存泄漏

### 响应速度检查

- [ ] 列表滚动流畅（60 FPS）
- [ ] 搜索过滤实时响应
- [ ] 页面切换无卡顿
- [ ] 拖拽按钮流畅

### 网络延迟检查

- [ ] 拦截不影响正常请求
- [ ] 延迟在可接受范围（< 50ms）
- [ ] 应用响应正常

---

## 🐛 第十三步：边界情况检查

### 空数据检查

- [ ] 清空所有日志
- [ ] 列表显示空状态
- [ ] 不会崩溃

### 大量数据检查

- [ ] 拦截 100+ 个请求
- [ ] 列表正常显示
- [ ] 滚动流畅
- [ ] 内存正常

### 错误请求检查

- [ ] 发起一个会失败的请求
- [ ] 能正常拦截
- [ ] 显示错误信息
- [ ] 不会崩溃

### 特殊字符检查

- [ ] URL 包含中文
- [ ] Body 包含特殊字符
- [ ] 正常显示
- [ ] 不会乱码

---

## 📊 完成度统计

### 必须完成（核心功能）

- [ ] 文件添加（7 个文件）
- [ ] 配置更新（AppDelegate + SceneDelegate）
- [ ] 编译成功
- [ ] 运行成功
- [ ] 悬浮按钮显示
- [ ] 网络拦截工作
- [ ] 日志列表显示
- [ ] 详情页面显示

**完成度：__ / 8**

### 建议完成（增强功能）

- [ ] 拖拽功能
- [ ] 搜索功能
- [ ] 过滤功能
- [ ] 导出功能
- [ ] 深色模式
- [ ] 性能优化

**完成度：__ / 6**

### 可选完成（高级功能）

- [ ] 自定义样式
- [ ] 添加过滤规则
- [ ] 性能监控
- [ ] 单元测试

**完成度：__ / 4**

---

## 🎯 总体评分

### 评分标准

- ✅ 所有必须项完成：**及格**（可以使用）
- ✅ 必须项 + 建议项完成：**良好**（功能完整）
- ✅ 全部完成：**优秀**（完美集成）

### 你的评分

- 必须完成：__ / 8
- 建议完成：__ / 6
- 可选完成：__ / 4
- **总计：__ / 18**

---

## 🔧 问题排查

如果某项检查失败，请参考：

1. **[INSTALLATION_GUIDE.md](INSTALLATION_GUIDE.md)** - 常见问题排查
2. **[QUICK_START.md](QUICK_START.md)** - 快速开始指南
3. **[README.md](README.md)** - 完整功能说明

---

## ✅ 验证通过

当所有必须项都完成后：

**🎉 恭喜！你已经成功集成了 iOS 网络日志拦截工具！**

现在可以：
- 📱 在实际项目中使用
- 🔍 调试网络请求
- 🐛 排查网络问题
- 📊 分析性能数据

---

## 📝 备注

- 日期：__________
- 项目名称：__________
- 集成人：__________
- 遇到的问题：__________
- 解决方案：__________

---

**祝你使用愉快！🚀**
