import WatchKit

public enum WatchBattery {
	public static func read() -> BatteryDevice {
		let device = WKInterfaceDevice.current()
		device.isBatteryMonitoringEnabled = true
		return BatteryDevice(id: "watch", kind: .watch, name: "Apple Watch", symbol: BatteryKind.watch.symbol, level: max(0, Double(device.batteryLevel)), isCharging: device.batteryState == .charging || device.batteryState == .full, isLowPowerMode: ProcessInfo.processInfo.isLowPowerModeEnabled)
	}
}