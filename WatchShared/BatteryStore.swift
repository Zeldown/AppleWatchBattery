import Foundation

public enum BatteryStore {
	private static let defaults = UserDefaults(suiteName: Bundle.main.object(forInfoDictionaryKey: "AppGroup") as? String) ?? UserDefaults.standard

	public static func load() -> BatterySnapshot? {
		return BatteryStore.defaults.data(forKey: "snapshot").flatMap(BatterySnapshot.decode)
	}

	public static func save(_ data: Data) {
		guard let snapshot = BatterySnapshot.decode(data), snapshot.date > (BatteryStore.load()?.date ?? Date.distantPast) else {
			return
		}
		BatteryStore.defaults.set(data, forKey: "snapshot")
	}

	public static func devices() -> [BatteryDevice] {
		let remote = BatteryStore.load()?.devices ?? []
		return remote.filter { $0.kind == .iPhone } + [WatchBattery.read()] + remote.filter { $0.kind != .iPhone }
	}
}