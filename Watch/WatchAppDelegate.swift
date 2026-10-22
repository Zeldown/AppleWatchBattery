import WatchKit

public final class WatchAppDelegate: NSObject, WKApplicationDelegate {
	public func applicationDidFinishLaunching() {
		WatchBatteryMonitor.shared.activate()
		WatchAppDelegate.schedule()
	}

	public func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
		for task in backgroundTasks {
			if let refresh = task as? WKApplicationRefreshBackgroundTask {
				WatchAppDelegate.schedule()
				WatchBatteryMonitor.shared.refresh {
					refresh.setTaskCompletedWithSnapshot(false)
				}
			} else if let connectivity = task as? WKWatchConnectivityRefreshBackgroundTask {
				WatchBatteryMonitor.shared.hold(connectivity)
			} else {
				task.setTaskCompletedWithSnapshot(false)
			}
		}
	}

	private static func schedule() {
		WKApplication.shared().scheduleBackgroundRefresh(withPreferredDate: Date().addingTimeInterval(15 * 60), userInfo: nil) { _ in
		}
	}
}