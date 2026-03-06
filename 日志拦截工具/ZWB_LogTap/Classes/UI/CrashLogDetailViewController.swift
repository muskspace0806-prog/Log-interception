//
//  CrashLogDetailViewController.swift
//  ZWB_LogTap
//
//  Crash 日志详情页面
//

import UIKit

class CrashLogDetailViewController: UIViewController {
    
    var crashLog: CrashMonitor.CrashLog?
    
    private var scrollView: UIScrollView!
    private var contentStackView: UIStackView!
    private var closeButton: UIButton!
    private var copyButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        displayCrashLog()
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
        titleLabel.text = "Crash 详情"
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        toolBar.addSubview(titleLabel)
        
        // 复制按钮
        copyButton = UIButton(type: .system)
        copyButton.setTitle("复制", for: .normal)
        copyButton.titleLabel?.font = .systemFont(ofSize: 16)
        copyButton.addTarget(self, action: #selector(copyTapped), for: .touchUpInside)
        copyButton.translatesAutoresizingMaskIntoConstraints = false
        toolBar.addSubview(copyButton)
        
        // 分享按钮
        let shareButton = UIButton(type: .system)
        shareButton.setTitle("分享", for: .normal)
        shareButton.titleLabel?.font = .systemFont(ofSize: 16)
        shareButton.addTarget(self, action: #selector(shareTapped), for: .touchUpInside)
        shareButton.translatesAutoresizingMaskIntoConstraints = false
        toolBar.addSubview(shareButton)
        
        // 滚动视图
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        // 内容容器
        contentStackView = UIStackView()
        contentStackView.axis = .vertical
        contentStackView.spacing = 0
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStackView)
        
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
            
            shareButton.trailingAnchor.constraint(equalTo: toolBar.trailingAnchor, constant: -16),
            shareButton.centerYAnchor.constraint(equalTo: toolBar.centerYAnchor),
            
            copyButton.trailingAnchor.constraint(equalTo: shareButton.leadingAnchor, constant: -12),
            copyButton.centerYAnchor.constraint(equalTo: toolBar.centerYAnchor),
            
            scrollView.topAnchor.constraint(equalTo: toolBar.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    private func displayCrashLog() {
        guard let log = crashLog else { return }
        
        // 基本信息
        addSection(title: "崩溃原因", content: log.reason, backgroundColor: .systemRed.withAlphaComponent(0.1))
        
        // 时间信息
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let timeString = dateFormatter.string(from: log.timestamp)
        addSection(title: "发生时间", content: timeString)
        
        // 应用版本
        addSection(title: "应用版本", content: log.appVersion)
        
        // 系统版本
        addSection(title: "系统版本", content: "iOS \(log.osVersion)")
        
        // 调用栈
        addSection(title: "调用栈 (Call Stack)", content: log.stackTrace, isMonospace: true)
    }
    
    private func addSection(title: String, content: String, backgroundColor: UIColor = .secondarySystemBackground, isMonospace: Bool = false) {
        // 标题容器
        let titleContainer = UIView()
        titleContainer.backgroundColor = .systemGray5
        titleContainer.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        titleLabel.textColor = .secondaryLabel
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleContainer.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: titleContainer.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: titleContainer.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: titleContainer.trailingAnchor, constant: -16),
            titleLabel.bottomAnchor.constraint(equalTo: titleContainer.bottomAnchor, constant: -8)
        ])
        
        contentStackView.addArrangedSubview(titleContainer)
        
        // 内容容器
        let contentContainer = UIView()
        contentContainer.backgroundColor = backgroundColor
        contentContainer.translatesAutoresizingMaskIntoConstraints = false
        
        let contentLabel = UILabel()
        contentLabel.text = content
        contentLabel.numberOfLines = 0
        contentLabel.font = isMonospace ? .monospacedSystemFont(ofSize: 12, weight: .regular) : .systemFont(ofSize: 14)
        contentLabel.textColor = .label
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        contentContainer.addSubview(contentLabel)
        
        NSLayoutConstraint.activate([
            contentLabel.topAnchor.constraint(equalTo: contentContainer.topAnchor, constant: 12),
            contentLabel.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor, constant: 16),
            contentLabel.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor, constant: -16),
            contentLabel.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor, constant: -12)
        ])
        
        contentStackView.addArrangedSubview(contentContainer)
        
        // 分隔线
        let separator = UIView()
        separator.backgroundColor = .separator
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        contentStackView.addArrangedSubview(separator)
    }
    
    @objc private func closeTapped() {
        dismiss(animated: true)
    }
    
    @objc private func copyTapped() {
        guard let log = crashLog else { return }
        
        let fullText = generateCrashText(log)
        UIPasteboard.general.string = fullText
        
        // 显示提示
        let alert = UIAlertController(title: nil, message: "已复制到剪贴板", preferredStyle: .alert)
        present(alert, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            alert.dismiss(animated: true)
        }
    }
    
    @objc private func shareTapped() {
        guard let log = crashLog else { return }
        
        let fullText = generateCrashText(log)
        
        // 创建临时文件
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd_HHmmss"
        let timeString = dateFormatter.string(from: log.timestamp)
        let fileName = "crash_\(timeString).txt"
        
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent(fileName)
        
        do {
            try fullText.write(to: fileURL, atomically: true, encoding: .utf8)
            
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
    
    private func generateCrashText(_ log: CrashMonitor.CrashLog) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let timeString = dateFormatter.string(from: log.timestamp)
        
        return """
        ===== Crash 日志 =====
        
        崩溃原因:
        \(log.reason)
        
        发生时间:
        \(timeString)
        
        应用版本:
        \(log.appVersion)
        
        系统版本:
        iOS \(log.osVersion)
        
        调用栈:
        \(log.stackTrace)
        
        =====================
        """
    }
}
