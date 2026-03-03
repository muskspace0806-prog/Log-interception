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
    private var filterSegment: UISegmentedControl!
    private var closeButton: UIButton!
    private var clearButton: UIButton!
    private var exportButton: UIButton!
    
    private var requests: [InterceptedRequest] = []
    private var filteredRequests: [InterceptedRequest] = []
    private var searchKeyword: String = ""
    private var selectedFilter: String = "全部"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
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
        titleLabel.text = "HTTP日志"
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
            
            titleLabel.centerXAnchor.constraint(equalTo: toolBar.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: toolBar.centerYAnchor),
            
            exportButton.trailingAnchor.constraint(equalTo: toolBar.trailingAnchor, constant: -16),
            exportButton.centerYAnchor.constraint(equalTo: toolBar.centerYAnchor),
            
            clearButton.trailingAnchor.constraint(equalTo: exportButton.leadingAnchor, constant: -12),
            clearButton.centerYAnchor.constraint(equalTo: toolBar.centerYAnchor),
            
            searchBar.topAnchor.constraint(equalTo: toolBar.bottomAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            filterSegment.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 8),
            filterSegment.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            filterSegment.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            tableView.topAnchor.constraint(equalTo: filterSegment.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(requestsUpdated), name: .networkRequestIntercepted, object: nil)
    }
    
    @objc private func requestsUpdated() {
        loadData()
    }
    
    private func loadData() {
        requests = NetworkInterceptorManager.shared.getAllRequests()
        applyFilters()
    }
    
    private func applyFilters() {
        filteredRequests = requests
        
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
        
        tableView.reloadData()
    }
    
    @objc private func closeTapped() {
        dismiss(animated: true)
    }
    
    @objc private func clearTapped() {
        let alert = UIAlertController(title: "确认清空", message: "确定要清空所有日志记录吗？", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "清空", style: .destructive) { _ in
            NetworkInterceptorManager.shared.clearAllRequests()
            self.loadData()
        })
        present(alert, animated: true)
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
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension NetworkLogViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredRequests.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NetworkLogCell", for: indexPath) as! NetworkLogCell
        cell.configure(with: filteredRequests[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let detailVC = NetworkLogDetailViewController()
        detailVC.request = filteredRequests[indexPath.row]
        present(detailVC, animated: true)
    }
}

// MARK: - UISearchBarDelegate
extension NetworkLogViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchKeyword = searchText
        applyFilters()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
