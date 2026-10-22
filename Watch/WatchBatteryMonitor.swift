import Combine
import WatchConnectivity
import WatchKit
import WidgetKit

public final class WatchBatteryMonitor: NSObject, ObservableObject, WCSessionDelegate {
	public static let shared = WatchBatteryMonitor()

	@Published public private(set) var devices: [BatteryDevice] = BatteryStore.devices()
	@Published public private(set) var date: Date? = BatteryStore.load()?.date

	private var tasks: [WKWatchConnectivityRefreshBackgroundTask] = []

	private override init() {
		super.init()
	}

	public func activate() {
		WCSession.default.delegate = self
		WCSession.default.activate()
	}

	public func refresh(completion: @escaping () -> Void) {
		self.update()
		guard WCSession.default.activationState == .activated, WCSession.default.isReachable else {
			completion()
			return
		}
		WCSession.default.sendMessage(["request": true], replyHandler: { reply in
			self.receive(reply)
			completion()
		}, errorHandler: { _ in
			completion()
		})
	}

	public func hold(_ task: WKWatchConnectivityRefreshBackgroundTask) {
		DispatchQueue.main.async {
			self.tasks.append(task)
			self.release()
		}
	}

	public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
		self.receive(session.receivedApplicationContext)
	}

	public func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
		self.receive(applicationContext)
	}

	public func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any]) {
		self.receive(userInfo)
	}

	private func receive(_ payload: [String: Any]) {
		if let data = payload["snapshot"] as? Data {
			BatteryStore.save(data)
		}
		DispatchQueue.main.async {
			self.update()
			self.release()
		}
	}

	private func update() {
		self.devices = BatteryStore.devices()
		self.date = BatteryStore.load()?.date
		WidgetCenter.shared.reloadAllTimelines()
	}

	private func release() {
		guard !WCSession.default.hasContentPending else {
			return
		}
		self.tasks.forEach { $0.setTaskCompletedWithSnapshot(false) }
		self.tasks.removeAll()
	}
}