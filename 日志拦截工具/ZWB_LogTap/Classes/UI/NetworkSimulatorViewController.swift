//
//  NetworkSimulatorViewController.swift
//  ZWB_LogTap
//
//  模拟弱网页面
//

import UIKit

class NetworkSimulatorViewController: UIViewController {
    
    private var tableView: UITableView!
    private var closeButton: UIButton!
    private var enableSwitch: UISwitch!
    private var modeSegment: UISegmentedControl!
    private var configStackView: UIStackView!
    private var floatingWindow: FloatingInfoWindow?
    
    // 输入框
    private var delayTextField: UITextField?
    private var requestSpeedTextField: UITextField?
    private var responseSpeedTextField: UITextField?
    
    private let modes: [NetworkSimulator.SimulationMode] = [.disconnect, .timeout, .speedLimit, .delay]
    private let modeNames = ["断网", "超时", "限速", "延迟"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateUI()
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
        titleLabel.text = "模拟弱网测试"
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        toolBar.addSubview(titleLabel)
        
        // 滚动视图
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        // 内容容器
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        // 弱网模式开关
        let switchContainer = createSwitchRow(title: "弱网模式")
        enableSwitch = switchContainer.arrangedSubviews.last as? UISwitch
        enableSwitch.addTarget(self, action: #selector(enableSwitchChanged), for: .valueChanged)
        contentView.addSubview(switchContainer)
        
        // 模式选择
        modeSegment = UISegmentedControl(items: modeNames)
        modeSegment.selectedSegmentIndex = 0
        modeSegment.addTarget(self, action: #selector(modeChanged), for: .valueChanged)
        modeSegment.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(modeSegment)
        
        // 配置区域
        configStackView = UIStackView()
        configStackView.axis = .vertical
        configStackView.spacing = 16
        configStackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(configStackView)
        
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
            
            scrollView.topAnchor.constraint(equalTo: toolBar.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            switchContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            switchContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            switchContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            modeSegment.topAnchor.constraint(equalTo: switchContainer.bottomAnchor, constant: 20),
            modeSegment.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            modeSegment.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            configStackView.topAnchor.constraint(equalTo: modeSegment.bottomAnchor, constant: 20),
            configStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            configStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            configStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    private func createSwitchRow(title: String) -> UIStackView {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 16)
        
        let switchControl = UISwitch()
        
        stack.addArrangedSubview(label)
        stack.addArrangedSubview(switchControl)
        
        return stack
    }
    
    private func updateUI() {
        let simulator = NetworkSimulator.shared
        enableSwitch.isOn = simulator.isEnabled
        
        // 更新配置区域
        configStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let selectedMode = modes[modeSegment.selectedSegmentIndex]
        
        switch selectedMode {
        case .delay:
            let container = createInputRow(title: "延迟时间 (秒):", value: "\(Int(simulator.delaySeconds))")
            delayTextField = container.arrangedSubviews.last as? UITextField
            delayTextField?.keyboardType = .numberPad
            configStackView.addArrangedSubview(container)
            
        case .speedLimit:
            let requestContainer = createInputRow(title: "请求限速 (KB/s):", value: "\(simulator.requestSpeedLimit)")
            requestSpeedTextField = requestContainer.arrangedSubviews.last as? UITextField
            requestSpeedTextField?.keyboardType = .numberPad
            configStackView.addArrangedSubview(requestContainer)
            
            let responseContainer = createInputRow(title: "响应限速 (KB/s):", value: "\(simulator.responseSpeedLimit)")
            responseSpeedTextField = responseContainer.arrangedSubviews.last as? UITextField
            responseSpeedTextField?.keyboardType = .numberPad
            configStackView.addArrangedSubview(responseContainer)
            
        default:
            break
        }
    }
    
    private func createInputRow(title: String, value: String) -> UIStackView {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fill
        
        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 14)
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        let textField = UITextField()
        textField.text = value
        textField.borderStyle = .roundedRect
        textField.font = .systemFont(ofSize: 14)
        textField.textAlignment = .right
        textField.delegate = self
        
        stack.addArrangedSubview(label)
        stack.addArrangedSubview(textField)
        
        return stack
    }
    
    @objc private func closeTapped() {
        dismiss(animated: true)
    }
    
    @objc private func enableSwitchChanged() {
        // 先更新配置值
        updateSimulatorConfig()
        
        if enableSwitch.isOn {
            let mode = modes[modeSegment.selectedSegmentIndex]
            NetworkSimulator.shared.enable(mode: mode)
            showFloatingWindow()
        } else {
            NetworkSimulator.shared.disable()
            hideFloatingWindow()
        }
        updateUI()
    }
    
    @objc private func modeChanged() {
        if enableSwitch.isOn {
            updateSimulatorConfig()
            let mode = modes[modeSegment.selectedSegmentIndex]
            NetworkSimulator.shared.enable(mode: mode)
            updateFloatingWindow()
        }
        updateUI()
    }
    
    private func updateSimulatorConfig() {
        let simulator = NetworkSimulator.shared
        
        if let delayText = delayTextField?.text, let delay = TimeInterval(delayText) {
            simulator.delaySeconds = delay
        }
        if let requestText = requestSpeedTextField?.text, let speed = Int(requestText) {
            simulator.requestSpeedLimit = speed
        }
        if let responseText = responseSpeedTextField?.text, let speed = Int(responseText) {
            simulator.responseSpeedLimit = speed
        }
    }
    
    private func showFloatingWindow() {
        guard floatingWindow == nil else { return }
        
        floatingWindow = FloatingInfoWindow()
        floatingWindow?.onClose = { [weak self] in
            self?.enableSwitch.isOn = false
            NetworkSimulator.shared.disable()
            self?.floatingWindow = nil
        }
        floatingWindow?.show(in: UIView())  // 传入空 view，实际不使用
        updateFloatingWindow()
    }
    
    private func hideFloatingWindow() {
        floatingWindow?.hide()
        floatingWindow = nil
    }
    
    private func updateFloatingWindow() {
        let simulator = NetworkSimulator.shared
        let mode = modes[modeSegment.selectedSegmentIndex]
        var text = "🌐 弱网\n\(modeNames[modeSegment.selectedSegmentIndex])"
        
        switch mode {
        case .delay:
            text += "\n延迟: \(Int(simulator.delaySeconds))秒"
        case .speedLimit:
            text += "\n请求: \(simulator.requestSpeedLimit)KB/s\n响应: \(simulator.responseSpeedLimit)KB/s"
        default:
            break
        }
        
        floatingWindow?.updateContent(text)
    }
}

// MARK: - UITextFieldDelegate
extension NetworkSimulatorViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateSimulatorConfig()
        if enableSwitch.isOn {
            updateFloatingWindow()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
