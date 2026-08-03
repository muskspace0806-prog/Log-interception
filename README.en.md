<h3 align="left">
  <a href="./README.md">中文</a> | <strong>English</strong>
</h3>

# ZWB_LogTap

[![Version](https://img.shields.io/badge/version-1.3.11-blue.svg)](https://github.com/muskspace0806-prog/Log-interception)
[![Platform](https://img.shields.io/badge/platform-iOS%2013.0%2B-lightgrey.svg)](https://github.com/muskspace0806-prog/Log-interception)
[![Swift](https://img.shields.io/badge/Swift-5.0-orange.svg)](https://swift.org)
[![ObjC](https://img.shields.io/badge/Objective--C-compatible-blue.svg)](https://github.com/muskspace0806-prog/Log-interception)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![CocoaPods](https://img.shields.io/badge/pod-1.3.11-blue.svg)](https://cocoapods.org/pods/ZWB_LogTap)

A powerful iOS network debugging tool for real-time HTTP/HTTPS inspection, environment switching, response decryption, IM message replay, weak-network simulation, crash logs, memory monitoring, and floating debug access.

## Features

- HTTP/HTTPS request interception for `URLSession`.
- Alamofire request interception.
- Environment switching between test and production, with different floating button colors.
- AES-128-CBC response decryption with per-environment configuration.
- URL filters for hiding noisy requests.
- IM message replay into your business message handler.
- Room stress testing from captured IM samples, with QPS/duration controls, normal/random replay modes, real-time performance metrics, and report export.
- Weak-network simulation including offline, throttling, and delay.
- Crash log capture and memory monitoring.
- Real-time performance floating window for FPS, CPU(App), memory, network requests, traffic, UI JANK, main-thread STALL, battery, and thermal state.
- Latest-first performance records with copy, clear, and asynchronous txt sharing.
- Failed request highlighting.
- JSON formatting, search, filtering, export, copy, and share.
- Draggable floating button with automatic recovery after host window changes.
- Debug-only integration with one-line startup.

> WebSocket interception is currently disabled due to technical limitations. Use specialized WebSocket tools when needed.

## Installation

### CocoaPods

```ruby
pod 'ZWB_LogTap', '~> 1.3.11', :configurations => ['Debug']
```

### Swift Package Manager

In Xcode, go to **File → Add Package Dependencies**, then enter:

```
https://github.com/muskspace0806-prog/Log-interception.git
```

Or add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/muskspace0806-prog/Log-interception.git", from: "1.3.11")
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

After launch, a floating debug button appears in the bottom-right corner and automatically reattaches if the host app rebuilds or switches its active window.

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
pod 'ZWB_LogTap', '~> 1.3.11', :configurations => ['Debug']
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

> Note: the first parameter of `logWebSocketReceiveWithUrl:message:` must be a URL string. Do not pass an `SRWebSocket` object there. For SocketRocket room stress replay, use `logWebSocketReceiveWithWebSocket:delegate:message:` in the delegate callback.

### Room Stress Testing

Room stress testing shows an independent floating `Stress` entry. It collects IM samples from recorded received WebSocket messages, replays selected samples at the configured QPS and duration, supports normal and randomized replay modes, records real-time performance samples, and exports a compact report. By default, ZWB_LogTap detects the current room from the `enterWithOpenChatRoom` IM `roomId`, including structures such as `res_data.data.room_info.roomId`.

For SocketRocket projects, prefer the Swift receive logging overload with an explicit delegate inside `webSocket(_:didReceiveMessage:)`. It records the message and registers the real business delegate, so room stress replay can call the original `SRWebSocketDelegate.webSocket(_:didReceiveMessage:)` path reliably. The older `logWebSocketReceive(webSocket:message:)` overload remains available and still tries to read SocketRocket's internal delegate as a fallback. Replay-generated receive logs are skipped automatically to avoid polluting the sample list.

For Objective-C SocketRocket projects, use `logWebSocketReceiveWithWebSocket:delegate:message:` instead of passing the socket object to `logWebSocketReceiveWithUrl:message:`.

If your business receive path decrypts the raw socket message first, use the display/replay split API: pass decrypted JSON as the display message for readable samples, and pass the original `message` as the replay message to avoid double-decryption during stress replay.

```swift
func webSocket(_ webSocket: SRWebSocket, didReceiveMessage message: Any) {
    ZWBLogTap.logWebSocketReceive(webSocket: webSocket, delegate: self, message: message)
    // Keep your existing business parsing logic unchanged.
}
```

```swift
// Enable / disable the room stress floating entry.
ZWBLogTap.shared.setRoomStressToolEnabled(true)
ZWBLogTap.shared.setRoomStressToolEnabled(false)
```

If your project uses a different IM structure, or room switching does not go through `enterWithOpenChatRoom`, pass the room id manually as a fallback. `String`, `Int`, and `NSNumber` are supported. Passing `nil`, an empty string, or `0` clears the context.

```swift
// After entering or switching rooms.
ZWBLogTap.shared.updateRoomStressContext(roomId: roomId)

// When leaving the room.
ZWBLogTap.shared.updateRoomStressContext(roomId: nil)
```

Objective-C projects can use:

```objc
// Enable / disable the room stress floating entry.
[ZWBLogTapOC setRoomStressToolEnabled:YES];
[ZWBLogTapOC setRoomStressToolEnabled:NO];

// After entering or switching rooms.
[ZWBLogTapOC updateRoomStressContextWithRoomId:@"123456"];
[ZWBLogTapOC updateRoomStressContextWithRoomIdNumber:@123456];

// When leaving the room.
[ZWBLogTapOC clearRoomStressContext];
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
    NSDictionary *dict = [self decryptFromData:message];

    // Recommended: display decrypted JSON, replay the original socket message.
    [ZWBLogTapOC logWebSocketReceiveWithWebSocket:webSocket
                                         delegate:self
                                   displayMessage:[dict yy_modelToJSONString]
                                    replayMessage:message];
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

## Changelog

### [1.3.11] - 2026-08-03

#### Added
- Added explicit WebSocket delegate receive logging APIs to make room stress replay more reliable across different SocketRocket projects.

### [1.3.10] - 2026-08-03

#### Added
- Added display/replay split WebSocket receive APIs so samples can show decrypted JSON while room stress replay uses the original socket message.

### [1.3.9] - 2026-07-31

#### Added
- Added OC room stress bridge APIs for enabling the entry, reading the current room id, updating string/number room ids, and clearing the context.

### [1.3.8] - 2026-07-31

#### Added
- Added OC bridge APIs `logWebSocketReceiveWithWebSocket:message:` and `logWebSocketReceiveDataWithWebSocket:data:`.

#### Fixed
- Fixed the README OC example to avoid passing `SRWebSocket` to `logWebSocketReceiveWithUrl:message:`, which can crash with `-[SRWebSocket length]`.

### [1.3.7] - 2026-07-31

#### Added
- Added `logWebSocketReceive(webSocket:message:)` so SocketRocket projects can register the real WebSocket instance by replacing only the receive logging line.

#### Improved
- Room stress testing now prefers replaying through the real `SRWebSocketDelegate.webSocket(_:didReceiveMessage:)` path, reducing project-specific adapter code.
- Receive logs generated by room stress replay are skipped automatically to avoid polluting captured IM samples.

### [1.3.6] - 2026-07-31

#### Added
- Added room stress testing from captured IM samples, with QPS and duration controls for normal/random mock receive replay.
- Added an independent `Stress` floating entry that can show or hide the room stress panel from the host app.
- Added `updateRoomStressContext(roomId:)` as a business-side fallback API for `String`, `Int`, and `NSNumber` room ids.
- Room stress reports now include configuration, selected samples, injection counts, and real-time performance summaries.

#### Improved
- Room stress testing detects the current room from the `enterWithOpenChatRoom` IM `roomId` by default, including `res_data.data.room_info.roomId`.
- New IM records notify the room stress panel to reload automatically, so room switching does not require reopening the panel.
- IM sample cells show `first/second`, gift name, gift id, gift count, gift type, whole-mic flag, and combo count.

### [1.3.5] - 2026-07-23

#### Added
- Added a real-time performance floating window for FPS, CPU(App), memory, network requests, traffic, UI JANK, main-thread STALL, battery, and thermal state.
- Added a green `PERF` floating entry. Enabling performance recording shows the panel by default, and the entry toggles panel visibility.
- Added a performance detail log view with latest-first records, copy, clear, and txt sharing.
- STALL events can include the blocked main-thread stack to help locate business-side UI freezes.

#### Improved
- Performance txt export is generated on a background queue before presenting the system share sheet.
- ZWB_LogTap internal UI actions such as open, close, copy, share, and clear are suppressed from JANK/STALL counting where possible.

### [1.3.4] - 2026-07-22

#### Fixed
- Fixed floating debug entry disappearing in some host apps after the home page or key window changes.
- Added automatic recovery for the main debug floating button and the IM mock-receive floating entry.
- Kept HTTP interception starting immediately, so startup requests are still captured without delaying SDK initialization.

## Notes

Use this tool only in Debug builds. It is designed for development and QA workflows, not production monitoring.
