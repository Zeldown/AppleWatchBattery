import Combine
import UIKit
import WatchConnectivity

public final class PhoneBatteryMonitor: NSObject, ObservableObject, WCSessionDelegate {
	public static let shared = PhoneBatteryMonitor()

	@Published public private(set) var devices: [BatteryDevice] = []
	@Published public private(set) var sources: [String] = []

	private var transferred: [BatteryDevice] = []

	private override init() {
		super.init()
	}

	public func activate() {
		UIDevice.current.isBatteryMonitoringEnabled = true
		for name in [UIDevice.batteryLevelDidChangeNotification, UIDevice.batteryStateDidChangeNotification, Notification.Name.NSProcessInfoPowerStateDidChange] {
			NotificationCenter.default.addObserver(forName: name, object: nil, queue: OperationQueue.main) { _ in
				self.push()
			}
		}
		if WCSession.isSupported() {
			WCSession.default.delegate = self
			WCSession.default.activate()
		}
		self.push()
	}

	public func push() {
		let snapshot = self.read()
		DispatchQueue.main.async {
			self.devices = snapshot.devices
			self.sources = PowerSourceReader.descriptions().map { description in
				return description.keys.sorted().map { "\($0) = \(description[$0] ?? "")" }.joined(separator: "\n")
			}
		}
		let session = WCSession.default
		guard WCSession.isSupported(), session.activationState == .activated, session.isPaired, session.isWatchAppInstalled, let data = snapshot.encode() else {
			return
		}
		try? session.updateApplicationContext(["snapshot": data])
		if session.isComplicationEnabled, session.remainingComplicationUserInfoTransfers > 0, snapshot.devices != self.transferred {
			self.transferred = snapshot.devices
			session.transferCurrentComplicationUserInfo(["snapshot": data])
		}
	}

	public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
		self.push()
	}

	public func session(_ session: WCSession, didReceiveMessage message: [String: Any], replyHandler: @escaping ([String: Any]) -> Void) {
		replyHandler(["snapshot": self.read().encode() ?? Data()])
	}

	public func sessionDidBecomeInactive(_ session: WCSession) {
	}

	public func sessionDidDeactivate(_ session: WCSession) {
		session.activate()
	}

	private func read() -> BatterySnapshot {
		let device = UIDevice.current
		let phone = BatteryDevice(id: "iphone", kind: .iPhone, name: device.name, symbol: BatteryKind.iPhone.symbol, level: max(0, Double(device.batteryLevel)), isCharging: device.batteryState == .charging || device.batteryState == .full, isLowPowerMode: ProcessInfo.processInfo.isLowPowerModeEnabled)
		return BatterySnapshot(devices: [phone] + PowerSourceReader.accessories(), date: Date())
	}
}