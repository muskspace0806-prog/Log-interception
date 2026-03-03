//
//  ViewController.swift
//  日志拦截工具
//
//  Created by hule on 2026/3/3.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setupTestUI()
    }
    
    private func setupTestUI() {
        // 创建测试按钮
        let testButton = UIButton(type: .system)
        testButton.setTitle("测试网络请求", for: .normal)
        testButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        testButton.backgroundColor = .systemBlue
        testButton.setTitleColor(.white, for: .normal)
        testButton.layer.cornerRadius = 12
        testButton.addTarget(self, action: #selector(testNetworkRequest), for: .touchUpInside)
        testButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(testButton)
        
        // 说明标签
        let infoLabel = UILabel()
        infoLabel.text = "长按右下角悬浮按钮\n查看网络日志"
        infoLabel.numberOfLines = 0
        infoLabel.textAlignment = .center
        infoLabel.font = .systemFont(ofSize: 16)
        infoLabel.textColor = .secondaryLabel
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(infoLabel)
        
        NSLayoutConstraint.activate([
            testButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            testButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            testButton.widthAnchor.constraint(equalToConstant: 200),
            testButton.heightAnchor.constraint(equalToConstant: 50),
            
            infoLabel.topAnchor.constraint(equalTo: testButton.bottomAnchor, constant: 30),
            infoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    @objc private func testNetworkRequest() {
        // 测试 GET 请求
        testGETRequest()
        
        // 测试 POST 请求
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.testPOSTRequest()
        }
    }
    
    private func testGETRequest() {
        guard let url = URL(string: "https://api.github.com/users/apple") else { return }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("GET 请求失败: \(error)")
                return
            }
            
            if let data = data, let json = try? JSONSerialization.jsonObject(with: data) {
                print("GET 请求成功: \(json)")
            }
        }
        task.resume()
    }
    
    private func testPOSTRequest() {
        guard let url = URL(string: "https://httpbin.org/post") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "name": "测试用户",
            "message": "这是一个测试请求",
            "timestamp": Date().timeIntervalSince1970
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("POST 请求失败: \(error)")
                return
            }
            
            if let data = data, let json = try? JSONSerialization.jsonObject(with: data) {
                print("POST 请求成功: \(json)")
            }
        }
        task.resume()
    }
}
