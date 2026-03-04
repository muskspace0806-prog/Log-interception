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
        // 创建测试网络请求按钮
        let testButton = UIButton(type: .system)
        testButton.setTitle("测试网络请求", for: .normal)
        testButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        testButton.backgroundColor = .systemBlue
        testButton.setTitleColor(.white, for: .normal)
        testButton.layer.cornerRadius = 12
        testButton.addTarget(self, action: #selector(testNetworkRequest), for: .touchUpInside)
        testButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(testButton)
        
        // 创建测试 IM 请求按钮
        let testIMButton = UIButton(type: .system)
        testIMButton.setTitle("测试IM请求", for: .normal)
        testIMButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        testIMButton.backgroundColor = .systemOrange
        testIMButton.setTitleColor(.white, for: .normal)
        testIMButton.layer.cornerRadius = 12
        testIMButton.addTarget(self, action: #selector(testIMRequest), for: .touchUpInside)
        testIMButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(testIMButton)
        
        // 说明标签
        let infoLabel = UILabel()
        infoLabel.text = "点击右下角悬浮按钮\n查看网络日志和IM消息"
        infoLabel.numberOfLines = 0
        infoLabel.textAlignment = .center
        infoLabel.font = .systemFont(ofSize: 16)
        infoLabel.textColor = .secondaryLabel
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(infoLabel)
        
        NSLayoutConstraint.activate([
            testButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            testButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            testButton.widthAnchor.constraint(equalToConstant: 200),
            testButton.heightAnchor.constraint(equalToConstant: 50),
            
            testIMButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            testIMButton.topAnchor.constraint(equalTo: testButton.bottomAnchor, constant: 20),
            testIMButton.widthAnchor.constraint(equalToConstant: 200),
            testIMButton.heightAnchor.constraint(equalToConstant: 50),
            
            infoLabel.topAnchor.constraint(equalTo: testIMButton.bottomAnchor, constant: 30),
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
    
    @objc private func testIMRequest() {
        // 模拟 WebSocket 消息（因为没有真实的 SocketRocket 连接）
        // 这里直接调用拦截器的日志方法来演示功能
        
        let testURL = "wss://echo.websocket.org"
        
        // 模拟连接
        WebSocketInterceptor.logConnection(url: testURL)
        
        // 模拟发送消息
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let sendMessage = """
            {
                "type": "message",
                "content": "你好，这是一条测试消息",
                "timestamp": \(Date().timeIntervalSince1970)
            }
            """
            WebSocketInterceptor.logSend(url: testURL, data: sendMessage)
        }
        
        // 模拟接收消息
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let receiveMessage = """
            {
                "type": "response",
                "content": "消息已收到",
                "status": "success",
                "timestamp": \(Date().timeIntervalSince1970)
            }
            """
            WebSocketInterceptor.logReceive(url: testURL, data: receiveMessage)
        }
        
        // 模拟再发送一条消息
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let sendMessage2 = """
            {
                "type": "ping",
                "timestamp": \(Date().timeIntervalSince1970)
            }
            """
            WebSocketInterceptor.logSend(url: testURL, data: sendMessage2)
        }
        
        // 模拟接收 pong
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            let receiveMessage2 = """
            {
                "type": "pong",
                "timestamp": \(Date().timeIntervalSince1970)
            }
            """
            WebSocketInterceptor.logReceive(url: testURL, data: receiveMessage2)
        }
        
        // 显示提示
        let alert = UIAlertController(title: "测试IM请求", message: "已模拟发送 WebSocket 消息\n请点击悬浮按钮查看 IM 日志", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
}
