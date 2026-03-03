# 项目结构说明

## 文件清单

### 📦 核心网络拦截模块

#### 1. NetworkInterceptor.swift
**功能：** 网络拦截核心类
- 基于 URLProtocol 实现
- 拦截所有 URLSession 请求
- 记录请求和响应数据
- 支持异步数据接收
- 发送通知更新 UI

**关键方法：**
- `canInit(with:)` - 判断是否拦截该请求
- `startLoading()` - 开始拦截并记录请求
- `stopLoading()` - 停止拦截
- URLSessionDataDelegate 方法 - 处理响应数据

#### 2. InterceptedRequest.swift
**功能：** 拦截请求数据模型
- 存储请求和响应的完整信息
- 提供数据格式化方法
- 计算请求耗时
- JSON 自动解析和格式化

**主要属性：**
- 请求信息：url, method, headers, body
- 响应信息：statusCode, responseHeaders, responseData
- 时间信息：startTime, endTime, duration
- 错误信息：error

**辅助方法：**
- `responseJSONString` - 格式化 JSON 响应
- `requestBodyString` - 格式化请求体
- `queryParameters` - 解析 URL 参数

#### 3. NetworkInterceptorManager.swift
**功能：** 拦截管理器（单例）
- 启动/停止网络拦截
- 管理拦截记录
- 提供过滤和搜索功能
- 导出日志为 JSON

**主要方法：**
- `startIntercepting()` - 启动拦截
- `stopIntercepting()` - 停止拦截
- `getAllRequests()` - 获取所有记录
- `clearAllRequests()` - 清空记录
- `filterRequests()` - 过滤记录
- `exportToJSON()` - 导出 JSON

---

### 🎨 UI 模块

#### 4. FloatingButton.swift
**功能：** 可拖拽的悬浮按钮
- 支持拖拽移动
- 自动吸附到屏幕边缘
- 点击和长按手势识别
- 显示/隐藏动画效果
- 震动反馈

**手势处理：**
- `handlePan()` - 拖拽手势
- `handleTap()` - 点击手势（隐藏按钮）
- `handleLongPress()` - 长按手势（显示日志）

**动画效果：**
- 拖拽时放大
- 点击时缩小
- 显示/隐藏渐变
- 吸附边缘弹性动画

#### 5. NetworkLogViewController.swift
**功能：** 网络日志列表页面
- 显示所有拦截的请求
- 搜索功能
- 过滤功能（全部/GET/POST/成功/失败）
- 清空和导出功能
- 实时更新

**UI 组件：**
- 顶部工具栏（关闭、清空、导出）
- 搜索框
- 过滤分段控制器
- 请求列表 TableView

**功能方法：**
- `loadData()` - 加载数据
- `applyFilters()` - 应用过滤条件
- `clearTapped()` - 清空日志
- `exportTapped()` - 导出日志

#### 6. NetworkLogCell.swift
**功能：** 日志列表单元格
- 显示请求方法（GET/POST 等）
- 显示状态码（带颜色标识）
- 显示 URL
- 显示时间和耗时

**颜色方案：**
- GET - 蓝色
- POST - 绿色
- PUT - 橙色
- DELETE - 红色
- 状态码 2xx - 绿色
- 状态码 3xx - 橙色
- 状态码 4xx - 红色
- 状态码 5xx - 紫色

#### 7. NetworkLogDetailViewController.swift
**功能：** 日志详情页面
- 7 个标签页展示详细信息
- 支持滚动查看长内容
- JSON 自动格式化显示
- 等宽字体显示代码

**标签页：**
1. 基本信息 - 时间、路由、方法、状态码、耗时
2. URL信息 - 完整 URL 和参数
3. 请求Headers - 所有请求头
4. 请求Body - 请求体内容
5. 响应Headers - 所有响应头
6. 响应Body - 响应体内容
7. 异常信息 - 错误信息

---

### 🔧 配置文件

#### 8. AppDelegate_Updated.swift
**功能：** 应用启动配置
- 启动网络拦截器
- 应用生命周期管理

**关键代码：**
```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    NetworkInterceptorManager.shared.startIntercepting()
    return true
}
```

#### 9. SceneDelegate_Updated.swift
**功能：** 场景管理和悬浮按钮
- 创建和管理悬浮按钮
- 处理按钮点击和长按事件
- 显示日志页面

**关键方法：**
- `setupFloatingButton()` - 创建悬浮按钮
- `showNetworkLog()` - 显示日志页面

#### 10. ViewController_Updated.swift
**功能：** 主页面（测试用）
- 测试网络请求功能
- 演示如何使用工具

**测试请求：**
- GET 请求 - GitHub API
- POST 请求 - httpbin.org

---

## 架构设计

```
┌─────────────────────────────────────────────────────────┐
│                     应用层 (App Layer)                    │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │ AppDelegate  │  │SceneDelegate │  │ViewController│  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
└─────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────┐
│                     UI 层 (UI Layer)                      │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │FloatingButton│  │  LogListVC   │  │ LogDetailVC  │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
│                    ┌──────────────┐                      │
│                    │ NetworkLogCell│                      │
│                    └──────────────┘                      │
└─────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────┐
│                  业务层 (Business Layer)                  │
│              ┌──────────────────────────┐                │
│              │NetworkInterceptorManager │                │
│              └──────────────────────────┘                │
└─────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────┐
│                   核心层 (Core Layer)                     │
│  ┌──────────────┐              ┌──────────────┐         │
│  │NetworkInterceptor│          │InterceptedRequest│      │
│  │  (URLProtocol) │            │   (Model)    │         │
│  └──────────────┘              └──────────────┘         │
└─────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────┐
│                 系统层 (System Layer)                     │
│                      URLSession                           │
│                      URLProtocol                          │
└─────────────────────────────────────────────────────────┘
```

## 数据流

### 1. 网络请求拦截流程
```
URLSession 发起请求
    ↓
URLProtocol.canInit() 判断是否拦截
    ↓
NetworkInterceptor.startLoading() 开始拦截
    ↓
记录请求信息 → InterceptedRequest
    ↓
执行实际网络请求
    ↓
接收响应数据
    ↓
更新 InterceptedRequest
    ↓
发送通知 → UI 更新
```

### 2. UI 交互流程
```
用户长按悬浮按钮
    ↓
触发 onLongPress 回调
    ↓
SceneDelegate.showNetworkLog()
    ↓
创建 NetworkLogViewController
    ↓
加载数据 → NetworkInterceptorManager.getAllRequests()
    ↓
显示列表
    ↓
用户点击列表项
    ↓
显示 NetworkLogDetailViewController
```

## 依赖关系

```
AppDelegate
    └── NetworkInterceptorManager

SceneDelegate
    ├── FloatingButton
    └── NetworkLogViewController

NetworkLogViewController
    ├── NetworkInterceptorManager
    ├── NetworkLogCell
    └── NetworkLogDetailViewController

NetworkLogDetailViewController
    └── InterceptedRequest

NetworkInterceptor
    ├── InterceptedRequest
    └── URLProtocol (系统)

NetworkInterceptorManager
    └── NetworkInterceptor
```

## 通知机制

### networkRequestIntercepted
- **发送者：** NetworkInterceptor
- **接收者：** NetworkLogViewController
- **时机：** 
  - 新请求被拦截时
  - 响应数据接收完成时
  - 请求发生错误时
- **用途：** 实时更新 UI

## 内存管理

### 数据存储
- 最大记录数：1000 条（可配置）
- 存储位置：内存（静态数组）
- 清理策略：FIFO（先进先出）

### 生命周期
- NetworkInterceptor：每个请求创建一个实例
- NetworkInterceptorManager：单例，应用生命周期
- FloatingButton：SceneDelegate 持有，场景生命周期
- ViewController：按需创建和销毁

## 性能考虑

### 优化点
1. 使用 DispatchQueue.main.async 避免阻塞主线程
2. 限制最大记录数避免内存溢出
3. 使用 UITableView 复用机制
4. JSON 解析采用懒加载
5. 大数据使用 NSData 而非 String

### 注意事项
- 拦截会增加网络请求延迟（约 10-50ms）
- 大量请求会占用内存
- 建议仅在 Debug 模式启用

## 扩展性

### 可扩展点
1. 添加更多过滤条件
2. 支持导出其他格式（CSV、HTML）
3. 添加请求重放功能
4. 支持修改请求/响应
5. 添加统计分析功能
6. 支持 WebSocket 拦截
7. 添加请求对比功能

### 自定义配置
- 悬浮按钮样式
- 最大记录数
- 过滤规则
- UI 主题颜色
- 导出格式

## 文件大小

| 文件 | 行数 | 功能 |
|------|------|------|
| NetworkInterceptor.swift | ~130 | 核心拦截 |
| InterceptedRequest.swift | ~100 | 数据模型 |
| NetworkInterceptorManager.swift | ~100 | 管理器 |
| FloatingButton.swift | ~180 | 悬浮按钮 |
| NetworkLogViewController.swift | ~230 | 列表页面 |
| NetworkLogCell.swift | ~130 | 列表单元格 |
| NetworkLogDetailViewController.swift | ~200 | 详情页面 |
| **总计** | **~1070** | **完整功能** |

## 总结

这是一个功能完整、架构清晰的 iOS 网络拦截工具：
- ✅ 模块化设计，易于维护
- ✅ 职责分离，代码清晰
- ✅ 性能优化，用户体验好
- ✅ 扩展性强，易于定制
- ✅ 文档完善，易于使用
