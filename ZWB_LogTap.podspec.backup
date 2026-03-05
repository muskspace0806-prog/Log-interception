Pod::Spec.new do |s|
  s.name             = 'ZWB_LogTap'
  s.version          = '1.0.2'
  s.summary          = 'A powerful iOS network debugging tool for HTTP and WebSocket'
  s.description      = <<-DESC
ZWB_LogTap is a comprehensive iOS debugging tool that helps developers monitor and analyze network traffic in real-time.

Features:
- Intercept all URLSession HTTP/HTTPS requests
- Monitor WebSocket connections and messages (SocketRocket support)
- Beautiful floating button UI
- Detailed request/response inspection
- JSON auto-formatting
- Search and filter capabilities
- Export logs as JSON
- Zero configuration required
                       DESC

  s.homepage         = 'https://github.com/yourusername/ZWB_LogTap'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ZWB' => 'your.email@example.com' }
  s.source           = { :git => 'https://github.com/yourusername/ZWB_LogTap.git', :tag => s.version.to_s }
  
  s.ios.deployment_target = '13.0'
  s.swift_version = '5.0'
  
  s.source_files = 'ZWB_LogTap/Classes/**/*'
  
  s.frameworks = 'UIKit', 'Foundation'
  
  # 只在 Debug 模式下使用
  s.pod_target_xcconfig = {
    'SWIFT_ACTIVE_COMPILATION_CONDITIONS' => 'DEBUG'
  }
end
