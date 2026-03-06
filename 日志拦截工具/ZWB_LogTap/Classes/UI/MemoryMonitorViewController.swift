//
//  MemoryMonitorViewController.swift
//  ZWB_LogTap
//
//  内存监控页面
//

import UIKit

class MemoryMonitorViewController: UIViewController {
    
    private var closeButton: UIButton!
    private var enableSwitch: UISwitch!
    private var currentMemoryLabel: UILabel!
    private var memoryChartView: UIView!
    private var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        startUpdating()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopUpdating()
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
        titleLabel.text = "内存检测"
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        toolBar.addSubview(titleLabel)
        
        // 开关容器
        let switchContainer = UIView()
        switchContainer.backgroundColor = .secondarySystemBackground
        switchContainer.layer.cornerRadius = 8
        switchContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(switchContainer)
        
        let switchLabel = UILabel()
        switchLabel.text = "内存检测开关"
        switchLabel.font = .systemFont(ofSize: 16)
        switchLabel.translatesAutoresizingMaskIntoConstraints = false
        switchContainer.addSubview(switchLabel)
        
        enableSwitch = UISwitch()
        enableSwitch.isOn = MemoryMonitor.shared.isEnabled
        enableSwitch.addTarget(self, action: #selector(enableSwitchChanged), for: .valueChanged)
        enableSwitch.translatesAutoresizingMaskIntoConstraints = false
        switchContainer.addSubview(enableSwitch)
        
        // 当前内存显示
        currentMemoryLabel = UILabel()
        currentMemoryLabel.text = "当前内存: -- MB"
        currentMemoryLabel.font = .systemFont(ofSize: 24, weight: .bold)
        currentMemoryLabel.textAlignment = .center
        currentMemoryLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(currentMemoryLabel)
        
        // 内存图表区域（简化版，显示一个进度条）
        memoryChartView = UIView()
        memoryChartView.backgroundColor = .secondarySystemBackground
        memoryChartView.layer.cornerRadius = 8
        memoryChartView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(memoryChartView)
        
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
            
            switchContainer.topAnchor.constraint(equalTo: toolBar.bottomAnchor, constant: 20),
            switchContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            switchContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            switchContainer.heightAnchor.constraint(equalToConstant: 50),
            
            switchLabel.leadingAnchor.constraint(equalTo: switchContainer.leadingAnchor, constant: 16),
            switchLabel.centerYAnchor.constraint(equalTo: switchContainer.centerYAnchor),
            
            enableSwitch.trailingAnchor.constraint(equalTo: switchContainer.trailingAnchor, constant: -16),
            enableSwitch.centerYAnchor.constraint(equalTo: switchContainer.centerYAnchor),
            
            currentMemoryLabel.topAnchor.constraint(equalTo: switchContainer.bottomAnchor, constant: 40),
            currentMemoryLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            currentMemoryLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            memoryChartView.topAnchor.constraint(equalTo: currentMemoryLabel.bottomAnchor, constant: 20),
            memoryChartView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            memoryChartView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            memoryChartView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    private func startUpdating() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateMemoryDisplay()
        }
    }
    
    private func stopUpdating() {
        timer?.invalidate()
        timer = nil
    }
    
    private func updateMemoryDisplay() {
        guard let snapshot = MemoryMonitor.shared.getCurrentMemoryUsage() else { return }
        
        currentMemoryLabel.text = String(format: "当前内存: %.1f MB", snapshot.usedMemoryMB)
        
        // 更新图表（简化版：显示文字信息）
        memoryChartView.subviews.forEach { $0.removeFromSuperview() }
        
        let infoLabel = UILabel()
        infoLabel.numberOfLines = 0
        infoLabel.text = String(format: "使用: %.1f MB\n总计: %.1f MB\n占用: %.1f%%", 
                               snapshot.usedMemoryMB, 
                               snapshot.totalMemoryMB, 
                               snapshot.usagePercentage)
        infoLabel.font = .systemFont(ofSize: 16)
        infoLabel.textAlignment = .center
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        memoryChartView.addSubview(infoLabel)
        
        NSLayoutConstraint.activate([
            infoLabel.centerXAnchor.constraint(equalTo: memoryChartView.centerXAnchor),
            infoLabel.centerYAnchor.constraint(equalTo: memoryChartView.centerYAnchor)
        ])
    }
    
    @objc private func closeTapped() {
        dismiss(animated: true)
    }
    
    @objc private func enableSwitchChanged() {
        if enableSwitch.isOn {
            MemoryMonitor.shared.enable()
            MemoryMonitor.shared.showFloatingWindow()
        } else {
            MemoryMonitor.shared.disable()
        }
    }
}
