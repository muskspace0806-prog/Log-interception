//
//  FloatingInfoWindow.swift
//  ZWB_LogTap
//
//  可拖拽的悬浮信息窗口
//

import UIKit

class FloatingInfoWindow: UIView {
    
    private var contentLabel: UILabel!
    private var closeButton: UIButton!
    private var panGesture: UIPanGestureRecognizer!
    
    // 独立的 window 用于确保始终在最顶层
    private var floatingWindow: UIWindow?
    
    var onClose: (() -> Void)?
    
    init() {
        super.init(frame: CGRect(x: 20, y: 100, width: 160, height: 90))
        setupUI()
        setupGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = UIColor.black.withAlphaComponent(0.7)
        layer.cornerRadius = 12
        layer.borderWidth = 1
        layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        
        // 内容标签
        contentLabel = UILabel()
        contentLabel.numberOfLines = 0
        contentLabel.font = .systemFont(ofSize: 12)
        contentLabel.textColor = .white
        contentLabel.textAlignment = .left
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentLabel)
        
        // 关闭按钮
        closeButton = UIButton(type: .system)
        closeButton.setTitle("✕", for: .normal)
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        closeButton.backgroundColor = UIColor.red.withAlphaComponent(0.8)
        closeButton.layer.cornerRadius = 12
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(closeButton)
        
        // 布局
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            closeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
            closeButton.widthAnchor.constraint(equalToConstant: 24),
            closeButton.heightAnchor.constraint(equalToConstant: 24),
            
            contentLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            contentLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            contentLabel.trailingAnchor.constraint(equalTo: closeButton.leadingAnchor, constant: -4),
            contentLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
    }
    
    private func setupGesture() {
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        addGestureRecognizer(panGesture)
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let window = floatingWindow else { return }
        
        let translation = gesture.translation(in: window)
        
        if let view = gesture.view {
            view.center = CGPoint(x: view.center.x + translation.x, y: view.center.y + translation.y)
        }
        
        gesture.setTranslation(.zero, in: window)
        
        // 限制在屏幕范围内
        if gesture.state == .ended {
            snapToEdge()
        }
    }
    
    private func snapToEdge() {
        guard let window = floatingWindow else { return }
        
        let screenWidth = window.bounds.width
        let screenHeight = window.bounds.height
        
        var newFrame = frame
        
        // 限制在屏幕内
        if newFrame.minX < 0 {
            newFrame.origin.x = 10
        }
        if newFrame.maxX > screenWidth {
            newFrame.origin.x = screenWidth - newFrame.width - 10
        }
        if newFrame.minY < 0 {
            newFrame.origin.y = 10
        }
        if newFrame.maxY > screenHeight {
            newFrame.origin.y = screenHeight - newFrame.height - 10
        }
        
        UIView.animate(withDuration: 0.3) {
            self.frame = newFrame
        }
    }
    
    @objc private func closeTapped() {
        onClose?()
        hide()
    }
    
    func updateContent(_ text: String) {
        DispatchQueue.main.async {
            self.contentLabel.text = text
        }
    }
    
    func updateContentWithAttributedString(_ attributedString: NSAttributedString) {
        DispatchQueue.main.async {
            self.contentLabel.attributedText = attributedString
        }
    }
    
    func show(in view: UIView) {
        if floatingWindow != nil {
            return
        }
        
        // 获取当前的 windowScene（iOS 13+）
        var windowScene: UIWindowScene?
        if #available(iOS 13.0, *) {
            windowScene = UIApplication.shared.connectedScenes
                .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
        }
        
        // 创建自定义 window，只在悬浮窗区域响应触摸
        let window: PassThroughWindow
        if #available(iOS 13.0, *), let scene = windowScene {
            window = PassThroughWindow(windowScene: scene)
        } else {
            window = PassThroughWindow(frame: UIScreen.main.bounds)
        }
        
        window.windowLevel = .alert + 1  // 设置为最高层级
        window.backgroundColor = .clear
        
        // 创建透明的根视图控制器
        let rootVC = UIViewController()
        rootVC.view.backgroundColor = .clear
        window.rootViewController = rootVC
        window.isHidden = false
        
        // 将悬浮窗添加到 window
        window.addSubview(self)
        self.floatingWindow = window
        
        print("🪟 悬浮窗已显示 - frame: \(self.frame)")
    }
    
    func hide() {
        removeFromSuperview()
        floatingWindow?.isHidden = true
        floatingWindow = nil
    }
}

// MARK: - PassThroughWindow
// 自定义 Window，只在有子视图的区域响应触摸，其他区域穿透
private class PassThroughWindow: UIWindow {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // 获取正常的 hitTest 结果
        guard let hitView = super.hitTest(point, with: event) else {
            return nil
        }
        
        // 如果点击的是根视图控制器的 view，说明点击的是空白区域，返回 nil 让触摸穿透
        if hitView == rootViewController?.view {
            return nil
        }
        
        // 否则返回正常的 hitView（悬浮窗或其子视图）
        return hitView
    }
}
