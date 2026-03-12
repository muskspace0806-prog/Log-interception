//
//  URLFilterViewController.swift
//  ZWB_LogTap
//
//  URL 过滤设置页面
//

import UIKit

class URLFilterViewController: UIViewController {
    
    private var tableView: UITableView!
    private var addButton: UIButton!
    private var closeButton: UIButton!
    
    private var filteredURLs: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadData()
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
        titleLabel.text = "URL 过滤"
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        toolBar.addSubview(titleLabel)
        
        // 添加按钮
        addButton = UIButton(type: .system)
        addButton.setTitle("添加", for: .normal)
        addButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        addButton.addTarget(self, action: #selector(addTapped), for: .touchUpInside)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        toolBar.addSubview(addButton)
        
        // 说明文字
        let descLabel = UILabel()
        descLabel.text = "添加要过滤的 URL（支持模糊匹配）"
        descLabel.font = .systemFont(ofSize: 14)
        descLabel.textColor = .secondaryLabel
        descLabel.textAlignment = .center
        descLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(descLabel)
        
        // 表格
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
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
            
            addButton.trailingAnchor.constraint(equalTo: toolBar.trailingAnchor, constant: -16),
            addButton.centerYAnchor.constraint(equalTo: toolBar.centerYAnchor),
            
            descLabel.topAnchor.constraint(equalTo: toolBar.bottomAnchor, constant: 8),
            descLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            descLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            tableView.topAnchor.constraint(equalTo: descLabel.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func loadData() {
        filteredURLs = URLFilterManager.shared.filteredURLs
        tableView.reloadData()
    }
    
    @objc private func closeTapped() {
        dismiss(animated: true)
    }
    
    @objc private func addTapped() {
        let alert = UIAlertController(title: "添加过滤 URL", message: "输入要过滤的 URL（部分或全部）", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "例如: api.example.com"
            textField.autocapitalizationType = .none
            textField.autocorrectionType = .no
        }
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "添加", style: .default) { [weak self] _ in
            guard let url = alert.textFields?.first?.text, !url.isEmpty else {
                return
            }
            
            URLFilterManager.shared.addFilteredURL(url)
            self?.loadData()
        })
        
        present(alert, animated: true)
    }
    
    private func removeURL(at index: Int) {
        let url = filteredURLs[index]
        
        let alert = UIAlertController(title: "确认移除", message: "确定要移除过滤规则：\n\(url)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "移除", style: .destructive) { [weak self] _ in
            URLFilterManager.shared.removeFilteredURL(url)
            self?.loadData()
        })
        
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension URLFilterViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if filteredURLs.isEmpty {
            // 显示空状态
            let emptyLabel = UILabel()
            emptyLabel.text = "暂无过滤规则\n点击右上角【添加】按钮添加"
            emptyLabel.textColor = .secondaryLabel
            emptyLabel.textAlignment = .center
            emptyLabel.numberOfLines = 0
            tableView.backgroundView = emptyLabel
        } else {
            tableView.backgroundView = nil
        }
        
        return filteredURLs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let url = filteredURLs[indexPath.row]
        cell.textLabel?.text = url
        cell.textLabel?.numberOfLines = 0
        
        // 添加删除按钮
        let deleteButton = UIButton(type: .system)
        deleteButton.setTitle("✕", for: .normal)
        deleteButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .medium)
        deleteButton.setTitleColor(.systemRed, for: .normal)
        deleteButton.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        deleteButton.tag = indexPath.row
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped(_:)), for: .touchUpInside)
        
        cell.accessoryView = deleteButton
        
        return cell
    }
    
    @objc private func deleteButtonTapped(_ sender: UIButton) {
        removeURL(at: sender.tag)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
