# ZWB_LogTap 项目结构

## 目录结构

```
ZWB_LogTap/
├── ZWB_LogTap/
│   └── Classes/
│       ├── Core/                          # 核心功能模块
│       │   ├── NetworkInterceptor.swift          # HTTP 拦截器
│       │   ├── NetworkInterceptorManager.swift   # 拦截管理器
│       │   ├── WebSocketInterceptor.swift        # WebSocket 拦截器
│       │   └── RuntimeHooker.swift               # Runtime Hook 工具
│       │
│       ├── Models/                        # 数据模型
│       │   ├── InterceptedRequest.swift          # HTTP 请求模型
│       │   └── WebSocketMessage.swift            # WebSocket 消息模型
│       │
│       ├── UI/                            # 用户界面
│       │   ├── FloatingButton.swift              # 悬浮按钮
│       │   ├── NetworkLogViewController.swift    # 日志列表页面
│       │   ├── NetworkLogCell.swift              # HTTP 日志单元格
│       │   ├── NetworkLogDetailViewController.swift  # HTTP 详情页面
│       │   ├── WebSocketMessageCell.swift        # WebSocket 消息单元格
│       │   └── WebSocketMessageDetailViewController.swift  # WebSocket 详情页面
│       │
│       └── ZWBLogTap.swift                # 主入口类
│
├── Example/                               # 示例项目
│   └── ZWB_LogTapExample/
│       ├── AppDelegate.swift
│       ├── ViewController.swift
│       └── Podfile
│
├── Screenshots/                           # 截图
│   ├── floating_button.png
│   ├── http_list.png
│   ├── http_detail.png
│   └── websocket.png
│
├── Docs/                                  # 文档
│   ├── API.md
│   ├── FAQ.md
│   └── CONTRIBUTING.md
│
├── ZWB_LogTap.podspec                     # CocoaPods 配置
├── README.md                              # 项目说明
├── README_CN.md                           # 中文说明
├── CHANGELOG.md                           # 更新日志
├── LICENSE                                # 许可证
├── QUICK_START.md                         # 快速开始
├── PROJECT_STRUCTURE.md                   # 项目结构（本文件）
└── .gitignore                             # Git 忽略文件

```

## 模块说明

### Core 模块

#### NetworkInterceptor.swift
- **功能**: HTTP/HTTPS 请求拦截
- **实现**: 基于 URLProtocol
- **职责**:
  - 拦截所有 URLSession 请求
  - 记录请求和响应数据
  - 管理拦截记录

#### NetworkInterceptorManager.swift
- **功能**: 拦截管理器
- **职责**:
  - 启动/停止拦截
  - 管理拦截记录
  - 提供数据访问接口
  - 导出 JSON

#### WebSocketInterceptor.swift
- **功能**: WebSocket 拦截
- **实现**: 基于 Method Swizzling
- **职责**:
  - Hook SocketRocket 方法
  - 记录 WebSocket 事件
  - 管理消息记录

#### RuntimeHooker.swift
- **功能**: Runtime Hook 工具
- **职责**:
  - 提供 Method Swizzling 功能
  - Hook URLSession 方法
  - Hook NSURLConnection（兼容旧代码）

### Models 模块

#### InterceptedRequest.swift
- **功能**: HTTP 请求数据模型
- **属性**:
  - 请求信息（URL、Method、Headers、Body）
  - 响应信息（StatusCode、Headers、Body）
  - 时间信息（开始时间、结束时间、耗时）
  - 错误信息
- **方法**:
  - JSON 格式化
  - 数据解析
  - 字符串转换

#### WebSocketMessage.swift
- **功能**: WebSocket 消息数据模型
- **属性**:
  - 消息类型（连接、发送、接收、断开、错误）
  - 消息内容
  - 时间戳
  - URL 信息
- **方法**:
  - 数据格式化
  - 大小计算
  - 预览生成

### UI 模块

#### FloatingButton.swift
- **功能**: 可拖拽的悬浮按钮
- **特性**:
  - 拖拽移动
  - 自动吸附边缘
  - 点击事件
  - 显示/隐藏动画

#### NetworkLogViewController.swift
- **功能**: 日志列表页面
- **特性**:
  - HTTP/IM 模式切换
  - 搜索功能
  - 过滤功能
  - 清空和导出

#### NetworkLogCell.swift
- **功能**: HTTP 日志列表单元格
- **显示**:
  - 请求方法和状态码
  - URL
  - 耗时
  - 时间

#### NetworkLogDetailViewController.swift
- **功能**: HTTP 日志详情页面
- **特性**:
  - 7 个标签页
  - JSON 格式化
  - 复制功能

#### WebSocketMessageCell.swift
- **功能**: WebSocket 消息列表单元格
- **显示**:
  - 消息类型
  - 时间
  - 内容预览
  - 数据大小

#### WebSocketMessageDetailViewController.swift
- **功能**: WebSocket 消息详情页面
- **特性**:
  - 基本信息展示
  - 消息内容展示
  - 复制功能

### 主入口

#### ZWBLogTap.swift
- **功能**: 统一的主入口类
- **职责**:
  - 启动/停止调试工具
  - 配置管理
  - 悬浮按钮管理
  - 提供公共 API

## 数据流

```
┌─────────────────┐
│   应用发起请求   │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ NetworkInterceptor│  ◄── URLProtocol 拦截
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ InterceptedRequest│  ◄── 数据模型
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ NetworkInterceptor│  ◄── 存储记录
│    Manager       │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ NetworkLogView  │  ◄── UI 展示
│   Controller    │
└─────────────────┘
```

## 技术栈

- **语言**: Swift 5.0
- **最低版本**: iOS 13.0
- **UI 框架**: UIKit
- **拦截技术**: 
  - URLProtocol (HTTP)
  - Method Swizzling (WebSocket)
- **数据存储**: 内存（数组）
- **线程**: 主线程 + 后台线程

## 设计模式

- **单例模式**: ZWBLogTap、NetworkInterceptorManager
- **代理模式**: URLProtocol、URLSessionDelegate
- **观察者模式**: NotificationCenter
- **工厂模式**: 创建拦截器实例
- **策略模式**: 不同类型的拦截策略

## 性能优化

1. **内存管理**
   - 限制最大记录数（默认 1000）
   - 自动清理旧记录
   - 使用弱引用避免循环引用

2. **线程安全**
   - 主线程更新 UI
   - 后台线程处理数据
   - 使用 DispatchQueue 同步

3. **懒加载**
   - 按需创建 UI 组件
   - 延迟加载详情数据

## 扩展性

### 添加新的拦截类型

1. 创建新的拦截器类（继承或实现协议）
2. 在 ZWBLogTap 中添加配置选项
3. 在 start() 方法中启动拦截
4. 创建对应的数据模型和 UI

### 添加新的 UI 功能

1. 在 UI 模块创建新的 ViewController
2. 在 NetworkLogViewController 中添加入口
3. 实现数据展示逻辑

### 添加新的导出格式

1. 在 NetworkInterceptorManager 中添加导出方法
2. 实现数据转换逻辑
3. 在 UI 中添加导出选项

## 测试

### 单元测试
- 测试拦截器功能
- 测试数据模型
- 测试工具方法

### 集成测试
- 测试完整的拦截流程
- 测试 UI 交互
- 测试数据导出

### 性能测试
- 测试大量请求的性能
- 测试内存占用
- 测试 UI 响应速度

## 维护指南

### 版本更新流程

1. 修改代码
2. 更新 CHANGELOG.md
3. 更新版本号（podspec）
4. 运行测试
5. 提交代码
6. 创建 Git tag
7. 发布到 CocoaPods

### 代码规范

- 使用 Swift 官方代码风格
- 添加必要的注释
- 使用有意义的变量名
- 保持函数简洁

### 文档维护

- 及时更新 README
- 记录重要变更
- 添加使用示例
- 回答常见问题

---

最后更新: 2026-03-04
