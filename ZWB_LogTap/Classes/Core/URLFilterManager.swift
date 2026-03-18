//
//  URLFilterManager.swift
//  ZWB_LogTap
//
//  URL 过滤管理器
//

import Foundation

public class URLFilterManager {
    
    public static let shared = URLFilterManager()
    
    private let userDefaultsKey = "ZWB_LogTap_FilteredURLs"
    private let defaultsInitializedKey = "ZWB_LogTap_FilterDefaults_Initialized"
    
    /// 默认过滤规则（首次安装时自动写入，用户可删除）
    private let builtinDefaults: [String] = [
        "/v1/heartbeat",
        "format/webp"
    ]
    
    /// 过滤的 URL 列表（包含默认 + 用户自定义）
    private(set) var filteredURLs: [String] = []
    
    private init() {
        loadFilteredURLs()
    }
    
    /// 添加过滤 URL
    public func addFilteredURL(_ url: String) {
        let trimmedURL = url.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedURL.isEmpty, !filteredURLs.contains(trimmedURL) else { return }
        filteredURLs.append(trimmedURL)
        saveFilteredURLs()
        print("✅ [URLFilter] 已添加过滤: \(trimmedURL)")
    }
    
    /// 移除过滤 URL
    public func removeFilteredURL(_ url: String) {
        if let index = filteredURLs.firstIndex(of: url) {
            filteredURLs.remove(at: index)
            saveFilteredURLs()
            print("✅ [URLFilter] 已移除过滤: \(url)")
        }
    }
    
    /// 清空所有过滤
    public func clearAllFilters() {
        filteredURLs.removeAll()
        saveFilteredURLs()
        print("✅ [URLFilter] 已清空所有过滤")
    }
    
    /// 检查 URL 是否应该被过滤
    public func shouldFilter(url: String) -> Bool {
        let lowercasedURL = url.lowercased()
        return filteredURLs.contains { lowercasedURL.contains($0.lowercased()) }
    }
    
    /// 保存到 UserDefaults
    private func saveFilteredURLs() {
        UserDefaults.standard.set(filteredURLs, forKey: userDefaultsKey)
        UserDefaults.standard.synchronize()
    }
    
    /// 从 UserDefaults 加载，首次安装时写入默认规则
    private func loadFilteredURLs() {
        let initialized = UserDefaults.standard.bool(forKey: defaultsInitializedKey)
        if !initialized {
            // 首次安装，写入默认规则
            filteredURLs = builtinDefaults
            saveFilteredURLs()
            UserDefaults.standard.set(true, forKey: defaultsInitializedKey)
            UserDefaults.standard.synchronize()
            print("✅ [URLFilter] 首次安装，已写入 \(builtinDefaults.count) 个默认过滤规则")
        } else if let urls = UserDefaults.standard.array(forKey: userDefaultsKey) as? [String] {
            filteredURLs = urls
            print("✅ [URLFilter] 已加载 \(urls.count) 个过滤规则")
        }
    }
}
