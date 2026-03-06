//
//  NetworkSimulator.swift
//  ZWB_LogTap
//
//  网络模拟器 - 模拟弱网、断网、延迟等场景
//

import Foundation

public class NetworkSimulator {
    
    public static let shared = NetworkSimulator()
    
    // 模拟模式
    public enum SimulationMode {
        case none           // 正常模式
        case disconnect     // 断网
        case timeout        // 超时
        case speedLimit     // 限速
        case delay          // 延迟
    }
    
    // 当前模式
    public private(set) var currentMode: SimulationMode = .none
    
    // 配置参数
    public var isEnabled: Bool = false
    public var delaySeconds: TimeInterval = 10.0        // 延迟时间（秒）
    public var requestSpeedLimit: Int = 2000            // 请求速度限制（KB/s）
    public var responseSpeedLimit: Int = 2000           // 响应速度限制（KB/s）
    public var timeoutSeconds: TimeInterval = 30.0      // 超时时间（秒）
    
    private init() {}
    
    // MARK: - Public Methods
    
    /// 启用模拟器
    public func enable(mode: SimulationMode) {
        isEnabled = true
        currentMode = mode
        print("🌐 [NetworkSimulator] 已启用: \(modeDescription(mode))")
    }
    
    /// 禁用模拟器
    public func disable() {
        isEnabled = false
        currentMode = .none
        print("🌐 [NetworkSimulator] 已禁用")
    }
    
    /// 模拟请求处理
    public func simulateRequest(completion: @escaping (Error?) -> Void) {
        guard isEnabled else {
            completion(nil)
            return
        }
        
        switch currentMode {
        case .none:
            completion(nil)
            
        case .disconnect:
            // 模拟断网
            let error = NSError(domain: NSURLErrorDomain, 
                              code: NSURLErrorNotConnectedToInternet,
                              userInfo: [NSLocalizedDescriptionKey: "网络连接已断开"])
            completion(error)
            
        case .timeout:
            // 模拟超时
            DispatchQueue.global().asyncAfter(deadline: .now() + timeoutSeconds) {
                let error = NSError(domain: NSURLErrorDomain,
                                  code: NSURLErrorTimedOut,
                                  userInfo: [NSLocalizedDescriptionKey: "请求超时"])
                completion(error)
            }
            
        case .speedLimit:
            // 限速模式下正常返回，但在数据传输时会限速
            completion(nil)
            
        case .delay:
            // 模拟延迟
            DispatchQueue.global().asyncAfter(deadline: .now() + delaySeconds) {
                completion(nil)
            }
        }
    }
    
    /// 模拟数据传输延迟（用于限速）
    public func simulateDataTransfer(dataSize: Int, completion: @escaping () -> Void) {
        guard isEnabled, currentMode == .speedLimit else {
            completion()
            return
        }
        
        // 计算传输时间（数据大小 / 速度限制）
        let speedKBps = Double(responseSpeedLimit)
        let dataSizeKB = Double(dataSize) / 1024.0
        let transferTime = dataSizeKB / speedKBps
        
        DispatchQueue.global().asyncAfter(deadline: .now() + transferTime) {
            completion()
        }
    }
    
    // MARK: - Helper Methods
    
    private func modeDescription(_ mode: SimulationMode) -> String {
        switch mode {
        case .none: return "正常模式"
        case .disconnect: return "断网模式"
        case .timeout: return "超时模式"
        case .speedLimit: return "限速模式"
        case .delay: return "延迟模式"
        }
    }
    
    /// 获取当前配置描述
    public func getCurrentConfig() -> String {
        guard isEnabled else {
            return "未启用"
        }
        
        var config = "模式: \(modeDescription(currentMode))\n"
        
        switch currentMode {
        case .delay:
            config += "延迟时间: \(Int(delaySeconds))秒"
        case .speedLimit:
            config += "请求限速: \(requestSpeedLimit) KB/s\n"
            config += "响应限速: \(responseSpeedLimit) KB/s"
        case .timeout:
            config += "超时时间: \(Int(timeoutSeconds))秒"
        default:
            break
        }
        
        return config
    }
}
