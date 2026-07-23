//
//  PerformanceFloatingWindow.swift
//  ZWB_LogTap
//
//  Floating performance entry, overlay, and detail log UI.
//

import UIKit

final class PerformanceEntryFloatingButton: UIButton {

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
        setTitle("PERF", for: .normal)
        titleLabel?.font = .systemFont(ofSize: 12, weight: .bold)
        setTitleColor(.white, for: .normal)
        backgroundColor = UIColor.systemGreen.withAlphaComponent(0.94)
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
        addGestureRecognizer(panGesture)

        tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
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
                self.transform = CGAffineTransform(scaleX: 1.08, y: 1.08)
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
            keepInsideScreen(animated: true)
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
        if superview === view {
            view.bringSubviewToFront(self)
            return
        }

        removeFromSuperview()
        view.addSubview(self)
        let margin: CGFloat = 20
        center = CGPoint(
            x: view.bounds.width - frame.width / 2 - margin,
            y: view.bounds.height - frame.height / 2 - margin - view.safeAreaInsets.bottom - 120
        )
        keepInsideScreen(animated: false)

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

    private func keepInsideScreen(animated: Bool) {
        guard let superview = superview else { return }
        let margin: CGFloat = 10
        let minX = frame.width / 2 + margin
        let maxX = superview.bounds.width - frame.width / 2 - margin
        let minY = frame.height / 2 + margin + superview.safeAreaInsets.top
        let maxY = superview.bounds.height - frame.height / 2 - margin - superview.safeAreaInsets.bottom
        let newCenter = CGPoint(
            x: max(minX, min(maxX, center.x)),
            y: max(minY, min(maxY, center.y))
        )
        let changes = { self.center = newCenter }
        animated ? UIView.animate(withDuration: 0.25, animations: changes) : changes()
    }
}

// MARK: - ZWB Performance Floating Window
final class PerformanceFloatingWindow: UIView {

    private let titleLabel = UILabel()
    private let rowsStackView = UIStackView()
    private let copyButton = UIButton(type: .system)
    private let detailButton = UIButton(type: .system)
    private let clearButton = UIButton(type: .system)
    private let closeButton = UIButton(type: .system)
    private var valueLabels: [UILabel] = []
    private var panGesture: UIPanGestureRecognizer!
    private var floatingWindow: UIWindow?

    var onClose: (() -> Void)?
    var onDetail: (() -> Void)?

    init() {
        super.init(frame: CGRect(x: 14, y: 74, width: 304, height: 268))
        setupUI()
        setupGesture()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let padding: CGFloat = 9
        titleLabel.frame = CGRect(x: padding, y: 5, width: bounds.width - 48, height: 19)
        closeButton.frame = CGRect(x: bounds.width - 30, y: 5, width: 22, height: 22)

        let buttonHeight: CGFloat = 30
        let buttonY = bounds.height - padding - buttonHeight
        rowsStackView.frame = CGRect(
            x: padding,
            y: 28,
            width: bounds.width - padding * 2,
            height: max(0, buttonY - 34)
        )
        layoutActionButtons(y: buttonY, height: buttonHeight)
    }

    func update(snapshot: PerformanceSnapshot) {
        DispatchQueue.main.async {
            self.setValue(0, [
                ("当前 ", false), (String(format: "%2d", snapshot.fpsCurrent), true),
                ("   平均 ", false), (String(format: "%2d", snapshot.fpsAverage), true),
                ("   最低 ", false), (String(format: "%2d", snapshot.fpsMin), true)
            ])
            self.setValue(1, [
                ("当前 ", false), (String(format: "%3.0f%%", snapshot.cpuCurrent), true),
                ("   峰值 ", false), (String(format: "%3.0f%%", snapshot.cpuPeak), true)
            ])
            self.setValue(2, [
                ("当前 ", false), (String(format: "%4.0fMB", snapshot.memoryCurrentMB), true),
                ("  峰值 ", false), (String(format: "%4.0fMB", snapshot.memoryPeakMB), true)
            ])
            self.setValue(3, [
                ("增量 ", false), (String(format: "%+4.0fMB", snapshot.memoryDeltaMB), true)
            ])
            self.setValue(4, [
                ("请求 ", false), (String(format: "%3d", snapshot.network.requestCount), true),
                ("   失败 ", false), (String(format: "%2d", snapshot.network.failureCount), true)
            ])
            self.setValue(5, [
                ("均耗时 ", false), (String(format: "%4.0fms", snapshot.network.averageDurationMS), true)
            ])
            self.setValue(6, [
                ("上行 ", false), (PerformanceSnapshot.formatBytes(snapshot.network.uploadBytes), true),
                ("  下行 ", false), (PerformanceSnapshot.formatBytes(snapshot.network.downloadBytes), true)
            ])
            self.setValue(7, [
                ("次数 ", false), (String(format: "%2d", snapshot.jankCount), true),
                ("   最近 ", false), (String(format: "%4.0fms", snapshot.lastJankDurationMS), true),
                ("   掉帧 ", false), (String(format: "%2d", snapshot.lastJankDroppedFrames), true)
            ])
            self.setValue(8, [
                ("次数 ", false), (String(format: "%2d", snapshot.stallCount), true),
                ("   最近 ", false), (String(format: "%4.0fms", snapshot.lastStallDurationMS), true)
            ])
            self.setValue(9, [
                (snapshot.batteryLevelText, true), ("  ", false), (snapshot.batteryStateText, true)
            ])
            self.setValue(10, [
                (snapshot.thermalStateText, true)
            ])
        }
    }

    func show() {
        guard floatingWindow == nil else { return }

        let window: PassThroughPerformanceWindow
        if #available(iOS 13.0, *),
           let scene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            window = PassThroughPerformanceWindow(windowScene: scene)
        } else {
            window = PassThroughPerformanceWindow(frame: UIScreen.main.bounds)
        }

        window.windowLevel = .alert + 2
        window.backgroundColor = .clear
        let rootVC = UIViewController()
        rootVC.view.backgroundColor = .clear
        window.rootViewController = rootVC
        window.isHidden = false
        window.addSubview(self)
        floatingWindow = window
        keepInsideScreen(animated: false)
    }

    func hide() {
        removeFromSuperview()
        floatingWindow?.isHidden = true
        floatingWindow = nil
    }

    private func setupUI() {
        backgroundColor = UIColor.black.withAlphaComponent(0.84)
        layer.cornerRadius = 10
        layer.borderWidth = 1
        layer.borderColor = UIColor.white.withAlphaComponent(0.24).cgColor

        titleLabel.text = "PERF(性能观察)"
        titleLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        titleLabel.textColor = .white
        addSubview(titleLabel)

        closeButton.setTitle("x", for: .normal)
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.titleLabel?.font = .systemFont(ofSize: 13, weight: .bold)
        closeButton.backgroundColor = UIColor.red.withAlphaComponent(0.78)
        closeButton.layer.cornerRadius = 11
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        addSubview(closeButton)

        rowsStackView.axis = .vertical
        rowsStackView.alignment = .fill
        rowsStackView.distribution = .fillEqually
        rowsStackView.spacing = 1
        addSubview(rowsStackView)

        [
            "帧率(FPS)",
            "CPU(App)",
            "内存(MEM)",
            "",
            "网络(NET)",
            "",
            "流量(FLOW)",
            "UI卡顿(JANK)",
            "阻塞(STALL)",
            "电量(BAT)",
            "热状态"
        ].forEach { addMetricRow(title: $0) }

        configureActionButton(copyButton, title: "复制", action: #selector(copyTapped))
        configureActionButton(detailButton, title: "详细记录", action: #selector(detailTapped))
        configureActionButton(clearButton, title: "清空", action: #selector(clearTapped))
        [copyButton, detailButton, clearButton].forEach { addSubview($0) }
    }

    private func addMetricRow(title: String) {
        let row = UIStackView()
        row.axis = .horizontal
        row.alignment = .center
        row.distribution = .fill
        row.spacing = 4

        let metricLabel = UILabel()
        metricLabel.text = title
        metricLabel.font = .systemFont(ofSize: 10.5, weight: .medium)
        metricLabel.textColor = UIColor.white.withAlphaComponent(title.isEmpty ? 0.35 : 0.88)
        metricLabel.textAlignment = .left
        metricLabel.setContentHuggingPriority(.required, for: .horizontal)
        metricLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        let valueLabel = UILabel()
        valueLabel.font = .monospacedDigitSystemFont(ofSize: 10.5, weight: .semibold)
        valueLabel.textColor = .white
        valueLabel.textAlignment = .left
        valueLabel.adjustsFontSizeToFitWidth = true
        valueLabel.minimumScaleFactor = 0.72
        valueLabel.lineBreakMode = .byClipping
        valueLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        row.addArrangedSubview(metricLabel)
        row.addArrangedSubview(valueLabel)
        NSLayoutConstraint.activate([
            metricLabel.widthAnchor.constraint(equalToConstant: 84)
        ])
        rowsStackView.addArrangedSubview(row)
        valueLabels.append(valueLabel)
    }

    private func setValue(_ index: Int, _ parts: [(String, Bool)]) {
        guard valueLabels.indices.contains(index) else { return }

        let attributedText = NSMutableAttributedString()
        let labelAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.monospacedDigitSystemFont(ofSize: 10.5, weight: .regular),
            .foregroundColor: UIColor.white.withAlphaComponent(0.86)
        ]
        let valueAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.monospacedDigitSystemFont(ofSize: 10.5, weight: .semibold),
            .foregroundColor: UIColor.systemYellow
        ]

        for part in parts {
            attributedText.append(NSAttributedString(
                string: part.0,
                attributes: part.1 ? valueAttributes : labelAttributes
            ))
        }

        valueLabels[index].attributedText = attributedText
    }

    private func layoutActionButtons(y: CGFloat, height: CGFloat) {
        let padding: CGFloat = 9
        let spacing: CGFloat = 6
        let width = (bounds.width - padding * 2 - spacing * 2) / 3
        copyButton.frame = CGRect(x: padding, y: y, width: width, height: height)
        detailButton.frame = CGRect(x: copyButton.frame.maxX + spacing, y: y, width: width, height: height)
        clearButton.frame = CGRect(x: detailButton.frame.maxX + spacing, y: y, width: width, height: height)
    }

    private func configureActionButton(_ button: UIButton, title: String, action: Selector) {
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 11, weight: .medium)
        button.backgroundColor = UIColor.white.withAlphaComponent(0.16)
        button.layer.cornerRadius = 6
        button.addTarget(self, action: action, for: .touchUpInside)
    }

    private func setupGesture() {
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        addGestureRecognizer(panGesture)
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let window = floatingWindow else { return }
        let translation = gesture.translation(in: window)
        center = CGPoint(x: center.x + translation.x, y: center.y + translation.y)
        gesture.setTranslation(.zero, in: window)

        if gesture.state == .ended || gesture.state == .cancelled {
            keepInsideScreen(animated: true)
        }
    }

    private func keepInsideScreen(animated: Bool) {
        guard let window = floatingWindow else { return }
        var newFrame = frame
        let inset: CGFloat = 8
        let safeBounds = window.bounds.insetBy(dx: inset, dy: inset)
        if newFrame.width > safeBounds.width { newFrame.size.width = safeBounds.width }
        if newFrame.height > safeBounds.height { newFrame.size.height = safeBounds.height }
        if newFrame.minX < safeBounds.minX { newFrame.origin.x = safeBounds.minX }
        if newFrame.maxX > safeBounds.maxX { newFrame.origin.x = safeBounds.maxX - newFrame.width }
        if newFrame.minY < safeBounds.minY { newFrame.origin.y = safeBounds.minY }
        if newFrame.maxY > safeBounds.maxY { newFrame.origin.y = safeBounds.maxY - newFrame.height }
        let changes = { self.frame = newFrame }
        animated ? UIView.animate(withDuration: 0.25, animations: changes) : changes()
    }

    @objc private func copyTapped() {
        PerformanceMonitor.shared.suppressInternalActivity(reason: "ZWBLogTap overlay copy", duration: 1.0)
        UIPasteboard.general.string = PerformanceMonitor.shared.currentSnapshot().displayText()
        showToast("已复制")
    }

    @objc private func detailTapped() {
        PerformanceMonitor.shared.suppressInternalActivity(reason: "ZWBLogTap open performance detail", duration: 2.0)
        onDetail?()
    }

    @objc private func clearTapped() {
        PerformanceMonitor.shared.suppressInternalActivity(reason: "ZWBLogTap overlay clear", duration: 1.0)
        PerformanceMonitor.shared.clearLog()
        showToast("已清空")
    }

    @objc private func closeTapped() {
        PerformanceMonitor.shared.suppressInternalActivity(reason: "ZWBLogTap close performance overlay", duration: 1.0)
        onClose?()
        hide()
    }

    private func showToast(_ text: String) {
        let oldText = titleLabel.text
        titleLabel.text = text
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.titleLabel.text = oldText
        }
    }
}

private final class PassThroughPerformanceWindow: UIWindow {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let hitView = super.hitTest(point, with: event) else { return nil }
        if hitView == rootViewController?.view { return nil }
        return hitView
    }
}

// MARK: - ZWB Performance Log View Controller
final class PerformanceLogViewController: UIViewController {

    private let textView = UITextView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        reloadLog()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground

        let toolBar = UIView()
        toolBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toolBar)

        let closeButton = makeButton("关闭", action: #selector(closeTapped))
        let copyButton = makeButton("复制", action: #selector(copyTapped))
        let shareButton = makeButton("分享", action: #selector(shareTapped))
        let clearButton = makeButton("清空", action: #selector(clearTapped))

        [closeButton, copyButton, shareButton, clearButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            toolBar.addSubview($0)
        }

        let titleLabel = UILabel()
        titleLabel.text = "性能记录"
        titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        toolBar.addSubview(titleLabel)

        textView.isEditable = false
        textView.alwaysBounceVertical = true
        textView.font = .monospacedSystemFont(ofSize: 11, weight: .regular)
        textView.textColor = .label
        textView.backgroundColor = .secondarySystemBackground
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 10, bottom: 12, right: 10)
        textView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textView)

        NSLayoutConstraint.activate([
            toolBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            toolBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            toolBar.heightAnchor.constraint(equalToConstant: 50),

            closeButton.leadingAnchor.constraint(equalTo: toolBar.leadingAnchor, constant: 12),
            closeButton.centerYAnchor.constraint(equalTo: toolBar.centerYAnchor),

            titleLabel.centerXAnchor.constraint(equalTo: toolBar.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: toolBar.centerYAnchor),

            clearButton.trailingAnchor.constraint(equalTo: toolBar.trailingAnchor, constant: -12),
            clearButton.centerYAnchor.constraint(equalTo: toolBar.centerYAnchor),

            shareButton.trailingAnchor.constraint(equalTo: clearButton.leadingAnchor, constant: -10),
            shareButton.centerYAnchor.constraint(equalTo: toolBar.centerYAnchor),

            copyButton.trailingAnchor.constraint(equalTo: shareButton.leadingAnchor, constant: -10),
            copyButton.centerYAnchor.constraint(equalTo: toolBar.centerYAnchor),

            textView.topAnchor.constraint(equalTo: toolBar.bottomAnchor),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func makeButton(_ title: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    private func reloadLog() {
        let text = PerformanceMonitor.shared.currentLogText()
        textView.text = text.isEmpty ? "暂无性能记录。请先开启右侧开关并操作 App。" : text
    }

    @objc private func closeTapped() {
        PerformanceMonitor.shared.suppressInternalActivity(reason: "ZWBLogTap close performance detail", duration: 1.5)
        dismiss(animated: true)
    }

    @objc private func copyTapped() {
        PerformanceMonitor.shared.suppressInternalActivity(reason: "ZWBLogTap copy performance detail", duration: 1.0)
        UIPasteboard.general.string = textView.text
    }

    @objc private func shareTapped(_ sender: UIButton) {
        let monitor = PerformanceMonitor.shared
        monitor.suppressInternalActivity(reason: "ZWBLogTap share performance txt", duration: 60.0)

        sender.isEnabled = false
        let originalTitle = sender.title(for: .normal)
        sender.setTitle("准备中", for: .normal)

        monitor.currentLogFileURLAsync { [weak self, weak sender] url in
            guard let self = self else {
                monitor.endInternalActivitySuppression()
                return
            }

            sender?.isEnabled = true
            sender?.setTitle(originalTitle, for: .normal)

            guard let url = url else {
                monitor.endInternalActivitySuppression()
                return
            }

            let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            activityVC.completionWithItemsHandler = { _, _, _, _ in
                monitor.endInternalActivitySuppression()
            }

            if let popover = activityVC.popoverPresentationController {
                popover.sourceView = self.view
                popover.sourceRect = CGRect(x: self.view.bounds.midX, y: 50, width: 1, height: 1)
            }
            self.present(activityVC, animated: true)
        }
    }

    @objc private func clearTapped() {
        PerformanceMonitor.shared.suppressInternalActivity(reason: "ZWBLogTap clear performance detail", duration: 1.0)
        PerformanceMonitor.shared.clearLog()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            self?.reloadLog()
        }
    }
}
