//
//  NetworkInterceptor.swift
//  日志拦截工具
//
//  网络拦截核心类 - 基于 URLProtocol 实现
//

import Foundation

class NetworkInterceptor: URLProtocol {
    
    private var session: URLSession?
    private var sessionTask: URLSessionDataTask?
    private var responseData: Data?
    
    // 拦截记录存储
    static var interceptedRequests: [InterceptedRequest] = []
    static var maxRecords = 1000 // 最大记录数
    
    // 判断是否需要拦截这个请求
    override class func canInit(with request: URLRequest) -> Bool {
        // 避免重复拦截
        if URLProtocol.property(forKey: "NetworkInterceptorHandled", in: request) != nil {
            return false
        }
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        guard let mutableRequest = (request as NSURLRequest).mutableCopy() as? NSMutableURLRequest else {
            return
        }
        
        // 标记已处理
        URLProtocol.setProperty(true, forKey: "NetworkInterceptorHandled", in: mutableRequest)
        
        let startTime = Date()
        
        // 获取请求 Body：优先使用 httpBody，否则尝试从 httpBodyStream 读取
        let bodyData = request.httpBody ?? Self.readBodyStream(from: request)
        
        // 记录请求信息
        let interceptedRequest = InterceptedRequest(
            id: UUID().uuidString,
            url: request.url?.absoluteString ?? "",
            method: request.httpMethod ?? "GET",
            headers: request.allHTTPHeaderFields ?? [:],
            body: bodyData,
            startTime: startTime
        )
        
        session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        sessionTask = session?.dataTask(with: mutableRequest as URLRequest)
        sessionTask?.resume()
        
        // 保存请求记录（限制最大数量）
        DispatchQueue.main.async {
            NetworkInterceptor.interceptedRequests.insert(interceptedRequest, at: 0)
            if NetworkInterceptor.interceptedRequests.count > NetworkInterceptor.maxRecords {
                NetworkInterceptor.interceptedRequests.removeLast()
            }
            NotificationCenter.default.post(name: .networkRequestIntercepted, object: nil)
        }
    }
    
    override func stopLoading() {
        sessionTask?.cancel()
        session?.invalidateAndCancel()
    }
    
    // MARK: - 从 httpBodyStream 读取 Body 数据
    // URLProtocol 中 httpBody 经常为 nil（iOS 系统会将 body 转为 stream），
    // 需要手动从 httpBodyStream 读取
    private static func readBodyStream(from request: URLRequest) -> Data? {
        guard let stream = request.httpBodyStream else { return nil }
        
        stream.open()
        defer { stream.close() }
        
        let bufferSize = 4096
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        defer { buffer.deallocate() }
        
        var data = Data()
        
        while stream.hasBytesAvailable {
            let bytesRead = stream.read(buffer, maxLength: bufferSize)
            if bytesRead > 0 {
                data.append(buffer, count: bytesRead)
            } else if bytesRead < 0 {
                // 读取错误
                return nil
            } else {
                break
            }
        }
        
        return data.isEmpty ? nil : data
    }
}

// MARK: - URLSessionDataDelegate
extension NetworkInterceptor: URLSessionDataDelegate {
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .allowed)
        completionHandler(.allow)
        
        // 记录响应信息
        if let httpResponse = response as? HTTPURLResponse,
           let url = response.url?.absoluteString {
            DispatchQueue.main.async {
                if let index = NetworkInterceptor.interceptedRequests.firstIndex(where: { $0.url == url && $0.statusCode == nil }) {
                    NetworkInterceptor.interceptedRequests[index].statusCode = httpResponse.statusCode
                    NetworkInterceptor.interceptedRequests[index].responseHeaders = httpResponse.allHeaderFields as? [String: String] ?? [:]
                }
            }
        }
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        client?.urlProtocol(self, didLoad: data)
        
        if responseData == nil {
            responseData = Data()
        }
        responseData?.append(data)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            client?.urlProtocol(self, didFailWithError: error)
            
            // 记录错误
            if let url = task.originalRequest?.url?.absoluteString {
                DispatchQueue.main.async {
                    if let index = NetworkInterceptor.interceptedRequests.firstIndex(where: { $0.url == url && $0.endTime == nil }) {
                        NetworkInterceptor.interceptedRequests[index].error = error.localizedDescription
                        NetworkInterceptor.interceptedRequests[index].endTime = Date()
                        NetworkInterceptor.interceptedRequests[index].responseData = self.responseData
                        NotificationCenter.default.post(name: .networkRequestIntercepted, object: nil)
                    }
                }
            }
        } else {
            client?.urlProtocolDidFinishLoading(self)
            
            // 请求完成时，保存完整的响应数据
            if let url = task.originalRequest?.url?.absoluteString {
                DispatchQueue.main.async {
                    if let index = NetworkInterceptor.interceptedRequests.firstIndex(where: { $0.url == url && $0.endTime == nil }) {
                        NetworkInterceptor.interceptedRequests[index].responseData = self.responseData
                        NetworkInterceptor.interceptedRequests[index].endTime = Date()
                        NotificationCenter.default.post(name: .networkRequestIntercepted, object: nil)
                    }
                }
            }
        }
    }
}

// MARK: - Notification
extension Notification.Name {
    static let networkRequestIntercepted = Notification.Name("networkRequestIntercepted")
}
