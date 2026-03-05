//
//  WebSocketMessageDetailViewController.swift
//  日志拦截工具
//
//  WebSocket 消息详情页面
//

import UIKit

class WebSocketMessageDetailViewController: UIViewController {
    
    var message: WebSocketMessage?
    
    private var scrollView: UIScrollView!
    private var contentStackView: UIStackView!
    private var closeButton: UIButton!
    private var messageContentView: UIStackView?  // 保存消息内容区域的引用
    private var copyButton: UIButton?  // 浮动复制按钮
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        displayMessage()
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
        titleLabel.text = "消息详情"
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        toolBar.addSubview(titleLabel)
        
        // 滚动视图
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        // 内容堆栈
        contentStackView = UIStackView()
        contentStackView.axis = .vertical
        contentStackView.spacing = 16
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStackView)
        
        NSLayoutConstraint.activate([
            toolBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            toolBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            toolBar.heightAnchor.constraint(equalToConstant: 50),
            
            closeButton.leadingAnchor.constraint(equalTo: toolBar.leadingAnchor, constant: 16),
            closeButton.centerYAnchor.constraint(equalTo: toolBar.centerYAnchor),
            
            titleLabel.centerXAnchor.constraint(equalTo: toolBar.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: toolBar.centerYAnchor),
            
            scrollView.topAnchor.constraint(equalTo: toolBar.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -32),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
        ])
    }
    
    private func displayMessage() {
        guard let message = message else { return }
        
        // 基本信息
        addSection(title: "基本信息", items: [
            ("类型", "\(message.type.emoji) \(message.type.rawValue)"),
            ("时间", message.timeString),
            ("URL", message.url),
            ("主机", message.host),
            ("路径", message.path),
            ("数据大小", message.dataSize)
        ])
        
        // 消息内容
        if message.type == .send || message.type == .receive {
            addSection(title: "消息内容", content: message.dataString)
        } else if message.type == .error || message.type == .disconnect {
            addSection(title: "详细信息", content: message.dataString)
        }
    }
    
    private func addSection(title: String, items: [(String, String)]) {
        let sectionView = createSectionView(title: title)
        
        for (key, value) in items {
            let itemView = createItemView(key: key, value: value)
            sectionView.addArrangedSubview(itemView)
        }
        
        contentStackView.addArrangedSubview(sectionView)
    }
    
    private func addSection(title: String, content: String) {
        let sectionView = createSectionView(title: title)
        
        // 创建一个容器来放置内容和复制按钮
        let contentContainer = UIView()
        contentContainer.translatesAutoresizingMaskIntoConstraints = false
        
        let contentLabel = UILabel()
        contentLabel.text = content
        contentLabel.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
        contentLabel.textColor = .label
        contentLabel.numberOfLines = 0
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        contentContainer.addSubview(contentLabel)
        
        // 创建浮动复制按钮
        let copyBtn = UIButton(type: .system)
        copyBtn.setTitle("复制", for: .normal)
        copyBtn.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        copyBtn.backgroundColor = .systemBlue
        copyBtn.setTitleColor(.white, for: .normal)
        copyBtn.layer.cornerRadius = 6
        copyBtn.contentEdgeInsets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
        copyBtn.addTarget(self, action: #selector(copyMessageContent), for: .touchUpInside)
        copyBtn.translatesAutoresizingMaskIntoConstraints = false
        contentContainer.addSubview(copyBtn)
        
        self.copyButton = copyBtn
        
        NSLayoutConstraint.activate([
            contentLabel.topAnchor.constraint(equalTo: contentContainer.topAnchor),
            contentLabel.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            contentLabel.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor),
            contentLabel.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor),
            
            copyBtn.topAnchor.constraint(equalTo: contentContainer.topAnchor, constant: -4),
            copyBtn.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor, constant: 4)
        ])
        
        sectionView.addArrangedSubview(contentContainer)
        contentStackView.addArrangedSubview(sectionView)
        
        // 保存消息内容区域的引用
        messageContentView = sectionView
    }
    
    private func createSectionView(title: String) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.backgroundColor = .secondarySystemBackground
        stackView.layer.cornerRadius = 8
        stackView.layoutMargins = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        stackView.isLayoutMarginsRelativeArrangement = true
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
        titleLabel.textColor = .label
        
        stackView.addArrangedSubview(titleLabel)
        
        return stackView
    }
    
    private func createItemView(key: String, value: String) -> UIView {
        let containerView = UIView()
        
        let keyLabel = UILabel()
        keyLabel.text = key
        keyLabel.font = .systemFont(ofSize: 14, weight: .medium)
        keyLabel.textColor = .secondaryLabel
        keyLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(keyLabel)
        
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = .systemFont(ofSize: 14)
        valueLabel.textColor = .label
        valueLabel.numberOfLines = 0
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(valueLabel)
        
        NSLayoutConstraint.activate([
            keyLabel.topAnchor.constraint(equalTo: containerView.topAnchor),
            keyLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            keyLabel.widthAnchor.constraint(equalToConstant: 80),
            
            valueLabel.topAnchor.constraint(equalTo: containerView.topAnchor),
            valueLabel.leadingAnchor.constraint(equalTo: keyLabel.trailingAnchor, constant: 8),
            valueLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            valueLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        return containerView
    }
    
    @objc private func closeTapped() {
        dismiss(animated: true)
    }
    
    @objc private func copyMessageContent() {
        guard let message = message else { return }
        
        // 只复制消息内容
        let content: String
        if message.type == .send || message.type == .receive {
            content = message.dataString
        } else if message.type == .error || message.type == .disconnect {
            content = message.dataString
        } else {
            content = ""
        }
        
        UIPasteboard.general.string = content
        
        // 显示复制成功提示
        if let copyBtn = copyButton {
            let originalTitle = copyBtn.title(for: .normal)
            copyBtn.setTitle("已复制", for: .normal)
            copyBtn.backgroundColor = .systemGreen
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                copyBtn.setTitle(originalTitle, for: .normal)
                copyBtn.backgroundColor = .systemBlue
            }
        }
    }
    
    @objc private func copyTapped() {
        // 保留这个方法以防万一，但实际上不会被调用
        copyMessageContent()
    }
}
