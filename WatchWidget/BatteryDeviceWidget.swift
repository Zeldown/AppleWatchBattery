import SwiftUI
import WidgetKit

public struct BatteryDeviceEntry: TimelineEntry {
	public let date: Date
	public let kind: BatteryKind
	public let device: BatteryDevice?
}

public struct BatteryDeviceProvider: AppIntentTimelineProvider {
	public func placeholder(in context: Context) -> BatteryDeviceEntry {
		return BatteryDeviceEntry(date: Date(), kind: .watch, device: WatchBattery.read())
	}

	public func snapshot(for configuration: SelectDeviceIntent, in context: Context) async -> BatteryDeviceEntry {
		return self.entry(configuration.kind)
	}

	public func timeline(for configuration: SelectDeviceIntent, in context: Context) async -> Timeline<BatteryDeviceEntry> {
		return Timeline(entries: [self.entry(configuration.kind)], policy: .after(Date().addingTimeInterval(15 * 60)))
	}

	public func recommendations() -> [AppIntentRecommendation<SelectDeviceIntent>] {
		return [BatteryKind.watch, BatteryKind.iPhone, BatteryKind.airPods, BatteryKind.airPodsCase].map { kind in
			return AppIntentRecommendation(intent: SelectDeviceIntent(kind: kind), description: String(localized: kind.title))
		}
	}

	private func entry(_ kind: BatteryKind) -> BatteryDeviceEntry {
		return BatteryDeviceEntry(date: Date(), kind: kind, device: BatteryStore.devices().first { $0.kind == kind })
	}
}

public struct BatteryDeviceWidget: Widget {
	public init() {
	}

	public var body: some WidgetConfiguration {
		AppIntentConfiguration(kind: "BatteryDevice", intent: SelectDeviceIntent.self, provider: BatteryDeviceProvider()) { entry in
			BatteryDeviceWidgetView(entry: entry)
		}
		.configurationDisplayName("Batterie")
		.description("La batterie d'un appareil.")
		.supportedFamilies([.accessoryCircular, .accessoryCorner, .accessoryInline])
	}
}

private struct BatteryDeviceWidgetView: View {
	@Environment(\.widgetFamily) private var family

	public let entry: BatteryDeviceEntry

	public var body: some View {
		let device = self.entry.device ?? BatteryDevice.unavailable(self.entry.kind)
		Group {
			switch self.family {
			case .accessoryCorner:
				Image(systemName: device.symbol)
					.font(.system(size: 20, weight: .medium))
					.widgetLabel {
						Gauge(value: device.level) {
							Text(device.name)
						} currentValueLabel: {
							Text(device.percent)
						} minimumValueLabel: {
							Text("")
						} maximumValueLabel: {
							Text(self.entry.device == nil ? "–" : device.percent)
						}
						.tint(device.color)
					}
			case .accessoryInline:
				Label {
					Text("\(Text(self.entry.kind.title)) \(self.entry.device == nil ? "–" : device.percent)")
				} icon: {
					Image(systemName: device.symbol)
				}
			default:
				ZStack {
					AccessoryWidgetBackground()
					BatteryRing(device: device, lineWidth: 4.5, showsValue: self.entry.device != nil)
						.padding(3)
				}
			}
		}
		.containerBackground(for: .widget) {
			Color.clear
		}
	}
}