import AppIntents
import WidgetKit

public struct SelectDeviceIntent: WidgetConfigurationIntent {
	public static let title: LocalizedStringResource = "Appareil"

	@Parameter(title: "Appareil", default: .watch) public var kind: BatteryKind

	public init() {
	}

	public init(kind: BatteryKind) {
		self.kind = kind
	}
}