//
//  EnvironmentManager.swift
//  ZWB_LogTap
//
//  环境管理器 - 管理测试/正式环境切换
//

import UIKit

public class EnvironmentManager {
    
    public static let shared = EnvironmentManager()
    
    /// 环境类型
    public enum Environment: Equatable {
        case test           // 测试环境
        case production     // 正式环境
        case custom(String) // 自定义环境
        
        public var name: String {
            switch self {
            case .test:
                return "测试环境"
            case .production:
                return "正式环境"
            case .custom(let name):
                return name
            }
        }
        
        public var buttonColor: UIColor {
            switch self {
            case .test:
                return .systemBlue
            case .production:
                return .systemRed
            case .custom:
                return .systemOrange
            }
        }
        
        public var switchButtonTitle: String {
            switch self {
            case .test:
                return "切换到正式环境"
            case .production:
                return "切换到测试环境"
            case .custom:
                return "切换环境"
            }
        }
        
        public var targetEnvironment: Environment {
            switch self {
            case .test:
                return .production
            case .production:
                return .test
            case .custom:
                return .test
            }
        }
    }
    
    /// 当前环境
    public private(set) var currentEnvironment: Environment = .test
    
    /// 环境切换回调
    public var onEnvironmentSwitch: ((Environment) -> Void)?
    
    private init() {}
    
    /// 设置当前环境
    public func setEnvironment(_ environment: Environment) {
        currentEnvironment = environment
        print("🌍 [EnvironmentManager] 当前环境: \(environment.name)")
    }
    
    /// 切换环境
    public func switchEnvironment() {
        let newEnvironment = currentEnvironment.targetEnvironment
        currentEnvironment = newEnvironment
        
        print("🌍 [EnvironmentManager] 切换到: \(newEnvironment.name)")
        
        // 触发回调
        onEnvironmentSwitch?(newEnvironment)
    }
    
    /// 切换到指定环境
    public func switchTo(_ environment: Environment) {
        currentEnvironment = environment
        
        print("🌍 [EnvironmentManager] 切换到: \(environment.name)")
        
        // 触发回调
        onEnvironmentSwitch?(environment)
    }
}
