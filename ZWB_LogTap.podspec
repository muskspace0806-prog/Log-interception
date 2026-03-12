Pod::Spec.new do |s|
  s.name             = 'ZWB_LogTap'
  s.version          = '1.0.7'
  s.summary          = 'A powerful iOS network debugging tool for HTTP/HTTPS with manual WebSocket logging'
  s.description      = <<-DESC
ZWB_LogTap is a comprehensive iOS debugging tool that helps developers monitor and analyze network traffic in real-time.

Features:
- Intercept all URLSession and Alamofire HTTP/HTTPS requests automatically
- Manual WebSocket logging API (stable and crash-free)
- Beautiful floating button UI
- Detailed request/response inspection
- JSON auto-formatting
- Search and filter capabilities
- Export logs as JSON
- Zero configuration for HTTP, simple API for WebSocket
                       DESC

  s.homepage         = 'https://github.com/muskspace0806-prog/Log-interception'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ZWB' => 'muskspace0806@gmail.com' }
  s.source           = { :git => 'https://github.com/muskspace0806-prog/Log-interception.git', :tag => s.version.to_s }
  
  s.ios.deployment_target = '13.0'
  s.swift_version = '5.0'
  
  s.source_files = 'ZWB_LogTap/Classes/**/*'
  
  s.frameworks = 'UIKit', 'Foundation'
  
  # 只在 Debug 模式下使用
  s.pod_target_xcconfig = {
    'SWIFT_ACTIVE_COMPILATION_CONDITIONS' => 'DEBUG'
  }
end
