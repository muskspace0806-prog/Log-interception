<h3 align="left">
  <a href="./README.md">中文</a> | <strong>English</strong>
</h3>

# ZWB_LogTap

[![Version](https://img.shields.io/badge/version-1.3.3-blue.svg)](https://github.com/muskspace0806-prog/Log-interception)
[![Platform](https://img.shields.io/badge/platform-iOS%2013.0%2B-lightgrey.svg)](https://github.com/muskspace0806-prog/Log-interception)
[![Swift](https://img.shields.io/badge/Swift-5.0-orange.svg)](https://swift.org)
[![ObjC](https://img.shields.io/badge/Objective--C-compatible-blue.svg)](https://github.com/muskspace0806-prog/Log-interception)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![CocoaPods](https://img.shields.io/badge/pod-1.3.3-blue.svg)](https://cocoapods.org/pods/ZWB_LogTap)

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
pod 'ZWB_LogTap', '~> 1.3.3', :configurations => ['Debug']
```

### Swift Package Manager

In Xcode, go to **File → Add Package Dependencies**, then enter:

```
https://github.com/muskspace0806-prog/Log-interception.git
```

Or add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/muskspace0806-prog/Log-interception.git", from: "1.3.3")
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

## 🔷 Objective-C Full Support

Since **v1.3.3**, ZWB_LogTap fully supports Objective-C projects through the `ZWBLogTapOC` bridge class.

> **Prerequisites**: Your OC project must support Swift interop (enabled by default in Xcode).

### Installation (Podfile)

```ruby
pod 'ZWB_LogTap', '~> 1.3.3', :configurations => ['Debug']
```

### Basic Usage

In `AppDelegate.m`:

```objc
#import "AppDelegate.h"
@import ZWB_LogTap;   // or #import <ZWB_LogTap/ZWB_LogTap-Swift.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    // Option 1: One-line start (Debug only, recommended)
    [ZWBLogTapOC startIfDebug];

    // Option 2: Manual start
    #ifdef DEBUG
    [ZWBLogTapOC start];
    #endif

    return YES;
}

@end
```

### Custom Configuration

```objc
#ifdef DEBUG
ZWBConfiguration *config = [[ZWBConfiguration alloc] init];
config.showFloatingButton   = YES;
config.interceptHTTP        = YES;
config.maxRecords           = 1000;
config.floatingButtonPosition = ZWBFloatingButtonPositionBottomRight;
config.defaultEnvironment   = ZWBEnvironmentTypeTest;

[ZWBLogTapOC startWith:config];
#endif
```

### Environment Switching + Decryption

```objc
#ifdef DEBUG
// Test environment decryption
ZWBDecryptionConfig *testDecrypt = [[ZWBDecryptionConfig alloc]
    initWithAesKey:@"test_aes_key_16b"
             aesIV:@"test_aes_iv__16b"];

// Production environment decryption
ZWBDecryptionConfig *prodDecrypt = [[ZWBDecryptionConfig alloc]
    initWithAesKey:@"prod_aes_key_16b"
             aesIV:@"prod_aes_iv__16b"
 encryptedFieldName:@"ed"
            enabled:YES];

ZWBConfiguration *config = [[ZWBConfiguration alloc] init];
config.defaultEnvironment       = ZWBEnvironmentTypeTest;
config.testDecryptionConfig     = testDecrypt;
config.productionDecryptionConfig = prodDecrypt;

[ZWBLogTapOC startWith:config];
#endif
```

### Environment Switch Callback

```objc
[ZWBLogTapOC setEnvironmentSwitchCallback:^(NSString *environmentName) {
    NSLog(@"Switched to: %@", environmentName);

    if ([environmentName isEqualToString:@"测试环境"]) {
        [APIManager shared].baseURL = @"https://test-api.example.com";
    } else {
        [APIManager shared].baseURL = @"https://api.example.com";
    }
}];

// Switch to production
[ZWBLogTapOC switchToEnvironment:ZWBEnvironmentTypeProduction customName:@""];

// Toggle between test/production
[ZWBLogTapOC switchEnvironment];

// Query current environment
NSString *envName = [ZWBLogTapOC currentEnvironmentName];
```

### WebSocket Manual Logging

```objc
// Connect
[ZWBLogTapOC logWebSocketConnectWithUrl:@"wss://example.com/ws"];

// Send (text)
[ZWBLogTapOC logWebSocketSendWithUrl:@"wss://example.com/ws"
                              message:@"{\"action\":\"ping\"}"];

// Send (binary)
[ZWBLogTapOC logWebSocketSendDataWithUrl:@"wss://example.com/ws"
                                    data:binaryData];

// Receive (text)
[ZWBLogTapOC logWebSocketReceiveWithUrl:@"wss://example.com/ws"
                                 message:receivedText];

// Receive (binary)
[ZWBLogTapOC logWebSocketReceiveDataWithUrl:@"wss://example.com/ws"
                                       data:receivedData];

// Disconnect
[ZWBLogTapOC logWebSocketDisconnectWithUrl:@"wss://example.com/ws"
                                    reason:@"Normal close"];

// Error
[ZWBLogTapOC logWebSocketErrorWithUrl:@"wss://example.com/ws"
                                error:@"Connection timeout"];
```

### SocketRocket Integration (OC)

```objc
#import <SocketRocket/SRWebSocket.h>
@import ZWB_LogTap;

@interface MyWebSocketManager () <SRWebSocketDelegate>
@property (nonatomic, strong) SRWebSocket *socket;
@end

@implementation MyWebSocketManager

- (void)connect {
    NSURL *url = [NSURL URLWithString:@"wss://example.com/ws"];
    self.socket = [[SRWebSocket alloc] initWithURL:url];
    self.socket.delegate = self;
    [self.socket open];

    [ZWBLogTapOC logWebSocketConnectWithUrl:url.absoluteString];
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
    // Log receive (just one line)
    [ZWBLogTapOC logWebSocketReceiveWithUrl:webSocket.url.absoluteString
                                    message:[message description]];
    // Your business logic...
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    [ZWBLogTapOC logWebSocketErrorWithUrl:webSocket.url.absoluteString
                                    error:error.localizedDescription];
}

- (void)webSocket:(SRWebSocket *)webSocket
    didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    [ZWBLogTapOC logWebSocketDisconnectWithUrl:webSocket.url.absoluteString
                                        reason:reason ?: @""];
}

@end
```

### Other Common APIs

```objc
// Show log panel
[ZWBLogTapOC showLogViewController];

// Clear all logs
[ZWBLogTapOC clearAllLogs];

// Export logs as JSON
NSString *json = [ZWBLogTapOC exportLogsAsJSON];

// Stop
[ZWBLogTapOC stop];

// Check if running
BOOL running = [ZWBLogTapOC isEnabled];
```

### OC Type Reference

| Swift Type | OC Type | Description |
|---|---|---|
| `ZWBLogTap.Configuration` | `ZWBConfiguration` | Startup config |
| `ZWBLogTap.ResponseDecryptionConfig` | `ZWBDecryptionConfig` | AES decryption config |
| `ZWBLogTap.FloatingButtonPosition` | `ZWBFloatingButtonPosition` | Floating button position enum |
| `EnvironmentManager.Environment` | `ZWBEnvironmentType` | Environment enum |
| `ZWBLogTap.shared.start(...)` | `[ZWBLogTapOC startWith:]` | Start entry point |

---

## Notes

Use this tool only in Debug builds. It is designed for development and QA workflows, not production monitoring.
