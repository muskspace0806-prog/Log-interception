//
//  CrashLogViewController.swift
//  ZWB_LogTap
//
//  Crash 日志页面
//

import UIKit

class CrashLogViewController: UIViewController {
    
    private var tableView: UITableView!
    private var closeButton: UIButton!
    private var clearButton: UIButton!
    private var enableSwitch: UISwitch!
    private var crashLogs: [CrashMonitor.CrashLog] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadData()
        
        // 默认开启 Crash 监控
        if !CrashMonitor.shared.isEnabled {
            CrashMonitor.shared.enable()
            enableSwitch.isOn = true
        } else {
            enableSwitch.isOn = CrashMonitor.shared.isEnabled
        }
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
        titleLabel.text = "Crash"
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        toolBar.addSubview(titleLabel)
        
        // 清空按钮
        clearButton = UIButton(type: .system)
        clearButton.setTitle("清空", for: .normal)
        clearButton.titleLabel?.font = .systemFont(ofSize: 16)
        clearButton.addTarget(self, action: #selector(clearTapped), for: .touchUpInside)
        clearButton.translatesAutoresizingMaskIntoConstraints = false
        toolBar.addSubview(clearButton)
        
        // 开关容器
        let switchContainer = UIView()
        switchContainer.backgroundColor = .secondarySystemBackground
        switchContainer.layer.cornerRadius = 8
        switchContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(switchContainer)
        
        let switchLabel = UILabel()
        switchLabel.text = "Crash 日志收集开关"
        switchLabel.font = .systemFont(ofSize: 16)
        switchLabel.translatesAutoresizingMaskIntoConstraints = false
        switchContainer.addSubview(switchLabel)
        
        enableSwitch = UISwitch()
        enableSwitch.isOn = CrashMonitor.shared.isEnabled
        enableSwitch.addTarget(self, action: #selector(enableSwitchChanged), for: .valueChanged)
        enableSwitch.translatesAutoresizingMaskIntoConstraints = false
        switchContainer.addSubview(enableSwitch)
        
        // 表格
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
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
            
            clearButton.trailingAnchor.constraint(equalTo: toolBar.trailingAnchor, constant: -16),
            clearButton.centerYAnchor.constraint(equalTo: toolBar.centerYAnchor),
            
            switchContainer.topAnchor.constraint(equalTo: toolBar.bottomAnchor, constant: 12),
            switchContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            switchContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            switchContainer.heightAnchor.constraint(equalToConstant: 50),
            
            switchLabel.leadingAnchor.constraint(equalTo: switchContainer.leadingAnchor, constant: 16),
            switchLabel.centerYAnchor.constraint(equalTo: switchContainer.centerYAnchor),
            
            enableSwitch.trailingAnchor.constraint(equalTo: switchContainer.trailingAnchor, constant: -16),
            enableSwitch.centerYAnchor.constraint(equalTo: switchContainer.centerYAnchor),
            
            tableView.topAnchor.constraint(equalTo: switchContainer.bottomAnchor, constant: 12),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func loadData() {
        crashLogs = CrashMonitor.shared.getAllCrashLogs()
        tableView.reloadData()
    }
    
    @objc private func closeTapped() {
        dismiss(animated: true)
    }
    
    @objc private func clearTapped() {
        let alert = UIAlertController(title: "确认清空", message: "确定要清空所有 Crash 日志吗？", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "清空", style: .destructive) { _ in
            CrashMonitor.shared.clearAllLogs()
            self.loadData()
        })
        present(alert, animated: true)
    }
    
    @objc private func enableSwitchChanged() {
        if enableSwitch.isOn {
            CrashMonitor.shared.enable()
        } else {
            CrashMonitor.shared.disable()
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension CrashLogViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return crashLogs.isEmpty ? 1 : crashLogs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        if crashLogs.isEmpty {
            cell.textLabel?.text = "暂无 Crash 日志"
            cell.textLabel?.textColor = .secondaryLabel
            cell.accessoryType = .none
        } else {
            let log = crashLogs[indexPath.row]
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            cell.textLabel?.text = "\(formatter.string(from: log.timestamp)) - \(log.reason)"
            cell.textLabel?.textColor = .label
            cell.accessoryType = .disclosureIndicator
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard !crashLogs.isEmpty else { return }
        
        let log = crashLogs[indexPath.row]
        let detailVC = CrashLogDetailViewController()
        detailVC.crashLog = log
        present(detailVC, animated: true)
    }
}
