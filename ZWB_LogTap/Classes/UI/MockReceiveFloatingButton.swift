//
//  MockReceiveFloatingButton.swift
//  ZWB_LogTap
//
//  可拖拽的 IM 模拟接收悬浮入口
//

import UIKit

final class MockReceiveFloatingButton: UIButton {
    
    var onTap: (() -> Void)?
    
    private var panGesture: UIPanGestureRecognizer!
    private var tapGesture: UITapGestureRecognizer!
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
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        bringToFrontTimer?.invalidate()
    }
    
    private func setupUI() {
        setTitle("IM", for: .normal)
        titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)
        setTitleColor(.white, for: .normal)
        backgroundColor = .systemRed.withAlphaComponent(0.92)
        layer.cornerRadius = 25
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        layer.shadowOpacity = 0.3
        frame.size = CGSize(width: 50, height: 50)
        
        NotificationCenter.default.addObserver(self, selector: #selector(bringToFront), name: UIWindow.didBecomeVisibleNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(bringToFront), name: UIWindow.didBecomeKeyNotification, object: nil)
        bringToFrontTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.bringToFront()
        }
    }
    
    private func setupGestures() {
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        panGesture.delegate = self
        addGestureRecognizer(panGesture)
        
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tapGesture.delegate = self
        addGestureRecognizer(tapGesture)
    }
    
    @objc private func bringToFront() {
        superview?.bringSubviewToFront(self)
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let superview = superview else { return }
        
        switch gesture.state {
        case .began:
            initialCenter = center
            UIView.animate(withDuration: 0.2) {
                self.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                self.alpha = 0.85
            }
        case .changed:
            let translation = gesture.translation(in: superview)
            center = CGPoint(x: initialCenter.x + translation.x, y: initialCenter.y + translation.y)
        case .ended, .cancelled:
            UIView.animate(withDuration: 0.2) {
                self.transform = .identity
                self.alpha = 1
            }
            snapToEdge()
        default:
            break
        }
    }
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        UIView.animate(withDuration: 0.1, animations: {
            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.transform = .identity
            }
        }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        onTap?()
    }
    
    func show(in view: UIView) {
        if superview != nil { return }
        view.addSubview(self)
        
        let margin: CGFloat = 20
        let extraBottomMargin: CGFloat = 120
        center = CGPoint(
            x: view.bounds.width - frame.width / 2 - margin,
            y: view.bounds.height - frame.height / 2 - margin - view.safeAreaInsets.bottom - extraBottomMargin
        )
        
        alpha = 0
        transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5) {
            self.alpha = 1
            self.transform = .identity
        }
    }
    
    func hide() {
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 0
            self.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        }) { _ in
            self.removeFromSuperview()
        }
    }
    
    private func snapToEdge() {
        guard let superview = superview else { return }
        
        let margin: CGFloat = 10
        var newCenter = center
        if center.x < superview.bounds.width / 2 {
            newCenter.x = frame.width / 2 + margin
        } else {
            newCenter.x = superview.bounds.width - frame.width / 2 - margin
        }
        
        let extraBottomMargin: CGFloat = 60
        let minY = frame.height / 2 + margin + superview.safeAreaInsets.top
        let maxY = superview.bounds.height - frame.height / 2 - margin - superview.safeAreaInsets.bottom - extraBottomMargin
        newCenter.y = max(minY, min(maxY, center.y))
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveEaseOut) {
            self.center = newCenter
        }
    }
}

extension MockReceiveFloatingButton: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}
