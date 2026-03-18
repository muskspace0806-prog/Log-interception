//
//  NetworkLogDetailViewController.swift
//  日志拦截工具
//
//  网络日志详情页面
//

import UIKit

class NetworkLogDetailViewController: UIViewController {
    
    var request: InterceptedRequest!
    
    private var scrollView: UIScrollView!
    private var contentView: UIView!
    private var tabButtonsContainer: UIView!
    private var tabButtons: [UIButton] = []
    private var selectedTabIndex: Int = 0
    private var textView: UITextView!
    private var copyButton: UIButton!
    private var closeButton: UIButton!
    
    private let tabTitles = ["基本信息", "URL信息", "请求Headers", "请求Body", "响应Headers", "响应Body", "异常信息"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        // 默认显示响应Body（索引5）
        selectedTabIndex = 5
        updateTabButtonStyles()
        displayResponseBody()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // 顶部工具栏
        let toolBar = UIView()
        toolBar.backgroundColor = .systemBackground
        toolBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toolBar)
        
        // 关闭按钮
        closeButton = UIButton(type: .system)
        closeButton.setTitle("关闭", for: .normal)
        closeButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        toolBar.addSubview(closeButton)
        
        // 标题
        let titleLabel = UILabel()
        titleLabel.text = "详情"
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        toolBar.addSubview(titleLabel)
        
        // 标签按钮容器（支持换行）
        tabButtonsContainer = UIView()
        tabButtonsContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tabButtonsContainer)
        
        setupTabButtons()
        
        // 滚动视图
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        // 内容视图
        contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        // 文本视图
        textView = UITextView()
        textView.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
        textView.isEditable = false
        textView.backgroundColor = .secondarySystemBackground
        textView.layer.cornerRadius = 8
        // 顶部留出空间给复制按钮（按钮高度约 32，加上间距）
        textView.textContainerInset = UIEdgeInsets(top: 48, left: 12, bottom: 12, right: 12)
        textView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(textView)
        
        // 复制按钮（浮动在 textView 右上角）
        copyButton = UIButton(type: .system)
        copyButton.setTitle("复制", for: .normal)
        copyButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        copyButton.backgroundColor = .systemBlue
        copyButton.setTitleColor(.white, for: .normal)
        copyButton.layer.cornerRadius = 6
        copyButton.contentEdgeInsets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
        copyButton.addTarget(self, action: #selector(copyButtonTapped), for: .touchUpInside)
        copyButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(copyButton)
        
        // 分享按钮（浮动在复制按钮旁边）
        let shareButton = UIButton(type: .system)
        shareButton.setTitle("分享", for: .normal)
        shareButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        shareButton.backgroundColor = .systemGreen
        shareButton.setTitleColor(.white, for: .normal)
        shareButton.layer.cornerRadius = 6
        shareButton.contentEdgeInsets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
        shareButton.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
        shareButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(shareButton)
        
        // 布局
        NSLayoutConstraint.activate([
            toolBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            toolBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            toolBar.heightAnchor.constraint(equalToConstant: 50),
            
            closeButton.leadingAnchor.constraint(equalTo: toolBar.leadingAnchor, constant: 16),
            closeButton.centerYAnchor.constraint(equalTo: toolBar.centerYAnchor),
            
            titleLabel.centerXAnchor.constraint(equalTo: toolBar.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: toolBar.centerYAnchor),
            
            tabButtonsContainer.topAnchor.constraint(equalTo: toolBar.bottomAnchor, constant: 8),
            tabButtonsContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            tabButtonsContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            tabButtonsContainer.heightAnchor.constraint(equalToConstant: 120), // 增加到 120 以容纳三行按钮
            
            scrollView.topAnchor.constraint(equalTo: tabButtonsContainer.bottomAnchor, constant: 8),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            textView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            textView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            textView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            textView.heightAnchor.constraint(equalTo: scrollView.heightAnchor, constant: -24),
            
            shareButton.topAnchor.constraint(equalTo: textView.topAnchor, constant: 8),
            shareButton.trailingAnchor.constraint(equalTo: textView.trailingAnchor, constant: -8),
            
            copyButton.topAnchor.constraint(equalTo: textView.topAnchor, constant: 8),
            copyButton.trailingAnchor.constraint(equalTo: shareButton.leadingAnchor, constant: -8)
        ])
    }
    
    private func setupTabButtons() {
        let buttonHeight: CGFloat = 32
        let spacing: CGFloat = 8
        let containerWidth = view.bounds.width - 24 // 减去左右边距
        
        var xOffset: CGFloat = 0
        var yOffset: CGFloat = 0
        
        for (index, title) in tabTitles.enumerated() {
            let button = UIButton(type: .system)
            button.setTitle(title, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
            button.tag = index
            button.addTarget(self, action: #selector(tabButtonTapped(_:)), for: .touchUpInside)
            button.translatesAutoresizingMaskIntoConstraints = false
            tabButtonsContainer.addSubview(button)
            
            // 计算按钮宽度（根据文字自适应）
            let buttonWidth = (title as NSString).size(withAttributes: [.font: UIFont.systemFont(ofSize: 14, weight: .medium)]).width + 20
            
            // 如果当前行放不下，换行
            if xOffset + buttonWidth > containerWidth && xOffset > 0 {
                xOffset = 0
                yOffset += buttonHeight + spacing
            }
            
            // 设置按钮样式
            button.layer.cornerRadius = 6
            button.layer.borderWidth = 1
            
            NSLayoutConstraint.activate([
                button.leadingAnchor.constraint(equalTo: tabButtonsContainer.leadingAnchor, constant: xOffset),
                button.topAnchor.constraint(equalTo: tabButtonsContainer.topAnchor, constant: yOffset),
                button.widthAnchor.constraint(equalToConstant: buttonWidth),
                button.heightAnchor.constraint(equalToConstant: buttonHeight)
            ])
            
            tabButtons.append(button)
            xOffset += buttonWidth + spacing
        }
        
        // 默认选中第一个
        updateTabButtonStyles()
    }
    
    private func updateTabButtonStyles() {
        for (index, button) in tabButtons.enumerated() {
            if index == selectedTabIndex {
                // 选中状态
                button.backgroundColor = .systemBlue
                button.setTitleColor(.white, for: .normal)
                button.layer.borderColor = UIColor.systemBlue.cgColor
            } else {
                // 未选中状态
                button.backgroundColor = .clear
                button.setTitleColor(.systemBlue, for: .normal)
                button.layer.borderColor = UIColor.systemGray4.cgColor
            }
        }
    }
    
    @objc private func tabButtonTapped(_ sender: UIButton) {
        selectedTabIndex = sender.tag
        updateTabButtonStyles()
        
        // 显示对应内容
        switch selectedTabIndex {
        case 0:
            displayBasicInfo()
        case 1:
            displayURLInfo()
        case 2:
            displayRequestHeaders()
        case 3:
            displayRequestBody()
        case 4:
            displayResponseHeaders()
        case 5:
            displayResponseBody()
        case 6:
            displayErrorInfo()
        default:
            break
        }
    }
    
    @objc private func closeTapped() {
        dismiss(animated: true)
    }
    
    @objc private func copyButtonTapped() {
        // 复制当前显示的内容
        UIPasteboard.general.string = textView.text
        
        // 显示复制成功提示
        let originalTitle = copyButton.title(for: .normal)
        copyButton.setTitle("已复制", for: .normal)
        copyButton.backgroundColor = .systemGreen
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.copyButton.setTitle(originalTitle, for: .normal)
            self.copyButton.backgroundColor = .systemBlue
        }
    }
    
    @objc private func shareTapped() {
        // 分享当前 tab 的内容
        shareCurrentTabContent()
    }
    
    @objc private func shareButtonTapped() {
        // 分享当前 tab 的内容
        shareCurrentTabContent()
    }
    
    private func shareCurrentTabContent() {
        // 获取当前显示的内容
        let currentContent = textView.text ?? ""
        let tabName = tabTitles[selectedTabIndex]
        
        // 创建临时文件
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd_HHmmss"
        let timeString = dateFormatter.string(from: request.startTime)
        let fileName = "network_\(tabName)_\(timeString).txt"
        
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent(fileName)
        
        do {
            try currentContent.write(to: fileURL, atomically: true, encoding: .utf8)
            
            // 调用系统分享
            let activityVC = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
            
            // iPad 需要设置 popover
            if let popover = activityVC.popoverPresentationController {
                popover.sourceView = view
                popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
                popover.permittedArrowDirections = []
            }
            
            present(activityVC, animated: true)
        } catch {
            let alert = UIAlertController(title: "分享失败", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "确定", style: .default))
            present(alert, animated: true)
        }
    }
    
    private func displayBasicInfo() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        
        var info = """
        时间: \(formatter.string(from: request.startTime))
        
        路由: \(request.path)
        
        请求类型: \(request.method)
        
        """
        
        if let statusCode = request.statusCode {
            info += "状态码: \(statusCode)\n\n"
        }
        
        if let duration = request.duration {
            info += "耗时: \(String(format: "%.0fms", duration * 1000))\n\n"
        }
        
        info += "日志ID: \(request.id)\n\n"
        info += "URL短链接: \(request.path)"
        
        textView.text = info
    }
    
    private func displayURLInfo() {
        textView.text = "完整URL:\n\(request.url)"
    }
    
    private func displayRequestHeaders() {
        if request.headers.isEmpty {
            textView.text = "无请求Headers"
            return
        }
        
        var info = "请求Headers (\(request.headers.count)):\n\n"
        for (key, value) in request.headers.sorted(by: { $0.key < $1.key }) {
            info += "\(key): \(value)\n"
        }
        
        textView.text = info
    }
    
    private func displayRequestBody() {
        var info = ""
        
        // 先显示URL参数（使用解密后的）
        let params = request.decryptedQueryParameters
        if !params.isEmpty {
            info += "URL参数（解密后） (\(params.count)):\n"
            for (key, value) in params.sorted(by: { $0.key < $1.key }) {
                info += "\(key): \(value)\n"
            }
            info += "\n"
        }
        
        // 再显示请求Body（已经在 requestBodyString 中解密）
        if let bodyString = request.requestBodyString {
            if !info.isEmpty {
                info += "请求Body（解密后）:\n"
            }
            info += bodyString
        } else if request.body != nil {
            if !info.isEmpty {
                info += "请求Body:\n"
            }
            info += "无法解析请求Body（可能是二进制数据）"
        } else {
            if info.isEmpty {
                info = "无URL参数和请求Body"
            }
        }
        
        textView.text = info
    }
    
    private func displayResponseHeaders() {
        if let headers = request.responseHeaders, !headers.isEmpty {
            var info = "响应Headers (\(headers.count)):\n\n"
            for (key, value) in headers.sorted(by: { $0.key < $1.key }) {
                info += "\(key): \(value)\n"
            }
            textView.text = info
        } else {
            textView.text = "无响应Headers"
        }
    }
    
    private func displayResponseBody() {
        if let bodyString = request.responseBodyString {
            textView.text = bodyString
        } else if request.responseData != nil {
            textView.text = "无法解析响应Body（可能是二进制数据）"
        } else {
            textView.text = "无响应Body"
        }
    }
    
    private func displayErrorInfo() {
        if let error = request.error {
            textView.text = "错误信息:\n\n\(error)"
        } else {
            textView.text = "无异常信息"
        }
    }
}
