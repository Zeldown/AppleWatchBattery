# Batteries

Apple Watch complications styled like the iOS Batteries widget: watch, iPhone, AirPods and case.

- **Circular / corner / inline**: one device of your choice (Apple Watch, iPhone, AirPods, case).
- **Rectangular**: up to 4 rings, like the iPhone widget.

## How it works

| Source | Read with |
|---|---|
| Apple Watch | `WKInterfaceDevice`, on the watch |
| iPhone | `UIDevice`, in the iPhone app, sent through `WatchConnectivity` |
| AirPods and accessories | IOKit `IOPSCopyPowerSourcesByType` (private API loaded with `dlopen`), in the iPhone app |

iPhone values refresh every ~15 min at best: iOS decides when the app runs in the background. Opening the watch app forces an update.

The private API rules out the App Store and TestFlight: the app is installed as **Ad Hoc** (or development).

## Requirements

- Paid Apple Developer account.
- A GitHub repository (builds run on a GitHub Actions macOS runner).

## Setup (once)

1. **Devices**: on [developer.apple.com](https://developer.apple.com/account/resources/devices/list), register the iPhone UDID **and** the watch UDID.
2. **API key**: App Store Connect → Users and Access → Integrations → key with the **Admin** role. Note the Key ID and Issuer ID and download the `.p8`.
3. **Development certificate**, from Git Bash on Windows:
   ```sh
   openssl req -new -newkey rsa:2048 -nodes -keyout dev.key -out dev.csr -subj "/CN=Batteries"
   ```
   Upload `dev.csr` in Certificates → Apple Development, download `development.cer`, then:
   ```sh
   openssl x509 -inform der -in development.cer -out dev.pem
   openssl pkcs12 -export -legacy -inkey dev.key -in dev.pem -out dev.p12
   ```
4. **GitHub secrets** (Settings → Secrets and variables → Actions):

   | Name | Value |
   |---|---|
   | `APPLE_TEAM_ID` | Team ID (10 characters) |
   | `ASC_KEY_ID` | API key Key ID |
   | `ASC_ISSUER_ID` | Issuer ID |
   | `ASC_KEY_P8` | `base64 -w0 AuthKey_XXXX.p8` |
   | `DEV_CERT_P12` | `base64 -w0 dev.p12` |
   | `DEV_CERT_PASSWORD` | `.p12` password |

   Variable `BUNDLE_ID_PREFIX`: a prefix of your own, e.g. `com.yourname`.

## Build and install

1. Actions → **Build** → *Run workflow* (`release-testing` = Ad Hoc).
2. Download the `Batteries` artifact (`.ipa`).
3. Install the `.ipa` on the iPhone from Windows (Sideloadly without re-signing, or iMazing).
4. Watch app on the iPhone → Batteries → **Install**.
5. Open the app once on the iPhone and once on the watch, then add the complication by editing the watch face.

Every push also runs an unsigned compile to check the code.

## AirPods calibration

The iPhone app screen lists the **detected sources** with their raw keys: they are what identifies earbuds and case. If AirPods are misclassified, this information is what `PowerSourceReader` gets adjusted from.
