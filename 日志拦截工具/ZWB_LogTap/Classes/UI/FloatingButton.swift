//
//  FloatingButton.swift
//  日志拦截工具
//
//  可拖拽的悬浮按钮
//

import UIKit

class FloatingButton: UIButton {
    
    // 回调
    var onTap: (() -> Void)?
    
    private var panGesture: UIPanGestureRecognizer!
    private var tapGesture: UITapGestureRecognizer!
    
    private var isDragging = false
    private var initialCenter: CGPoint = .zero
    private var bringToFrontTimer: Timer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupGestures()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupGestures()
    }
    
    private func setupUI() {
        // 设置按钮样式
        updateEnvironmentColor()
        setTitle("📊", for: .normal)
        titleLabel?.font = UIFont.systemFont(ofSize: 24)
        layer.cornerRadius = 25
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        layer.shadowOpacity = 0.3
        
        // 设置大小为 50x50
        frame.size = CGSize(width: 50, height: 50)
        
        // 监听通知，确保始终在最顶层
        NotificationCenter.default.addObserver(self, selector: #selector(bringToFront), name: UIWindow.didBecomeVisibleNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(bringToFront), name: UIWindow.didBecomeKeyNotification, object: nil)
        
        // 启动定时器，定期检查并置顶
        startBringToFrontTimer()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        bringToFrontTimer?.invalidate()
    }
    
    private func startBringToFrontTimer() {
        // 每0.5秒检查一次，确保始终在最顶层
        bringToFrontTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.bringToFront()
        }
    }
    
    @objc private func bringToFront() {
        guard let superview = superview else { return }
        superview.bringSubviewToFront(self)
    }
    
    private func setupGestures() {
        // 拖拽手势
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        panGesture.delegate = self
        addGestureRecognizer(panGesture)
        
        // 点击手势
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tapGesture.delegate = self
        addGestureRecognizer(tapGesture)
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let superview = superview else { return }
        
        switch gesture.state {
        case .began:
            isDragging = true
            initialCenter = center
            // 放大动画
            UIView.animate(withDuration: 0.2) {
                self.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                self.alpha = 0.8
            }
            
        case .changed:
            let translation = gesture.translation(in: superview)
            center = CGPoint(x: initialCenter.x + translation.x, y: initialCenter.y + translation.y)
            
        case .ended, .cancelled:
            isDragging = false
            // 恢复大小
            UIView.animate(withDuration: 0.2) {
                self.transform = .identity
                self.alpha = 1.0
            }
            
            // 吸附到边缘
            snapToEdge()
            
        default:
            break
        }
    }
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        // 点击动画
        UIView.animate(withDuration: 0.1, animations: {
            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.transform = .identity
            }
        }
        
        // 震动反馈
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        // 执行回调
        onTap?()
    }
    
    // 吸附到边缘
    private func snapToEdge() {
        guard let superview = superview else { return }
        
        let screenWidth = superview.bounds.width
        let screenHeight = superview.bounds.height
        let margin: CGFloat = 10
        
        var newCenter = center
        
        // 判断靠近哪个边缘
        if center.x < screenWidth / 2 {
            // 靠近左边
            newCenter.x = frame.width / 2 + margin
        } else {
            // 靠近右边
            newCenter.x = screenWidth - frame.width / 2 - margin
        }
        
        // 限制 Y 轴范围，增加底部额外距离避免与 tabBar 重叠
        let extraBottomMargin: CGFloat = 60
        let minY = frame.height / 2 + margin + (superview.safeAreaInsets.top)
        let maxY = screenHeight - frame.height / 2 - margin - (superview.safeAreaInsets.bottom) - extraBottomMargin
        newCenter.y = max(minY, min(maxY, center.y))
        
        // 动画移动到边缘
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveEaseOut) {
            self.center = newCenter
        }
    }
    
    // 显示按钮
    func show(in view: UIView) {
        if superview != nil {
            return
        }
        
        view.addSubview(self)
        
        // 初始位置（右下角）
        let margin: CGFloat = 20
        // 增加额外的底部距离，避免与 tabBar 重叠（tabBar 高度约 49-83pt）
        let extraBottomMargin: CGFloat = 60
        let x = view.bounds.width - frame.width / 2 - margin
        let y = view.bounds.height - frame.height / 2 - margin - view.safeAreaInsets.bottom - extraBottomMargin
        center = CGPoint(x: x, y: y)
        
        // 显示动画
        alpha = 0
        transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5) {
            self.alpha = 1
            self.transform = .identity
        }
    }
    
    // 隐藏按钮
    func hide() {
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 0
            self.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        }) { _ in
            self.removeFromSuperview()
        }
    }
    
    // 更新环境颜色
    func updateEnvironmentColor() {
        let color = EnvironmentManager.shared.currentEnvironment.buttonColor
        backgroundColor = color.withAlphaComponent(0.9)
    }
}

// MARK: - UIGestureRecognizerDelegate
extension FloatingButton: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}
