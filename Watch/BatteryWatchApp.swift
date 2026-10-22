import SwiftUI

@main
public struct BatteryWatchApp: App {
	@WKApplicationDelegateAdaptor(WatchAppDelegate.self) private var delegate

	public var body: some Scene {
		WindowGroup {
			BatteryListView(monitor: WatchBatteryMonitor.shared)
		}
	}
}