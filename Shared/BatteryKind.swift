import AppIntents

public enum BatteryKind: String, Codable, CaseIterable, AppEnum {
	case iPhone
	case watch
	case airPods
	case airPodsCase
	case accessory

	public static let typeDisplayRepresentation: TypeDisplayRepresentation = "Appareil"
	public static let caseDisplayRepresentations: [BatteryKind: DisplayRepresentation] = [
		.iPhone: "iPhone",
		.watch: "Apple Watch",
		.airPods: "AirPods",
		.airPodsCase: "Boîtier AirPods",
		.accessory: "Accessoire"
	]

	public var title: LocalizedStringResource {
		switch self {
		case .iPhone: return "iPhone"
		case .watch: return "Apple Watch"
		case .airPods: return "AirPods"
		case .airPodsCase: return "Boîtier AirPods"
		case .accessory: return "Accessoire"
		}
	}

	public var symbol: String {
		switch self {
		case .iPhone: return "iphone"
		case .watch: return "applewatch"
		case .airPods: return "airpodspro"
		case .airPodsCase: return "airpodspro.chargingcase.wireless.fill"
		case .accessory: return "headphones"
		}
	}
}