import SwiftUI

public struct BatteryDevice: Codable, Hashable, Identifiable {
	public let id: String
	public let kind: BatteryKind
	public let name: String
	public let symbol: String
	public let level: Double
	public let isCharging: Bool
	public let isLowPowerMode: Bool

	public static func unavailable(_ kind: BatteryKind) -> BatteryDevice {
		return BatteryDevice(id: kind.rawValue, kind: kind, name: String(localized: kind.title), symbol: kind.symbol, level: 0, isCharging: false, isLowPowerMode: false)
	}

	public var value: Int {
		return Int((self.level * 100).rounded())
	}

	public var percent: String {
		return self.level.formatted(.percent.precision(.fractionLength(0)))
	}

	public var color: Color {
		if self.isLowPowerMode {
			return Color.yellow
		}
		if self.level <= 0.2 && !self.isCharging {
			return Color.red
		}
		return Color.green
	}
}