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
    public enum Environment: Hashable {
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
    
    private static let persistenceKey = "ZWBLogTap_CurrentEnvironment"
    
    /// 当前环境（自动从 UserDefaults 恢复）
    public private(set) var currentEnvironment: Environment = {
        let raw = UserDefaults.standard.string(forKey: EnvironmentManager.persistenceKey) ?? "test"
        return EnvironmentManager.environmentFromRaw(raw)
    }()
    
    /// 环境切换回调
    public var onEnvironmentSwitch: ((Environment) -> Void)?
    
    /// 响应数据解密配置（按环境存储）
    private var decryptionConfigs: [Environment: ZWBLogTap.ResponseDecryptionConfig] = [:]
    
    private init() {}
    
    private static func environmentFromRaw(_ raw: String) -> Environment {
        switch raw {
        case "production": return .production
        case "test":       return .test
        default:
            if raw.hasPrefix("custom:") {
                return .custom(String(raw.dropFirst(7)))
            }
            return .test
        }
    }
    
    private static func rawFromEnvironment(_ env: Environment) -> String {
        switch env {
        case .test:              return "test"
        case .production:        return "production"
        case .custom(let name):  return "custom:\(name)"
        }
    }
    
    private func persist(_ environment: Environment) {
        UserDefaults.standard.set(Self.rawFromEnvironment(environment), forKey: Self.persistenceKey)
        UserDefaults.standard.synchronize()
    }
    
    /// 是否已有持久化的环境记录
    public var hasPersisted: Bool {
        return UserDefaults.standard.object(forKey: Self.persistenceKey) != nil
    }
    
    /// 设置当前环境（不持久化，仅用于首次默认值）
    public func setEnvironment(_ environment: Environment) {
        currentEnvironment = environment
        persist(environment)
        print("🌍 [EnvironmentManager] 当前环境: \(environment.name)")
    }
    
    /// 切换环境（持久化）
    public func switchEnvironment() {
        let newEnvironment = currentEnvironment.targetEnvironment
        currentEnvironment = newEnvironment
        persist(newEnvironment)
        print("🌍 [EnvironmentManager] 切换到: \(newEnvironment.name)")
        onEnvironmentSwitch?(newEnvironment)
    }
    
    /// 切换到指定环境（持久化）
    public func switchTo(_ environment: Environment) {
        currentEnvironment = environment
        persist(environment)
        print("🌍 [EnvironmentManager] 切换到: \(environment.name)")
        onEnvironmentSwitch?(environment)
    }
    
    /// 设置解密配置（支持多环境）
    public func setDecryptionConfigs(_ configs: [Environment: ZWBLogTap.ResponseDecryptionConfig]) {
        decryptionConfigs = configs
        for (env, _) in configs {
            print("🔐 [EnvironmentManager] 已为 \(env.name) 配置响应数据解密")
        }
    }
    
    /// 为指定环境设置解密配置
    public func setDecryptionConfig(for environment: Environment, config: ZWBLogTap.ResponseDecryptionConfig?) {
        if let config = config {
            decryptionConfigs[environment] = config
            print("🔐 [EnvironmentManager] 已为 \(environment.name) 配置响应数据解密")
        } else {
            decryptionConfigs.removeValue(forKey: environment)
            print("🔓 [EnvironmentManager] 已移除 \(environment.name) 的解密配置")
        }
    }
    
    /// 获取当前环境的解密配置
    public func getCurrentDecryptionConfig() -> ZWBLogTap.ResponseDecryptionConfig? {
        return decryptionConfigs[currentEnvironment]
    }
    
    /// 解密响应数据
    /// - Parameter data: 原始响应数据
    /// - Returns: 解密后的数据，如果不需要解密或解密失败则返回原数据
    public func decryptResponseData(_ data: Data) -> Data {
        // 获取当前环境的解密配置
        guard let config = decryptionConfigs[currentEnvironment], config.enabled else {
            // 如果当前环境没有配置解密，直接返回原数据
            return data
        }
        
        // 尝试解析 JSON
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: String],
              let encryptedString = json[config.encryptedFieldName] else {
            // 如果不是加密格式，返回原数据
            return data
        }
        
        print("🔐 [EnvironmentManager] 检测到加密数据，字段名: \(config.encryptedFieldName)")
        
        // Base64 解码
        guard let encryptedData = Data(base64Encoded: encryptedString) else {
            print("⚠️ [EnvironmentManager] Base64 解码失败，返回原数据")
            return data
        }
        
        print("🔐 [EnvironmentManager] Base64 解码成功，加密数据大小: \(encryptedData.count) 字节")
        
        // AES 解密
        guard let keyData = config.aesKey.data(using: .utf8),
              let ivData = config.aesIV.data(using: .utf8) else {
            print("⚠️ [EnvironmentManager] Key/IV 转换失败，返回原数据")
            return data
        }
        
        print("🔐 [EnvironmentManager] Key 长度: \(keyData.count), IV 长度: \(ivData.count)")
        
        guard let decryptedData = aesDecrypt(data: encryptedData, key: keyData, iv: ivData) else {
            print("⚠️ [EnvironmentManager] AES 解密失败，返回原数据")
            return data
        }
        
        print("🔐 [EnvironmentManager] AES 解密完成，解密数据大小: \(decryptedData.count) 字节")
        
        // 验证解密后的数据是否为有效的 JSON 或 UTF-8
        // 先尝试解析为 JSON
        if let _ = try? JSONSerialization.jsonObject(with: decryptedData) {
            print("✅ [EnvironmentManager] 解密成功，数据为有效的 JSON")
            return decryptedData
        }
        
        // 再尝试验证是否为有效的 UTF-8
        if let utf8String = String(data: decryptedData, encoding: .utf8), !utf8String.isEmpty {
            print("✅ [EnvironmentManager] 解密成功，数据为有效的 UTF-8 文本")
            return decryptedData
        }
        
        // 如果都不是，说明解密失败（Key/IV 可能错误）
        print("❌ [EnvironmentManager] 解密后的数据既不是 JSON 也不是有效的 UTF-8")
        print("❌ [EnvironmentManager] 可能原因：")
        print("   1. AES Key 不正确")
        print("   2. AES IV 不正确")
        print("   3. 加密算法不匹配（当前使用 AES-256-CBC）")
        print("   4. 数据本身已损坏")
        print("⚠️ [EnvironmentManager] 返回原始加密数据")
        
        return data
    }
    
    /// AES-128-CBC 解密（与你的原有代码一致）
    private func aesDecrypt(data: Data, key: Data, iv: Data) -> Data? {
        // 使用 AES-128（与你的 jx_AES256Decrypt 方法一致）
        return data.aes128Decrypt(key: key, iv: iv)
    }
}
