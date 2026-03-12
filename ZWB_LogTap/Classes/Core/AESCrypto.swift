//
//  AESCrypto.swift
//  ZWB_LogTap
//
//  AES 加密解密工具
//

import Foundation
import CommonCrypto

extension Data {
    
    /// AES-256-CBC 解密
    /// - Parameters:
    ///   - key: 解密密钥
    ///   - iv: 初始化向量
    /// - Returns: 解密后的数据，失败返回 nil
    func aes256Decrypt(key: Data, iv: Data) -> Data? {
        return aesCrypt(operation: CCOperation(kCCDecrypt), algorithm: CCAlgorithm(kCCAlgorithmAES), key: key, iv: iv)
    }
    
    /// AES-128-CBC 解密（兼容你的原有代码）
    /// - Parameters:
    ///   - key: 解密密钥
    ///   - iv: 初始化向量
    /// - Returns: 解密后的数据，失败返回 nil
    func aes128Decrypt(key: Data, iv: Data) -> Data? {
        return aesCrypt(operation: CCOperation(kCCDecrypt), algorithm: CCAlgorithm(kCCAlgorithmAES128), key: key, iv: iv)
    }
    
    /// AES-256-CBC 加密
    /// - Parameters:
    ///   - key: 加密密钥
    ///   - iv: 初始化向量
    /// - Returns: 加密后的数据，失败返回 nil
    func aes256Encrypt(key: Data, iv: Data) -> Data? {
        return aesCrypt(operation: CCOperation(kCCEncrypt), algorithm: CCAlgorithm(kCCAlgorithmAES), key: key, iv: iv)
    }
    
    /// AES 加密/解密核心方法
    private func aesCrypt(operation: CCOperation, algorithm: CCAlgorithm, key: Data, iv: Data) -> Data? {
        // 根据算法确定 key 大小
        let keySize: Int
        if algorithm == CCAlgorithm(kCCAlgorithmAES128) {
            keySize = kCCKeySizeAES128  // 16 字节
        } else {
            keySize = kCCKeySizeAES256  // 32 字节
        }
        
        // 确保 key 长度正确
        var keyData = key
        if keyData.count < keySize {
            // 如果 key 不足，用 0 填充
            keyData.append(Data(repeating: 0, count: keySize - keyData.count))
        } else if keyData.count > keySize {
            // 如果 key 超过，截取
            keyData = keyData.prefix(keySize)
        }
        
        // 确保 iv 长度为 16 字节
        var ivData = iv
        if ivData.count < kCCBlockSizeAES128 {
            ivData.append(Data(repeating: 0, count: kCCBlockSizeAES128 - ivData.count))
        } else if ivData.count > kCCBlockSizeAES128 {
            ivData = ivData.prefix(kCCBlockSizeAES128)
        }
        
        // 计算输出缓冲区大小
        let bufferSize = self.count + kCCBlockSizeAES128
        var buffer = Data(count: bufferSize)
        
        var numBytesEncrypted: size_t = 0
        
        let cryptStatus = buffer.withUnsafeMutableBytes { bufferBytes in
            self.withUnsafeBytes { dataBytes in
                keyData.withUnsafeBytes { keyBytes in
                    ivData.withUnsafeBytes { ivBytes in
                        CCCrypt(
                            operation,
                            algorithm,
                            CCOptions(kCCOptionPKCS7Padding),
                            keyBytes.baseAddress,
                            keySize,
                            ivBytes.baseAddress,
                            dataBytes.baseAddress,
                            self.count,
                            bufferBytes.baseAddress,
                            bufferSize,
                            &numBytesEncrypted
                        )
                    }
                }
            }
        }
        
        guard cryptStatus == kCCSuccess else {
            print("⚠️ [AESCrypto] 加密/解密失败，错误码: \(cryptStatus)")
            return nil
        }
        
        buffer.count = numBytesEncrypted
        return buffer
    }
}

extension NSData {
    
    /// 兼容旧的 Objective-C 风格 API（AES-128）
    @objc func jx_AES256Decrypt(withKey key: Data, iv: Data) -> NSData? {
        // 注意：虽然方法名是 AES256，但实际使用的是 AES128（与你的原有代码一致）
        guard let decrypted = (self as Data).aes128Decrypt(key: key, iv: iv) else {
            return nil
        }
        return decrypted as NSData
    }
}
