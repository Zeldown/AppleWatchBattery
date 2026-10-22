import BackgroundTasks
import SwiftUI

@main
public struct BatteryPhoneApp: App {
	private static let refreshIdentifier = (Bundle.main.bundleIdentifier ?? "") + ".refresh"

	@Environment(\.scenePhase) private var scenePhase

	public init() {
		PhoneBatteryMonitor.shared.activate()
	}

	public var body: some Scene {
		WindowGroup {
			PhoneContentView(monitor: PhoneBatteryMonitor.shared)
		}
		.onChange(of: self.scenePhase) { _, phase in
			if phase == .background {
				BatteryPhoneApp.schedule()
			}
		}
		.backgroundTask(.appRefresh(BatteryPhoneApp.refreshIdentifier)) {
			await BatteryPhoneApp.schedule()
			PhoneBatteryMonitor.shared.push()
		}
	}

	private static func schedule() {
		let request = BGAppRefreshTaskRequest(identifier: BatteryPhoneApp.refreshIdentifier)
		request.earliestBeginDate = Date().addingTimeInterval(15 * 60)
		try? BGTaskScheduler.shared.submit(request)
	}
}