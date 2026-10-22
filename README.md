# Batteries

Apple Watch complications styled like the iOS Batteries widget: watch, iPhone, AirPods and their case, right on the watch face.

## Complications

| Family | Content |
|---|---|
| Circular | One device: ring, icon and level |
| Corner | One device: curved gauge |
| Inline | One device: icon and level |
| Rectangular | Up to 4 rings, like the iPhone widget |

The ring turns yellow in Low Power Mode, red at 20 % and below, and opens on a bolt while charging.

## How it works

| Source | Read with |
|---|---|
| Apple Watch | `WKInterfaceDevice`, on the watch |
| iPhone | `UIDevice`, in the companion iPhone app |
| AirPods and accessories | IOKit power sources, in the companion iPhone app |

The iPhone app sends its readings to the watch through `WatchConnectivity`; the watch app and its widget extension share them through an App Group.

AirPods levels come from a private IOKit API, so the app cannot ship on the App Store and is meant for personal installation.

## Building

The Xcode project is generated with [XcodeGen](https://github.com/yonaskolb/XcodeGen):

```sh
BUNDLE_ID_PREFIX=com.example DEVELOPMENT_TEAM=XXXXXXXXXX xcodegen generate
```

Requires iOS 17 and watchOS 10.
