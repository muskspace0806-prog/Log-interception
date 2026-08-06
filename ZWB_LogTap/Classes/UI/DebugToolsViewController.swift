//
//  DebugToolsViewController.swift
//  ZWB_LogTap
//
//  调试工具入口页面
//

import UIKit

class DebugToolsViewController: UIViewController {

    private var tableView: UITableView!
    private var closeButton: UIButton!

    private let sections = [
        Section(title: "环境配置", items: [
            ToolItem(title: "环境切换", icon: "🌍", subtitle: "切换测试/正式环境")
        ]),
        Section(title: "性能检测", items: [
            ToolItem(title: "性能悬浮窗", icon: "⚡️", subtitle: "FPS、CPU、内存、网络、JANK、阻塞、电量"),
            ToolItem(title: "房间压测", icon: "🧪", subtitle: "采集 IM 样本并打开独立压测悬浮入口"),
            ToolItem(title: "模拟弱网", icon: "🌐", subtitle: "断网、限速、延迟等"),
            ToolItem(title: "Crash 日志", icon: "💥", subtitle: "查看应用崩溃记录"),
            ToolItem(title: "内存监控", icon: "💾", subtitle: "实时监控内存使用")
        ]),
        Section(title: "日志管理", items: [
            ToolItem(title: "URL 过滤", icon: "🔗", subtitle: "过滤不需要的 URL 请求"),
            ToolItem(title: "HTTP 日志", icon: "🔍", subtitle: "查看网络请求日志"),
            ToolItem(title: "IM 日志", icon: "💬", subtitle: "查看 WebSocket 消息")
        ])
    ]

    struct Section {
        let title: String
        let items: [ToolItem]
    }

    struct ToolItem {
        let title: String
        let icon: String
        let subtitle: String
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView?.reloadData()
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
        titleLabel.text = "调试工具"
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        toolBar.addSubview(titleLabel)

        // 表格
        tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

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

            tableView.topAnchor.constraint(equalTo: toolBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    @objc private func closeTapped() {
        dismiss(animated: true)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension DebugToolsViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        let item = sections[indexPath.section].items[indexPath.row]

        cell.textLabel?.text = "\(item.icon) \(item.title)"

        // 环境切换显示当前环境
        if item.title == "环境切换" {
            let currentEnv = EnvironmentManager.shared.currentEnvironment
            cell.detailTextLabel?.text = "当前: \(currentEnv.name)"
        } else {
            cell.detailTextLabel?.text = item.subtitle
        }

        if item.title == "性能悬浮窗" {
            let enableSwitch = UISwitch()
            enableSwitch.isOn = ZWBLogTap.shared.isPerformanceMonitorEnabled
            enableSwitch.addTarget(self, action: #selector(performanceSwitchChanged(_:)), for: .valueChanged)
            cell.accessoryView = enableSwitch
            cell.accessoryType = .none
        } else if item.title == "房间压测" {
            let enableSwitch = UISwitch()
            enableSwitch.isOn = ZWBLogTap.shared.isRoomStressToolEnabled
            enableSwitch.addTarget(self, action: #selector(roomStressSwitchChanged(_:)), for: .valueChanged)
            cell.accessoryView = enableSwitch
            cell.accessoryType = .none
        } else {
            cell.accessoryView = nil
            cell.accessoryType = .disclosureIndicator
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let item = sections[indexPath.section].items[indexPath.row]

        switch item.title {
        case "环境切换":
            showEnvironmentSwitchAlert()
        case "性能悬浮窗":
            let vc = PerformanceLogViewController()
            present(vc, animated: true)
        case "房间压测":
            ZWBLogTap.shared.setRoomStressToolEnabled(!ZWBLogTap.shared.isRoomStressToolEnabled)
            tableView.reloadRows(at: [indexPath], with: .automatic)
        case "模拟弱网":
            let vc = NetworkSimulatorViewController()
            present(vc, animated: true)
        case "Crash 日志":
            let vc = CrashLogViewController()
            present(vc, animated: true)
        case "内存监控":
            let vc = MemoryMonitorViewController()
            present(vc, animated: true)
        case "URL 过滤":
            let vc = URLFilterViewController()
            present(vc, animated: true)
        case "HTTP 日志", "IM 日志":
            // 返回到主页面并切换到对应 tab
            dismiss(animated: true) {
                NotificationCenter.default.post(name: NSNotification.Name("SwitchToLogTab"), object: item.title)
            }
        default:
            break
        }
    }


    @objc private func performanceSwitchChanged(_ sender: UISwitch) {
        ZWBLogTap.shared.setPerformanceMonitorEnabled(sender.isOn)
    }

    @objc private func roomStressSwitchChanged(_ sender: UISwitch) {
        ZWBLogTap.shared.setRoomStressToolEnabled(sender.isOn)
    }

    // 显示环境切换弹窗
    private func showEnvironmentSwitchAlert() {
        let currentEnv = EnvironmentManager.shared.currentEnvironment
        let targetEnv = currentEnv.targetEnvironment

        let alert = UIAlertController(
            title: "环境切换",
            message: "当前环境: \(currentEnv.name)\n\n确定要切换到 \(targetEnv.name) 吗？",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "切换", style: .default) { [weak self] _ in
            // 执行切换
            ZWBLogTap.shared.switchEnvironment()

            // 刷新表格
            self?.tableView.reloadData()

            // 显示提示
            let successAlert = UIAlertController(
                title: "切换成功",
                message: "已切换到 \(targetEnv.name)",
                preferredStyle: .alert
            )
            successAlert.addAction(UIAlertAction(title: "确定", style: .default))
            self?.present(successAlert, animated: true)
        })

        present(alert, animated: true)
    }
}

// MARK: - 房间压测面板
final class RoomStressLogTapPanelViewController: UIViewController {

    var onClose: (() -> Void)?
    var onExitTool: (() -> Void)?
    /// 系统 pageSheet 手势关闭后的回调，用于同步外层悬浮入口状态。
    var onDidDismissByGesture: (() -> Void)?

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let routeButton = UIButton(type: .system)
    private let qpsField = UITextField()
    private let durationField = UITextField()
    private let currentRoomLabel = UILabel()
    private let metricsTitleLabel = UILabel()
    private let metricsLabel = UILabel()
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let selectAllButton = UIButton(type: .system)
    private let normalStressButton = UIButton(type: .system)
    private let randomStressButton = UIButton(type: .system)
    private let stopStressButton = UIButton(type: .system)
    private let refreshSamplesButton = UIButton(type: .system)
    private let clearSelectionButton = UIButton(type: .system)
    private let exportReportButton = UIButton(type: .system)
    private var tableHeightConstraint: NSLayoutConstraint?
    private var roomStressContextObserver: NSObjectProtocol?
    private var webSocketMessageObserver: NSObjectProtocol?

    private static var cachedSamples: [WebSocketMessage] = []
    private static var cachedSelectedSampleIds = Set<String>()
    private static var cachedRoomId: String?
    private static var cachedQPS = "20"
    private static var cachedDuration = "60"
    private static var sharedStressMode = "未运行"
    private static var sharedStressTimer: Timer?
    private static var sharedSampleTimer: Timer?
    private static var sharedStressEndDate: Date?
    private static var sharedSessionStartDate: Date?
    private static var sharedSessionEndDate: Date?
    private static var sharedStressCursor = 0
    private static var sharedInjectedCount = 0
    private static var sharedFailedCount = 0
    private static var sharedSessionSamples: [RoomStressMetricSample] = []
    private static let maxSessionSampleCount = 600

    private var samples: [WebSocketMessage] {
        get { Self.cachedSamples }
        set { Self.cachedSamples = newValue }
    }
    private var selectedSampleIds: Set<String> {
        get { Self.cachedSelectedSampleIds }
        set { Self.cachedSelectedSampleIds = newValue }
    }
    private var stressTimer: Timer? {
        get { Self.sharedStressTimer }
        set { Self.sharedStressTimer = newValue }
    }
    private var sampleTimer: Timer? {
        get { Self.sharedSampleTimer }
        set { Self.sharedSampleTimer = newValue }
    }
    private var stressEndDate: Date? {
        get { Self.sharedStressEndDate }
        set { Self.sharedStressEndDate = newValue }
    }
    private var stressCursor: Int {
        get { Self.sharedStressCursor }
        set { Self.sharedStressCursor = newValue }
    }
    private var injectedCount: Int {
        get { Self.sharedInjectedCount }
        set { Self.sharedInjectedCount = newValue }
    }
    private var failedCount: Int {
        get { Self.sharedFailedCount }
        set { Self.sharedFailedCount = newValue }
    }

    private struct RoomStressMetricSample {
        let offset: TimeInterval
        let fps: Int
        let cpu: Double
        let memory: Double
        let injected: Int
        let failed: Int
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "房间压测"
        view.backgroundColor = .systemBackground
        configureNavigationItems()
        buildUI()
        startPerformanceMonitorIfNeeded()
        observeRoomStressContext()
        observeWebSocketMessages()
        reloadSamples()
        updateMetrics()
        updateRunningStateUI()
    }

    deinit {
        saveInputState()
        if let roomStressContextObserver {
            NotificationCenter.default.removeObserver(roomStressContextObserver)
        }
        if let webSocketMessageObserver {
            NotificationCenter.default.removeObserver(webSocketMessageObserver)
        }
    }

    private func configureNavigationItems() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "关闭",
            style: .plain,
            target: self,
            action: #selector(closePanel)
        )
    }

    private func buildUI() {
        qpsField.text = Self.cachedQPS
        qpsField.placeholder = "每秒注入消息数"
        qpsField.keyboardType = .decimalPad
        durationField.text = Self.cachedDuration
        durationField.placeholder = "持续时间（秒）"
        durationField.keyboardType = .numberPad

        [qpsField, durationField].forEach {
            $0.borderStyle = .roundedRect
            $0.clearButtonMode = .whileEditing
            $0.autocorrectionType = .no
            $0.autocapitalizationType = .none
        }

        routeButton.contentHorizontalAlignment = .left
        routeButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        routeButton.titleLabel?.numberOfLines = 1
        routeButton.titleLabel?.adjustsFontSizeToFitWidth = true
        routeButton.titleLabel?.minimumScaleFactor = 0.78
        routeButton.backgroundColor = .secondarySystemBackground
        routeButton.layer.cornerRadius = 8
        routeButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        routeButton.addTarget(self, action: #selector(showSelectedTypes), for: .touchUpInside)

        currentRoomLabel.numberOfLines = 0
        currentRoomLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        currentRoomLabel.textColor = .label

        metricsLabel.numberOfLines = 0
        metricsLabel.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
        metricsLabel.textColor = .label
        metricsLabel.backgroundColor = .secondarySystemBackground
        metricsLabel.layer.cornerRadius = 8
        metricsLabel.clipsToBounds = true

        metricsTitleLabel.text = "实时性能"
        metricsTitleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        metricsTitleLabel.textColor = .label

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(WebSocketMessageCell.self, forCellReuseIdentifier: "RoomStressLogTapSampleCell")
        tableView.rowHeight = 168
        tableView.isScrollEnabled = false
        tableView.tableFooterView = UIView()
        tableView.layer.cornerRadius = 8
        tableView.clipsToBounds = true
        tableView.layoutMargins = .zero
        tableView.separatorInset = .zero
        tableView.cellLayoutMarginsFollowReadableWidth = false

        [
            currentRoomLabel,
            makeFormRow(title: "已选类型", control: routeButton),
            makeFormRow(title: "总 QPS\n(每秒注入消息数)", control: qpsField),
            makeFormRow(title: "持续时间", control: durationField, suffix: "秒"),
            makeActionGrid(),
            metricsTitleLabel,
            metricsLabel,
            makeListTitle(),
            makeSampleSelectionRow(),
            tableView
        ].forEach { contentStack.addArrangedSubview($0) }

        contentStack.axis = .vertical
        contentStack.spacing = 10
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .onDrag
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)

        tableHeightConstraint = tableView.heightAnchor.constraint(equalToConstant: 120)
        tableHeightConstraint?.isActive = true

        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -16),
            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 12),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -24),
            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -32)
        ])
    }

    private func makeFormRow(title: String, control: UIView, suffix: String? = nil) -> UIView {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 0
        titleLabel.widthAnchor.constraint(equalToConstant: 126).isActive = true

        let row = UIStackView()
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 10
        row.addArrangedSubview(titleLabel)
        row.addArrangedSubview(control)

        control.setContentHuggingPriority(.defaultLow, for: .horizontal)
        control.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        if let suffix {
            let suffixLabel = UILabel()
            suffixLabel.text = suffix
            suffixLabel.font = .systemFont(ofSize: 14)
            suffixLabel.textColor = .secondaryLabel
            row.addArrangedSubview(suffixLabel)
        }

        return row
    }

    private func configureButton(_ button: UIButton, title: String, action: Selector) -> UIButton {
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        button.titleLabel?.numberOfLines = 1
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.82
        button.backgroundColor = .secondarySystemBackground
        button.layer.cornerRadius = 8
        button.heightAnchor.constraint(equalToConstant: 40).isActive = true
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    private func makeActionGrid() -> UIView {
        let rows = [
            [
                configureButton(normalStressButton, title: "普通压测", action: #selector(startStress)),
                configureButton(randomStressButton, title: "随机压测", action: #selector(startRandomStress))
            ],
            [
                configureButton(stopStressButton, title: "停止压测", action: #selector(stopStress)),
                configureButton(refreshSamplesButton, title: "刷新IM样本", action: #selector(refreshAll))
            ],
            [
                configureButton(clearSelectionButton, title: "清空选择", action: #selector(clearSelection)),
                configureButton(exportReportButton, title: "导出报告", action: #selector(exportReport))
            ]
        ]

        let grid = UIStackView()
        grid.axis = .vertical
        grid.spacing = 8

        rows.forEach { buttons in
            let row = UIStackView(arrangedSubviews: buttons)
            row.axis = .horizontal
            row.distribution = buttons.count == 1 ? .fill : .fillEqually
            row.spacing = 8
            grid.addArrangedSubview(row)
        }

        return grid
    }

    private func makeSmallButton(title: String, imageName: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setImage(UIImage(systemName: imageName), for: .normal)
        button.tintColor = .systemBlue
        button.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
        button.backgroundColor = .tertiarySystemBackground
        button.layer.cornerRadius = 7
        button.heightAnchor.constraint(equalToConstant: 34).isActive = true
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    private func makeListTitle() -> UILabel {
        let label = UILabel()
        label.text = "已采集样本"
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        return label
    }

    private func makeSampleSelectionRow() -> UIView {
        configureSelectAllButton()

        let container = UIView()
        container.layoutMargins = .zero
        selectAllButton.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(selectAllButton)
        NSLayoutConstraint.activate([
            selectAllButton.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            selectAllButton.topAnchor.constraint(equalTo: container.topAnchor),
            selectAllButton.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        return container
    }

    private func configureSelectAllButton() {
        let isAllSelected = !samples.isEmpty && selectedSampleIds.count == samples.count
        let title = isAllSelected ? "取消全选" : "全选"
        let imageName = isAllSelected ? "checkmark.circle.fill" : "circle"
        selectAllButton.setTitle(title, for: .normal)
        selectAllButton.setImage(UIImage(systemName: imageName), for: .normal)
        selectAllButton.tintColor = .systemBlue
        selectAllButton.contentHorizontalAlignment = .left
        selectAllButton.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
        selectAllButton.backgroundColor = .tertiarySystemBackground
        selectAllButton.layer.cornerRadius = 7
        if !selectAllButton.constraints.contains(where: { $0.firstAttribute == .height }) {
            selectAllButton.heightAnchor.constraint(equalToConstant: 34).isActive = true
        }
        if !selectAllButton.constraints.contains(where: { $0.firstAttribute == .width }) {
            selectAllButton.widthAnchor.constraint(equalToConstant: 96).isActive = true
        }
        selectAllButton.removeTarget(nil, action: nil, for: .touchUpInside)
        selectAllButton.addTarget(self, action: #selector(toggleSelectAllSamples), for: .touchUpInside)
    }

    private func reloadSamples() {
        saveInputState()
        if let cachedRoomId = Self.cachedRoomId,
           cachedRoomId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || Int(cachedRoomId) == 0 {
            Self.cachedRoomId = nil
        }
        let messages = ZWBLogTap.shared.getAllWebSocketMessages()
        let manualRoomId = ZWBLogTap.shared.currentRoomStressRoomId
        let latestRoomId = messages.compactMap { message -> String? in
            return message.roomStressRoomId
        }.first
        let eligibleMessages = messages.filter { message in
            guard message.type == .receive else { return false }
            guard !message.dataString.isEmpty else { return false }
            let firstSecond = message.firstSecond
            return firstSecond.first != nil || firstSecond.second != nil
        }
        if let manualRoomId, manualRoomId != Self.cachedRoomId {
            resetRoomState(for: manualRoomId)
        } else if manualRoomId == nil, let latestRoomId, latestRoomId != Self.cachedRoomId {
            resetRoomState(for: latestRoomId)
        } else if Self.cachedRoomId == nil {
            Self.cachedRoomId = manualRoomId ?? latestRoomId
        }

        if manualRoomId == nil, latestRoomId == nil, Self.cachedRoomId != nil, messages.isEmpty {
            resetRoomState(for: nil)
        }

        if manualRoomId == nil, latestRoomId == nil, Self.cachedRoomId == nil {
            samples.removeAll()
        } else if Self.cachedRoomId == nil {
            Self.cachedRoomId = manualRoomId ?? latestRoomId
        }

        var dedupKeys = Set<String>()
        samples = eligibleMessages.filter { message in
            if let roomId = Self.cachedRoomId,
               let messageRoomId = message.roomStressRoomId,
               messageRoomId != roomId {
                return false
            }

            guard let key = message.roomStressDedupKey else {
                return true
            }
            if dedupKeys.contains(key) {
                return false
            }
            dedupKeys.insert(key)
            return true
        }

        updateSelectedTypesButton()
        updateCurrentRoomLabel()
        selectedSampleIds = selectedSampleIds.intersection(Set(samples.map { $0.id }))
        configureSelectAllButton()
        tableView.reloadData()
        tableHeightConstraint?.constant = CGFloat(max(1, samples.count)) * tableView.rowHeight
        updateMetrics()
    }

    private func updateSelectedTypesButton() {
        let selectedMessages = samples.filter { selectedSampleIds.contains($0.id) }
        let title: String
        if selectedMessages.isEmpty {
            title = "未选择"
        } else if selectedMessages.count == 1 {
            title = selectedMessages[0].firstSecondDisplayText
        } else {
            title = "已选 \(selectedMessages.count) 条"
        }
        routeButton.setTitle("  已选类型：\(title)", for: .normal)
    }

    private func updateCurrentRoomLabel() {
        let roomId = Self.cachedRoomId ?? samples.compactMap { $0.roomStressRoomId }.first ?? "未识别"
        currentRoomLabel.text = "当前房间：\(roomId)"
    }

    private func updateMetrics() {
        startPerformanceMonitorIfNeeded()
        let snapshot = PerformanceMonitor.shared.currentSnapshot()
        let runningState = isStressRunning ? "压测中" : "未运行"
        metricsLabel.attributedText = makeMetricsText([
            [("  FPS 当前 ", false), ("\(snapshot.fpsCurrent)", true), ("    平均 ", false), ("\(snapshot.fpsAverage)", true), ("    最低 ", false), ("\(snapshot.fpsMin)", true)],
            [("  CPU 当前 ", false), (String(format: "%.0f%%", snapshot.cpuCurrent), true), ("    峰值 ", false), (String(format: "%.0f%%", snapshot.cpuPeak), true)],
            [("  内存 当前 ", false), (String(format: "%.0fMB", snapshot.memoryCurrentMB), true), ("    峰值 ", false), (String(format: "%.0fMB", snapshot.memoryPeakMB), true)],
            [("  状态 ", false), (runningState, true), ("    模式 ", false), (Self.sharedStressMode, true), ("    剩余 ", false), (remainingStressTimeText(), true)],
            [("  样本 ", false), ("\(samples.count)", true), ("    已选 ", false), ("\(selectedSampleIds.count)", true)],
            [("  注入 ", false), ("\(injectedCount)", true), ("    失败 ", false), ("\(failedCount)", true)]
        ])
        updateRunningStateUI()
    }

    private func makeMetricsText(_ rows: [[(String, Bool)]]) -> NSAttributedString {
        let text = NSMutableAttributedString()
        let normalAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.monospacedSystemFont(ofSize: 13, weight: .regular),
            .foregroundColor: UIColor.label
        ]
        let valueAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.monospacedSystemFont(ofSize: 13, weight: .semibold),
            .foregroundColor: UIColor.systemPurple
        ]

        rows.enumerated().forEach { index, row in
            row.forEach { item in
                text.append(NSAttributedString(string: item.0, attributes: item.1 ? valueAttributes : normalAttributes))
            }
            if index < rows.count - 1 {
                text.append(NSAttributedString(string: "\n", attributes: normalAttributes))
            }
        }
        return text
    }

    @objc private func closePanel() {
        onClose?()
    }

    @objc private func showSelectedTypes() {
        let selectedMessages = samples.filter { selectedSampleIds.contains($0.id) }
        let alert = UIAlertController(title: "已选类型", message: nil, preferredStyle: .actionSheet)
        if selectedMessages.isEmpty {
            alert.message = "未选择 IM 样本"
        } else {
            selectedMessages.forEach { message in
                alert.addAction(UIAlertAction(title: sampleDisplayTitle(message), style: .default))
            }
        }
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        present(alert, animated: true)
    }

    @objc private func startStress() {
        runStress(randomized: false)
    }

    @objc private func startRandomStress() {
        runStress(randomized: true)
    }

    private func runStress(randomized: Bool) {
        saveInputState()
        startPerformanceMonitorIfNeeded()
        let selectedMessages = samples.filter { selectedSampleIds.contains($0.id) }
        guard !selectedMessages.isEmpty else {
            showAlert(title: "缺少样本", message: "请先选择至少一条 IM 样本。")
            return
        }

        let qps = max(Double(qpsField.text ?? "") ?? 1, 1)
        let duration = max(Double(durationField.text ?? "") ?? 60, 1)
        let interval = max(1.0 / qps, 0.001)
        stressEndDate = Date().addingTimeInterval(duration)
        stressCursor = 0
        stressTimer?.invalidate()
        startMetricSession(mode: randomized ? "随机" : "顺序")

        stressTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] timer in
            guard let endDate = Self.sharedStressEndDate, Date() < endDate else {
                if let self = self {
                    self.finishStressSession(timer: timer)
                } else {
                    Self.finishSharedStressSession(timer: timer)
                }
                return
            }

            let template: WebSocketMessage
            if randomized {
                template = selectedMessages.randomElement() ?? selectedMessages[Self.sharedStressCursor % selectedMessages.count]
            } else {
                template = selectedMessages[Self.sharedStressCursor % selectedMessages.count]
            }
            Self.sharedStressCursor += 1
            let message = randomized ? template.randomizedGiftStressMessage() : template
            if ZWBLogTap.shared.triggerWebSocketMockReceive(message) {
                Self.sharedInjectedCount += 1
            } else {
                Self.sharedFailedCount += 1
                if let self = self {
                    self.finishStressSession(timer: timer)
                    self.showAlert(title: "缺少入口", message: "未配置 IM 模拟接收处理入口。")
                } else {
                    Self.finishSharedStressSession(timer: timer)
                }
            }
            self?.updateMetrics()
        }
        RunLoop.main.add(stressTimer!, forMode: .common)
        updateMetrics()
        updateRunningStateUI()
        onClose?()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            ZWBLogTap.shared.dismissLogViewControllerIfNeeded()
        }
    }

    @objc private func stopStress() {
        finishStressSession(timer: stressTimer)
        updateMetrics()
        updateRunningStateUI()
    }

    @objc private func refreshAll() {
        reloadSamples()
    }

    @objc private func clearSelection() {
        selectedSampleIds.removeAll()
        saveInputState()
        configureSelectAllButton()
        updateSelectedTypesButton()
        tableView.reloadData()
        updateMetrics()
    }

    @objc private func exportReport() {
        saveInputState()
        let alert = UIAlertController(title: "导出报告", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "拷贝报告", style: .default) { [weak self] _ in
            guard let self else { return }
            let report = self.makeRoomStressReport()
            UIPasteboard.general.string = report
            self.showAlert(title: "已拷贝", message: "房间压测报告已复制到剪贴板。")
        })
        alert.addAction(UIAlertAction(title: "分享报告", style: .default) { [weak self] _ in
            self?.shareRoomStressReport()
        })
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        present(alert, animated: true)
    }

    @objc private func toggleSelectAllSamples() {
        if !samples.isEmpty && selectedSampleIds.count == samples.count {
            selectedSampleIds.removeAll()
        } else {
            selectedSampleIds = Set(samples.map { $0.id })
        }
        saveInputState()
        configureSelectAllButton()
        updateSelectedTypesButton()
        tableView.reloadData()
        updateMetrics()
    }

    private func saveInputState() {
        Self.cachedQPS = qpsField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false ? (qpsField.text ?? "20") : "20"
        Self.cachedDuration = durationField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false ? (durationField.text ?? "60") : "60"
    }

    private var isStressRunning: Bool {
        stressTimer != nil
    }

    private func remainingStressTimeText() -> String {
        guard isStressRunning, let stressEndDate else {
            return "0秒"
        }
        return "\(Int(ceil(max(0, stressEndDate.timeIntervalSinceNow))))秒"
    }

    private func updateRunningStateUI() {
        let running = isStressRunning
        qpsField.isEnabled = !running
        durationField.isEnabled = !running
        routeButton.isEnabled = !running
        normalStressButton.isEnabled = !running
        randomStressButton.isEnabled = !running
        refreshSamplesButton.isEnabled = !running
        clearSelectionButton.isEnabled = !running
        selectAllButton.isEnabled = !running
        stopStressButton.isEnabled = running
        exportReportButton.isEnabled = true
        tableView.allowsSelection = !running
        [qpsField, durationField, routeButton, normalStressButton, randomStressButton, refreshSamplesButton, clearSelectionButton, selectAllButton].forEach {
            $0.alpha = running ? 0.45 : 1
        }
        stopStressButton.alpha = running ? 1 : 0.45
        exportReportButton.alpha = 1
        tableView.visibleCells.forEach { cell in
            cell.accessoryView?.isUserInteractionEnabled = !running
            cell.accessoryView?.alpha = running ? 0.45 : 1
        }
    }

    private func startPerformanceMonitorIfNeeded() {
        guard !PerformanceMonitor.shared.isEnabled else { return }
        PerformanceMonitor.shared.start()
    }

    private func observeRoomStressContext() {
        roomStressContextObserver = NotificationCenter.default.addObserver(
            forName: .roomStressContextDidChange,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            let roomId = notification.object as? String
            self?.resetRoomState(for: roomId)
            self?.reloadSamples()
        }
    }

    private func observeWebSocketMessages() {
        webSocketMessageObserver = NotificationCenter.default.addObserver(
            forName: .webSocketMessageIntercepted,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard ZWBLogTap.shared.currentRoomStressRoomId == nil,
                  let message = notification.object as? WebSocketMessage,
                  message.route == "enterWithOpenChatRoom",
                  let roomId = message.roomStressRoomId,
                  roomId != Self.cachedRoomId else {
                return
            }
            self?.resetRoomState(for: roomId)
            self?.reloadSamples()
        }
    }

    private func startMetricSession(mode: String) {
        Self.sharedStressMode = mode
        Self.sharedSessionStartDate = Date()
        Self.sharedSessionEndDate = nil
        Self.sharedSessionSamples.removeAll()
        Self.sharedInjectedCount = 0
        Self.sharedFailedCount = 0
        recordMetricSample()
        sampleTimer?.invalidate()
        sampleTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.recordMetricSample()
        }
        if let sampleTimer {
            RunLoop.main.add(sampleTimer, forMode: .common)
        }
    }

    private func resetRoomState(for roomId: String?) {
        stressTimer?.invalidate()
        stressTimer = nil
        sampleTimer?.invalidate()
        sampleTimer = nil
        stressEndDate = nil
        Self.cachedRoomId = roomId
        Self.cachedSamples.removeAll()
        Self.cachedSelectedSampleIds.removeAll()
        Self.sharedStressMode = "未运行"
        Self.sharedStressCursor = 0
        Self.sharedInjectedCount = 0
        Self.sharedFailedCount = 0
        Self.sharedSessionStartDate = nil
        Self.sharedSessionEndDate = nil
        Self.sharedSessionSamples.removeAll()
    }

    private func finishStressSession(timer: Timer?) {
        recordMetricSample()
        Self.finishSharedStressSession(timer: timer)
        updateMetrics()
    }

    /// 页面已释放时也要清理共享压测状态，避免重新进入仍显示压测中。
    private static func finishSharedStressSession(timer: Timer?) {
        timer?.invalidate()
        sharedStressTimer?.invalidate()
        sharedStressTimer = nil
        sharedStressEndDate = nil
        sharedSampleTimer?.invalidate()
        sharedSampleTimer = nil
        sharedSessionEndDate = Date()
    }

    private func recordMetricSample() {
        guard let startDate = Self.sharedSessionStartDate else { return }
        let snapshot = PerformanceMonitor.shared.currentSnapshot()
        let sample = RoomStressMetricSample(
            offset: Date().timeIntervalSince(startDate),
            fps: snapshot.fpsCurrent,
            cpu: snapshot.cpuCurrent,
            memory: snapshot.memoryCurrentMB,
            injected: injectedCount,
            failed: failedCount
        )
        Self.sharedSessionSamples.append(sample)
        if Self.sharedSessionSamples.count > Self.maxSessionSampleCount {
            Self.sharedSessionSamples.removeFirst(Self.sharedSessionSamples.count - Self.maxSessionSampleCount)
        }
    }

    private func shareRoomStressReport() {
        let loading = makeLoadingAlert(message: "正在准备报告...")
        present(loading, animated: true) { [weak self] in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                guard let self else { return }
                let report = self.makeRoomStressReport()
                let activityVC = UIActivityViewController(activityItems: [report], applicationActivities: nil)
                if let popover = activityVC.popoverPresentationController {
                    popover.sourceView = self.view
                    popover.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                    popover.permittedArrowDirections = []
                }
                loading.dismiss(animated: false) {
                    self.present(activityVC, animated: true)
                }
            }
        }
    }

    private func makeLoadingAlert(message: String) -> UIAlertController {
        let alert = UIAlertController(title: nil, message: "\n\n\(message)", preferredStyle: .alert)
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.startAnimating()
        alert.view.addSubview(indicator)
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: alert.view.centerXAnchor),
            indicator.topAnchor.constraint(equalTo: alert.view.topAnchor, constant: 24)
        ])
        return alert
    }

    private func sampleDisplayTitle(_ message: WebSocketMessage) -> String {
        "\(message.route ?? message.host)  \(message.firstSecondDisplayText)"
    }

    private func makeRoomStressReport() -> String {
        let snapshot = PerformanceMonitor.shared.currentSnapshot()
        let selectedMessages = samples.filter { selectedSampleIds.contains($0.id) }
        let runningState = stressTimer == nil ? "未运行" : "压测中"
        let endText: String
        if let stressEndDate {
            let remaining = max(0, stressEndDate.timeIntervalSinceNow)
            endText = String(format: "剩余 %.1f 秒", remaining)
        } else {
            endText = "无"
        }

        var lines: [String] = [
            "# RoomStress 房间压测报告",
            "生成时间：\(Self.reportDateFormatter.string(from: Date()))",
            "当前房间：\(currentRoomLabel.text?.replacingOccurrences(of: "当前房间：", with: "") ?? "未识别")",
            "",
            "## 压测配置",
            "总 QPS（每秒注入消息数）：\(Self.cachedQPS)",
            "持续时间：\(Self.cachedDuration) 秒",
            "压测模式：\(Self.sharedStressMode)",
            "运行状态：\(runningState)",
            "结束倒计时：\(endText)",
            "",
            "## 实时性能",
            "FPS：当前 \(snapshot.fpsCurrent) / 平均 \(snapshot.fpsAverage) / 最低 \(snapshot.fpsMin)",
            String(format: "CPU：当前 %.0f%% / 峰值 %.0f%%", snapshot.cpuCurrent, snapshot.cpuPeak),
            String(format: "内存：当前 %.0fMB / 峰值 %.0fMB", snapshot.memoryCurrentMB, snapshot.memoryPeakMB),
            "",
            "## 本次压测统计",
            sessionSummaryText(),
            "",
            "## 注入统计",
            "已采集样本：\(samples.count)",
            "已选样本：\(selectedMessages.count)",
            "注入成功：\(injectedCount)",
            "失败：\(failedCount)",
            "",
            "## 已选类型"
        ]

        if selectedMessages.isEmpty {
            lines.append("未选择")
        } else {
            selectedMessages.enumerated().forEach { index, message in
                lines.append("\(index + 1). \(sampleDisplayTitle(message))")
            }
        }

        lines.append("")
        lines.append("## 已采集样本")
        if samples.isEmpty {
            lines.append("无")
        } else {
            samples.enumerated().forEach { index, message in
                lines.append("\(index + 1). \(sampleReportLine(message))")
            }
        }

        lines.append("")
        lines.append("## 详细采样日志")
        let sampleLines = metricSampleLogLines()
        lines.append(contentsOf: sampleLines.isEmpty ? ["无"] : sampleLines)

        return lines.joined(separator: "\n")
    }

    private func sessionSummaryText() -> String {
        let sessionSamples = Self.sharedSessionSamples
        guard !sessionSamples.isEmpty else {
            return "暂无本次压测采样数据"
        }

        let fpsValues = sessionSamples.map { $0.fps }
        let cpuValues = sessionSamples.map { $0.cpu }
        let memoryValues = sessionSamples.map { $0.memory }
        let fpsAverage = fpsValues.reduce(0, +) / max(fpsValues.count, 1)
        let fpsMin = fpsValues.min() ?? 0
        let lowFPSCount = fpsValues.filter { $0 > 0 && $0 < 50 }.count
        let cpuAverage = cpuValues.reduce(0, +) / Double(max(cpuValues.count, 1))
        let cpuPeak = cpuValues.max() ?? 0
        let memoryStart = memoryValues.first ?? 0
        let memoryEnd = memoryValues.last ?? 0
        let memoryPeak = memoryValues.max() ?? 0
        let actualDuration = sessionDuration()
        let actualQPS = actualDuration > 0 ? Double(injectedCount) / actualDuration : 0

        return [
            "实际运行时长：\(String(format: "%.1f", actualDuration)) 秒",
            "压测模式：\(Self.sharedStressMode)",
            "目标 QPS：\(Self.cachedQPS)",
            "实际 QPS：\(String(format: "%.1f", actualQPS))",
            "FPS：平均 \(fpsAverage) / 最低 \(fpsMin) / 低于50次数 \(lowFPSCount)",
            String(format: "CPU：平均 %.0f%% / 峰值 %.0f%%", cpuAverage, cpuPeak),
            String(format: "内存：开始 %.0fMB / 结束 %.0fMB / 峰值 %.0fMB / 增长 %.0fMB", memoryStart, memoryEnd, memoryPeak, memoryEnd - memoryStart)
        ].joined(separator: "\n")
    }

    private func sessionDuration() -> TimeInterval {
        guard let startDate = Self.sharedSessionStartDate else { return 0 }
        return (Self.sharedSessionEndDate ?? Date()).timeIntervalSince(startDate)
    }

    private func metricSampleLogLines() -> [String] {
        Self.sharedSessionSamples.map { sample in
            String(
                format: "%@  FPS %2d  CPU %3.0f%%  MEM %4.0fMB  注入 %d  失败 %d%@",
                sampleOffsetText(sample.offset),
                sample.fps,
                sample.cpu,
                sample.memory,
                sample.injected,
                sample.failed,
                sample.fps > 0 && sample.fps < 50 ? "  LOW_FPS" : ""
            )
        }
    }

    private func sampleOffsetText(_ offset: TimeInterval) -> String {
        let seconds = max(0, Int(offset.rounded()))
        return String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }

    private func sampleReportLine(_ message: WebSocketMessage) -> String {
        let fields = Dictionary(uniqueKeysWithValues: message.giftInfoFields.map { ($0.name, $0.value ?? "nil") })
        let route = message.route ?? message.host
        return "\(route) \(message.firstSecondDisplayText) giftName:\(fields["giftName"] ?? "nil") giftId:\(fields["giftId"] ?? "nil") giftNum:\(fields["giftNum"] ?? "nil") giftType:\(fields["giftType"] ?? "nil") isWholeMic:\(fields["isWholeMic"] ?? "nil") comboCount:\(fields["comboCount"] ?? "nil")"
    }

    private static let reportDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }

    private static func fieldValue(named fieldName: String, in text: String) -> String? {
        let pattern = "\"\(fieldName)\"\\s*:\\s*\"?([^\",}\\s]+)"
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }
        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        guard let match = regex.firstMatch(in: text, range: range),
              match.numberOfRanges > 1,
              let valueRange = Range(match.range(at: 1), in: text) else {
            return nil
        }
        return String(text[valueRange])
    }
}

extension RoomStressLogTapPanelViewController: UIAdaptivePresentationControllerDelegate {

    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        onDidDismissByGesture?()
    }
}

extension RoomStressLogTapPanelViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        samples.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "RoomStressLogTapSampleCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! WebSocketMessageCell
        let sample = samples[indexPath.row]
        let selected = selectedSampleIds.contains(sample.id)
        cell.configure(with: sample, isMockSelected: false, showsMockActions: false)
        cell.layoutMargins = .zero
        cell.separatorInset = .zero
        cell.preservesSuperviewLayoutMargins = false
        let imageName = selected ? "checkmark.circle.fill" : "circle"
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: imageName), for: .normal)
        button.tintColor = selected ? .systemBlue : .tertiaryLabel
        button.contentHorizontalAlignment = .center
        button.contentVerticalAlignment = .center
        button.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        button.tag = indexPath.row
        button.addTarget(self, action: #selector(toggleSampleSelectionButtonTapped(_:)), for: .touchUpInside)
        button.isUserInteractionEnabled = !isStressRunning
        button.alpha = isStressRunning ? 0.45 : 1
        cell.accessoryView = button
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let detailVC = WebSocketMessageDetailViewController()
        detailVC.message = samples[indexPath.row]
        present(detailVC, animated: true)
    }

    @objc private func toggleSampleSelectionButtonTapped(_ sender: UIButton) {
        guard !isStressRunning else { return }
        guard sender.tag >= 0 && sender.tag < samples.count else { return }
        let indexPath = IndexPath(row: sender.tag, section: 0)
        let id = samples[sender.tag].id
        if selectedSampleIds.contains(id) {
            selectedSampleIds.remove(id)
        } else {
            selectedSampleIds.insert(id)
        }
        saveInputState()
        configureSelectAllButton()
        updateSelectedTypesButton()
        tableView.reloadRows(at: [indexPath], with: .automatic)
        updateMetrics()
    }
}
