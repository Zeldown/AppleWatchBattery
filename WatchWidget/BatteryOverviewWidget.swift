import SwiftUI
import WidgetKit

public struct BatteryOverviewEntry: TimelineEntry {
	public let date: Date
	public let devices: [BatteryDevice]
}

public struct BatteryOverviewProvider: TimelineProvider {
	public func placeholder(in context: Context) -> BatteryOverviewEntry {
		return BatteryOverviewEntry(date: Date(), devices: [BatteryKind.iPhone, BatteryKind.watch, BatteryKind.airPods, BatteryKind.airPodsCase].map(BatteryDevice.unavailable))
	}

	public func getSnapshot(in context: Context, completion: @escaping (BatteryOverviewEntry) -> Void) {
		completion(BatteryOverviewEntry(date: Date(), devices: BatteryStore.devices()))
	}

	public func getTimeline(in context: Context, completion: @escaping (Timeline<BatteryOverviewEntry>) -> Void) {
		completion(Timeline(entries: [BatteryOverviewEntry(date: Date(), devices: BatteryStore.devices())], policy: .after(Date().addingTimeInterval(15 * 60))))
	}
}

public struct BatteryOverviewWidget: Widget {
	public init() {
	}

	public var body: some WidgetConfiguration {
		StaticConfiguration(kind: "BatteryOverview", provider: BatteryOverviewProvider()) { entry in
			BatteryOverviewWidgetView(entry: entry)
		}
		.configurationDisplayName("Batteries")
		.description("Toutes vos batteries.")
		.supportedFamilies([.accessoryRectangular])
	}
}

private struct BatteryOverviewWidgetView: View {
	public let entry: BatteryOverviewEntry

	public var body: some View {
		HStack(spacing: 4) {
			ForEach(self.entry.devices.prefix(4)) { device in
				VStack(spacing: 3) {
					BatteryRing(device: device, lineWidth: 3.5, showsValue: false)
						.aspectRatio(1, contentMode: .fit)
					Text(device.percent)
						.font(.system(size: 12, weight: .semibold, design: .rounded))
						.minimumScaleFactor(0.6)
						.lineLimit(1)
				}
				.frame(maxWidth: .infinity)
			}
		}
		.containerBackground(for: .widget) {
			Color.clear
		}
	}
}