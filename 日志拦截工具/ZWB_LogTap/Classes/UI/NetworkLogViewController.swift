//
//  NetworkLogViewController.swift
//  日志拦截工具
//
//  网络日志列表页面
//

import UIKit

class NetworkLogViewController: UIViewController {
    
    private var tableView: UITableView!
    private var searchBar: UISearchBar!
    private var typeSegment: UISegmentedControl!  // HTTP/IM 切换
    private var filterSegment: UISegmentedControl!
    private var closeButton: UIButton!
    private var toolsButton: UIButton!
    private var filterButton: UIButton!  // URL 过滤按钮
    private var clearButton: UIButton!
    private var exportButton: UIButton!
    
    private var currentType: LogType = .http
    private static let lastTabKey = "ZWBLogTap_LastTabType"
    private static let lastSearchKey = "ZWBLogTap_LastSearchKeyword"
    private var requests: [InterceptedRequest] = []
    private var filteredRequests: [InterceptedRequest] = []
    private var wsMessages: [WebSocketMessage] = []
    private var filteredWSMessages: [WebSocketMessage] = []
    private var searchKeyword: String = ""
    private var selectedFilter: String = "全部"
    
    enum LogType {
        case http
        case websocket
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        // 恢复上次选择的 tab
        let savedIndex = UserDefaults.standard.integer(forKey: Self.lastTabKey)
        if savedIndex == 1 {
            currentType = .websocket
            typeSegment.selectedSegmentIndex = 1
            typeChanged()
        }
        // 恢复上次搜索关键词
        if let savedKeyword = UserDefaults.standard.string(forKey: Self.lastSearchKey), !savedKeyword.isEmpty {
            searchKeyword = savedKeyword
            searchBar.text = savedKeyword
        }
        loadData()
        setupNotification()
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
        titleLabel.text = "网络日志"
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        toolBar.addSubview(titleLabel)
        
        // 工具按钮
        toolsButton = UIButton(type: .system)
        toolsButton.setTitle("工具", for: .normal)
        toolsButton.titleLabel?.font = .systemFont(ofSize: 16)
        toolsButton.addTarget(self, action: #selector(toolsTapped), for: .touchUpInside)
        toolsButton.translatesAutoresizingMaskIntoConstraints = false
        toolBar.addSubview(toolsButton)
        
        // 切换环境按钮（原过滤按钮位置）
        filterButton = UIButton(type: .system)
        filterButton.setTitle("切换", for: .normal)
        filterButton.titleLabel?.font = .systemFont(ofSize: 16)
        filterButton.addTarget(self, action: #selector(switchEnvTapped), for: .touchUpInside)
        filterButton.translatesAutoresizingMaskIntoConstraints = false
        toolBar.addSubview(filterButton)
        
        // 清空按钮
        clearButton = UIButton(type: .system)
        clearButton.setTitle("清空", for: .normal)
        clearButton.titleLabel?.font = .systemFont(ofSize: 16)
        clearButton.addTarget(self, action: #selector(clearTapped), for: .touchUpInside)
        clearButton.translatesAutoresizingMaskIntoConstraints = false
        toolBar.addSubview(clearButton)
        
        // 导出按钮
        exportButton = UIButton(type: .system)
        exportButton.setTitle("导出", for: .normal)
        exportButton.titleLabel?.font = .systemFont(ofSize: 16)
        exportButton.addTarget(self, action: #selector(exportTapped), for: .touchUpInside)
        exportButton.translatesAutoresizingMaskIntoConstraints = false
        toolBar.addSubview(exportButton)
        
        // 搜索框
        searchBar = UISearchBar()
        searchBar.placeholder = "搜索 URL、请求、响应..."
        searchBar.delegate = self
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchBar)
        
        // HTTP/IM 切换
        typeSegment = UISegmentedControl(items: ["HTTP", "IM"])
        typeSegment.selectedSegmentIndex = 0
        typeSegment.addTarget(self, action: #selector(typeChanged), for: .valueChanged)
        typeSegment.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(typeSegment)
        
        // 过滤器
        filterSegment = UISegmentedControl(items: ["全部", "GET", "POST", "成功", "失败"])
        filterSegment.selectedSegmentIndex = 0
        filterSegment.addTarget(self, action: #selector(filterChanged), for: .valueChanged)
        filterSegment.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(filterSegment)
        
        // 表格
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(NetworkLogCell.self, forCellReuseIdentifier: "NetworkLogCell")
        tableView.register(WebSocketMessageCell.self, forCellReuseIdentifier: "WebSocketMessageCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        tableView.separatorStyle = .singleLine
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
            
            filterButton.leadingAnchor.constraint(equalTo: closeButton.trailingAnchor, constant: 12),
            filterButton.centerYAnchor.constraint(equalTo: toolBar.centerYAnchor),
            
            titleLabel.centerXAnchor.constraint(equalTo: toolBar.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: toolBar.centerYAnchor),
            
            exportButton.trailingAnchor.constraint(equalTo: toolBar.trailingAnchor, constant: -16),
            exportButton.centerYAnchor.constraint(equalTo: toolBar.centerYAnchor),
            
            clearButton.trailingAnchor.constraint(equalTo: exportButton.leadingAnchor, constant: -12),
            clearButton.centerYAnchor.constraint(equalTo: toolBar.centerYAnchor),
            
            toolsButton.trailingAnchor.constraint(equalTo: clearButton.leadingAnchor, constant: -12),
            toolsButton.centerYAnchor.constraint(equalTo: toolBar.centerYAnchor),
            
            searchBar.topAnchor.constraint(equalTo: toolBar.bottomAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            typeSegment.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 8),
            typeSegment.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            typeSegment.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            filterSegment.topAnchor.constraint(equalTo: typeSegment.bottomAnchor, constant: 8),
            filterSegment.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            filterSegment.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            tableView.topAnchor.constraint(equalTo: filterSegment.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private var refreshTimer: Timer?
    
    private func setupNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(requestsUpdated), name: .networkRequestIntercepted, object: nil)
        
        // 使用定时器定期刷新 WebSocket 消息，避免通知崩溃
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            guard let self = self, self.currentType == .websocket else { return }
            self.loadData()
        }
    }
    
    deinit {
        refreshTimer?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func requestsUpdated() {
        loadData()
    }
    
    @objc private func wsMessagesUpdated() {
        // 不再使用，保留以兼容
    }
    
    private func loadData() {
        requests = NetworkInterceptorManager.shared.getAllRequests()
        wsMessages = WebSocketInterceptor.interceptedMessages
        applyFilters()
    }
    
    private func applyFilters() {
        if currentType == .http {
            applyHTTPFilters()
        } else {
            applyWSFilters()
        }
        tableView.reloadData()
    }
    
    private func applyHTTPFilters() {
        filteredRequests = requests
        
        // 应用 URL 过滤（优先级最高）
        filteredRequests = filteredRequests.filter { !URLFilterManager.shared.shouldFilter(url: $0.url) }
        
        // 应用搜索
        if !searchKeyword.isEmpty {
            filteredRequests = filteredRequests.filter { $0.url.lowercased().contains(searchKeyword.lowercased()) }
        }
        
        // 应用过滤器
        switch selectedFilter {
        case "GET":
            filteredRequests = filteredRequests.filter { $0.method == "GET" }
        case "POST":
            filteredRequests = filteredRequests.filter { $0.method == "POST" }
        case "成功":
            filteredRequests = filteredRequests.filter { ($0.statusCode ?? 0) >= 200 && ($0.statusCode ?? 0) < 300 }
        case "失败":
            filteredRequests = filteredRequests.filter { ($0.statusCode ?? 0) >= 400 || $0.error != nil }
        default:
            break
        }
    }
    
    private func applyWSFilters() {
        filteredWSMessages = wsMessages
        
        // 应用 URL 过滤（优先级最高）
        filteredWSMessages = filteredWSMessages.filter { !URLFilterManager.shared.shouldFilter(url: $0.url) }
        
        // 过滤掉 route 在过滤列表中的消息（如 heartbeat）
        filteredWSMessages = filteredWSMessages.filter { msg in
            guard let route = msg.route else { return true }
            return !URLFilterManager.shared.shouldFilter(url: route)
        }
        
        // 应用搜索
        if !searchKeyword.isEmpty {
            filteredWSMessages = filteredWSMessages.filter {
                $0.url.lowercased().contains(searchKeyword.lowercased()) ||
                $0.dataString.lowercased().contains(searchKeyword.lowercased())
            }
        }
        
        // 应用过滤器
        switch selectedFilter {
        case "连接":
            filteredWSMessages = filteredWSMessages.filter { $0.type == .connect }
        case "发送":
            filteredWSMessages = filteredWSMessages.filter { $0.type == .send }
        case "接收":
            filteredWSMessages = filteredWSMessages.filter { $0.type == .receive }
        case "错误":
            filteredWSMessages = filteredWSMessages.filter { $0.type == .error }
        default:
            break
        }
    }
    
    @objc private func closeTapped() {
        dismiss(animated: true) {
            // 清除 ZWBLogTap 中的引用
            ZWBLogTap.shared.clearCurrentViewController()
        }
    }
    
    @objc private func toolsTapped() {
        let toolsVC = DebugToolsViewController()
        present(toolsVC, animated: true)
    }
    
    @objc private func switchEnvTapped() {
        let currentEnv = EnvironmentManager.shared.currentEnvironment
        let targetEnv = currentEnv.targetEnvironment
        let alert = UIAlertController(
            title: "环境切换",
            message: "当前环境: \(currentEnv.name)\n\n确定要切换到 \(targetEnv.name) 吗？",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "切换", style: .default) { _ in
            ZWBLogTap.shared.switchEnvironment()
            let success = UIAlertController(title: "切换成功", message: "已切换到 \(targetEnv.name)", preferredStyle: .alert)
            success.addAction(UIAlertAction(title: "确定", style: .default))
            self.present(success, animated: true)
        })
        present(alert, animated: true)
    }
    
    @objc private func filterTapped() {
        let filterVC = URLFilterViewController()
        present(filterVC, animated: true)
    }
    
    @objc private func clearTapped() {
        let message = currentType == .http ? "确定要清空所有 HTTP 日志记录吗？" : "确定要清空所有 IM 消息记录吗？"
        let alert = UIAlertController(title: "确认清空", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "清空", style: .destructive) { _ in
            if self.currentType == .http {
                NetworkInterceptorManager.shared.clearAllRequests()
            } else {
                WebSocketInterceptor.clearAllMessages()
            }
            self.loadData()
        })
        present(alert, animated: true)
    }
    
    @objc private func typeChanged() {
        currentType = typeSegment.selectedSegmentIndex == 0 ? .http : .websocket
        // 持久化 tab 选择
        UserDefaults.standard.set(typeSegment.selectedSegmentIndex, forKey: Self.lastTabKey)
        
        // 更新过滤器选项
        if currentType == .http {
            filterSegment.removeAllSegments()
            filterSegment.insertSegment(withTitle: "全部", at: 0, animated: false)
            filterSegment.insertSegment(withTitle: "GET", at: 1, animated: false)
            filterSegment.insertSegment(withTitle: "POST", at: 2, animated: false)
            filterSegment.insertSegment(withTitle: "成功", at: 3, animated: false)
            filterSegment.insertSegment(withTitle: "失败", at: 4, animated: false)
        } else {
            filterSegment.removeAllSegments()
            filterSegment.insertSegment(withTitle: "全部", at: 0, animated: false)
            filterSegment.insertSegment(withTitle: "连接", at: 1, animated: false)
            filterSegment.insertSegment(withTitle: "发送", at: 2, animated: false)
            filterSegment.insertSegment(withTitle: "接收", at: 3, animated: false)
            filterSegment.insertSegment(withTitle: "错误", at: 4, animated: false)
        }
        filterSegment.selectedSegmentIndex = 0
        selectedFilter = "全部"
        
        applyFilters()
    }
    
    @objc private func exportTapped() {
        guard let jsonString = NetworkInterceptorManager.shared.exportToJSON() else {
            showAlert(message: "导出失败")
            return
        }
        
        let activityVC = UIActivityViewController(activityItems: [jsonString], applicationActivities: nil)
        present(activityVC, animated: true)
    }
    
    @objc private func filterChanged() {
        selectedFilter = filterSegment.titleForSegment(at: filterSegment.selectedSegmentIndex) ?? "全部"
        applyFilters()
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
    

}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension NetworkLogViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentType == .http ? filteredRequests.count : filteredWSMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if currentType == .http {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NetworkLogCell", for: indexPath) as! NetworkLogCell
            cell.configure(with: filteredRequests[indexPath.row])
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "WebSocketMessageCell", for: indexPath) as! WebSocketMessageCell
            cell.configure(with: filteredWSMessages[indexPath.row])
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if currentType == .http {
            let detailVC = NetworkLogDetailViewController()
            detailVC.request = filteredRequests[indexPath.row]
            present(detailVC, animated: true)
        } else {
            let detailVC = WebSocketMessageDetailViewController()
            detailVC.message = filteredWSMessages[indexPath.row]
            present(detailVC, animated: true)
        }
    }
}

// MARK: - UISearchBarDelegate
extension NetworkLogViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchKeyword = searchText
        UserDefaults.standard.set(searchText, forKey: Self.lastSearchKey)
        applyFilters()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
