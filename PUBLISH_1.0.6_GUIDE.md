# ZWB_LogTap 1.0.6 发布指南

## 准备工作检查清单

- [x] 版本号已更新为 1.0.6
  - [x] ZWB_LogTap.podspec
  - [x] README.md
- [x] CHANGELOG.md 已更新
- [x] 截图已更新
- [x] README.md 截图路径已更新
- [x] 所有代码已同步
- [x] 发布脚本已创建

## 发布步骤

### 方式一：使用自动化脚本（推荐）

```bash
./release_1.0.6.sh
```

脚本会自动完成：
1. ✅ 检查 Git 状态
2. ✅ 确认版本号
3. ✅ 同步文件
4. ✅ 提交代码
5. ✅ 创建标签
6. ✅ 推送到 GitHub
7. ✅ 验证 podspec
8. ✅ 发布到 CocoaPods（可选）

### 方式二：手动发布

#### 1. 同步文件

```bash
./sync_files.sh
```

#### 2. 提交代码

```bash
git add .
git commit -m "Release 1.0.6

新功能：
- 环境切换功能（测试/正式环境）
- 调试工具集成（模拟弱网、Crash监控、内存监控）
- 分享功能（导出为txt文件）

优化：
- 优化入口按钮尺寸（40x40）
- 优化悬浮窗显示（独立UIWindow）
- 修复iOS 13+悬浮窗显示问题

详见 CHANGELOG.md"
```

#### 3. 创建标签

```bash
git tag -a 1.0.6 -m "Release 1.0.6"
```

#### 4. 推送到 GitHub

```bash
git push origin main
git push origin 1.0.6
```

#### 5. 验证 podspec

```bash
pod lib lint ZWB_LogTap.podspec --allow-warnings
```

#### 6. 发布到 CocoaPods

```bash
pod trunk push ZWB_LogTap.podspec --allow-warnings
```

## 发布后检查

### 1. GitHub 检查

访问：https://github.com/muskspace0806-prog/Log-interception

- [ ] 代码已推送
- [ ] 标签 1.0.6 已创建
- [ ] README 显示正确
- [ ] 截图显示正常

### 2. CocoaPods 检查

访问：https://cocoapods.org/pods/ZWB_LogTap

- [ ] 版本 1.0.6 已发布
- [ ] 文档已更新
- [ ] 可以正常安装

测试安装：
```bash
pod try ZWB_LogTap
```

### 3. 功能测试

创建测试项目：
```ruby
# Podfile
pod 'ZWB_LogTap', '~> 1.0.6', :configurations => ['Debug']
```

测试功能：
- [ ] 悬浮按钮显示正常（蓝色）
- [ ] 点击悬浮按钮，能看到"工具"按钮
- [ ] 环境切换功能正常
- [ ] 模拟弱网功能正常
- [ ] Crash 监控功能正常
- [ ] 内存监控功能正常
- [ ] 分享功能正常

## 发布后任务

### 1. 创建 GitHub Release（可选）

1. 访问：https://github.com/muskspace0806-prog/Log-interception/releases/new
2. 选择标签：1.0.6
3. 标题：ZWB_LogTap 1.0.6
4. 描述：复制 RELEASE_NOTES_1.0.6.md 的内容
5. 上传截图（可选）
6. 点击 "Publish release"

### 2. 更新文档

- [ ] 更新 Wiki（如果有）
- [ ] 更新示例项目
- [ ] 更新 FAQ

### 3. 通知用户

- [ ] 发布公告（如果有社区）
- [ ] 更新项目主页
- [ ] 通知主要用户

## 常见问题

### Q: pod trunk push 失败？

A: 检查以下几点：
1. 是否已登录 CocoaPods Trunk：`pod trunk me`
2. podspec 是否通过验证：`pod lib lint --allow-warnings`
3. 标签是否已推送到 GitHub：`git tag -l`
4. 网络是否正常

### Q: 截图不显示？

A: 检查：
1. 截图文件是否已提交到 Git
2. README 中的路径是否正确
3. GitHub 是否已同步

### Q: 版本号不一致？

A: 确保以下文件版本号一致：
- ZWB_LogTap.podspec
- README.md（badge）
- CHANGELOG.md

## 回滚步骤

如果发布后发现严重问题，需要回滚：

### 1. 删除 CocoaPods 版本

```bash
pod trunk delete ZWB_LogTap 1.0.6
```

### 2. 删除 Git 标签

```bash
git tag -d 1.0.6
git push origin :refs/tags/1.0.6
```

### 3. 回退代码

```bash
git revert HEAD
git push origin main
```

### 4. 修复问题后重新发布

修复问题后，可以：
- 发布 1.0.6.1（补丁版本）
- 或者发布 1.0.7（新版本）

## 发布检查表

发布前最后检查：

- [ ] 所有测试通过
- [ ] 文档已更新
- [ ] 截图已更新
- [ ] 版本号正确
- [ ] CHANGELOG 完整
- [ ] 没有未提交的更改
- [ ] podspec 验证通过

发布后检查：

- [ ] GitHub 代码已更新
- [ ] CocoaPods 已发布
- [ ] 可以正常安装
- [ ] 功能测试通过
- [ ] 文档显示正常

## 联系方式

如有问题，请联系：
- GitHub Issues: https://github.com/muskspace0806-prog/Log-interception/issues
- Email: [your-email]

---

**祝发布顺利！** 🎉
