//
//  AppDelegate.swift
//  日志拦截工具
//
//  Created by hule on 2026/3/3.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // 启动网络拦截
        NetworkInterceptorManager.shared.startIntercepting()
        print("✅ 网络拦截已启动")
        
        // 启动 WebSocket 拦截
        WebSocketInterceptor.shared.startIntercepting()
        print("✅ WebSocket 拦截已启动")
        
        // 设置环境切换回调（示例）
        setupEnvironmentSwitchCallback()
        
        return true
    }
    
    // MARK: - Environment Switch
    
    private func setupEnvironmentSwitchCallback() {
        ZWBLogTap.shared.setEnvironmentSwitchCallback { newEnvironment in
            print("🌍 环境切换回调触发")
            
            switch newEnvironment {
            case .test:
                print("🔵 已切换到测试环境")
                // 在这里更新你的 API 基础 URL
                // APIManager.shared.baseURL = "https://test-api.example.com"
                
            case .production:
                print("🔴 已切换到正式环境")
                // 在这里更新你的 API 基础 URL
                // APIManager.shared.baseURL = "https://api.example.com"
                
            case .custom(let name):
                print("🟠 已切换到自定义环境: \(name)")
            }
            
            // 可以在这里执行其他操作：
            // - 重新初始化网络层
            // - 清空缓存
            // - 重新加载数据
            // - 显示提示信息
            
            self.showEnvironmentSwitchAlert(environment: newEnvironment)
        }
    }
    
    private func showEnvironmentSwitchAlert(environment: EnvironmentManager.Environment) {
        DispatchQueue.main.async {
            guard let window = UIApplication.shared.windows.first,
                  let rootVC = window.rootViewController else { return }
            
            let alert = UIAlertController(
                title: "环境已切换",
                message: "当前环境: \(environment.name)\n\n这是一个示例回调，你可以在这里执行自定义逻辑",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "确定", style: .default))
            
            var topVC = rootVC
            while let presented = topVC.presentedViewController {
                topVC = presented
            }
            topVC.present(alert, animated: true)
        }
    }
    
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
}
