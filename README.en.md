<h3 align="left">
  <a href="./README.md">中文</a> | <strong>English</strong>
</h3>

# ZWB_LogTap

[![Version](https://img.shields.io/badge/version-1.2.9-blue.svg)](https://github.com/muskspace0806-prog/Log-interception)
[![Platform](https://img.shields.io/badge/platform-iOS%2013.0%2B-lightgrey.svg)](https://github.com/muskspace0806-prog/Log-interception)
[![Swift](https://img.shields.io/badge/Swift-5.0-orange.svg)](https://swift.org)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![CocoaPods](https://img.shields.io/badge/pod-1.2.9-blue.svg)](https://cocoapods.org/pods/ZWB_LogTap)

A powerful iOS network debugging tool for real-time HTTP/HTTPS inspection, environment switching, response decryption, IM message replay, weak-network simulation, crash logs, memory monitoring, and floating debug access.

## Features

- HTTP/HTTPS request interception for `URLSession`.
- Alamofire request interception.
- Environment switching between test and production, with different floating button colors.
- AES-128-CBC response decryption with per-environment configuration.
- URL filters for hiding noisy requests.
- IM message replay into your business message handler.
- Weak-network simulation including offline, throttling, and delay.
- Crash log capture and memory monitoring.
- Failed request highlighting.
- JSON formatting, search, filtering, export, copy, and share.
- Draggable floating button.
- Debug-only integration with one-line startup.

> WebSocket interception is currently disabled due to technical limitations. Use specialized WebSocket tools when needed.

## Installation

### CocoaPods

```ruby
pod 'ZWB_LogTap', '~> 1.2.9', :configurations => ['Debug']
```

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/muskspace0806-prog/Log-interception.git", from: "1.2.0")
]
```

### Manual

Drag the `ZWB_LogTap/Classes` folder into your project.

## Quick Start

```swift
import ZWB_LogTap

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    ZWBLogTap.startIfDebug()
    return true
}
```

After launch, a floating debug button appears in the bottom-right corner.

## Configuration

```swift
var config = ZWBLogTap.Configuration()
config.showFloatingButton = true
config.interceptHTTP = true
config.maxRecords = 1000
config.defaultEnvironment = .test

ZWBLogTap.shared.start(with: config)
```

## Environment Switching And Decryption

```swift
let testConfig = ZWBLogTap.ResponseDecryptionConfig(
    aesKey: "test_aes_key_16b",
    aesIV: "test_aes_iv__16b",
    encryptedFieldName: "ed",
    enabled: true
)

ZWBLogTap.start(
    defaultEnvironment: .test,
    decryptionConfigs: [.test: testConfig]
)
```

## Preview

Screenshots are stored in the `Screenshots` folder and demonstrate the HTTP list, detail pages, IM replay, weak-network tools, memory monitor, and crash logs.

## Notes

Use this tool only in Debug builds. It is designed for development and QA workflows, not production monitoring.
