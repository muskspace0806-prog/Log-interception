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
    
    /// 过滤的 URL 列表
    private(set) var filteredURLs: [String] = []
    
    private init() {
        loadFilteredURLs()
    }
    
    /// 添加过滤 URL
    public func addFilteredURL(_ url: String) {
        let trimmedURL = url.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedURL.isEmpty, !filteredURLs.contains(trimmedURL) else {
            return
        }
        
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
        for filteredURL in filteredURLs {
            if url.lowercased().contains(filteredURL.lowercased()) {
                return true
            }
        }
        return false
    }
    
    /// 保存到 UserDefaults
    private func saveFilteredURLs() {
        UserDefaults.standard.set(filteredURLs, forKey: userDefaultsKey)
        UserDefaults.standard.synchronize()
    }
    
    /// 从 UserDefaults 加载
    private func loadFilteredURLs() {
        if let urls = UserDefaults.standard.array(forKey: userDefaultsKey) as? [String] {
            filteredURLs = urls
            print("✅ [URLFilter] 已加载 \(urls.count) 个过滤规则")
        }
    }
}
