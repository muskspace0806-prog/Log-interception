//
//  SceneDelegate.swift
//  日志拦截工具
//
//  Created by hule on 2026/3/3.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var floatingButton: FloatingButton?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        // 延迟显示悬浮按钮（等待视图层级建立）
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.setupFloatingButton()
        }
    }
    
    private func setupFloatingButton() {
        guard let window = window else { return }
        
        // 创建悬浮按钮
        floatingButton = FloatingButton()
        
        // 移除点击隐藏功能 - 只保留长按显示日志
        floatingButton?.onTap = nil
        
        // 长按事件 - 显示日志页面
        floatingButton?.onLongPress = { [weak self] in
            self?.showNetworkLog()
        }
        
        // 显示按钮
        floatingButton?.show(in: window)
    }
    
    private func showNetworkLog() {
        guard let rootVC = window?.rootViewController else { return }
        
        let logVC = NetworkLogViewController()
        logVC.modalPresentationStyle = .fullScreen
        
        // 找到最顶层的 ViewController
        var topVC = rootVC
        while let presented = topVC.presentedViewController {
            topVC = presented
        }
        
        topVC.present(logVC, animated: true) { [weak self] in
            // 显示日志页面后，重新显示悬浮按钮
            if let button = self?.floatingButton, button.superview == nil {
                self?.setupFloatingButton()
            }
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
    }

    func sceneWillResignActive(_ scene: UIScene) {
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
    }
}
