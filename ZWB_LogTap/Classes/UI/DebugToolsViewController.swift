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
            ToolItem(title: "模拟弱网", icon: "🌐", subtitle: "断网、限速、延迟等"),
            ToolItem(title: "Crash 日志", icon: "💥", subtitle: "查看应用崩溃记录"),
            ToolItem(title: "内存监控", icon: "💾", subtitle: "实时监控内存使用")
        ]),
        Section(title: "日志管理", items: [
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
        
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = sections[indexPath.section].items[indexPath.row]
        
        switch item.title {
        case "环境切换":
            showEnvironmentSwitchAlert()
        case "模拟弱网":
            let vc = NetworkSimulatorViewController()
            present(vc, animated: true)
        case "Crash 日志":
            let vc = CrashLogViewController()
            present(vc, animated: true)
        case "内存监控":
            let vc = MemoryMonitorViewController()
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
