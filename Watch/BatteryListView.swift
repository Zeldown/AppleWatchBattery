import SwiftUI

public struct BatteryListView: View {
	@ObservedObject public var monitor: WatchBatteryMonitor

	public var body: some View {
		NavigationStack {
			List {
				ForEach(self.monitor.devices) { device in
					HStack(spacing: 10) {
						BatteryRing(device: device, lineWidth: 3.5, showsValue: false)
							.frame(width: 34, height: 34)
						Text(device.name)
							.lineLimit(1)
						Spacer(minLength: 4)
						Text(device.percent)
							.font(.system(.body, design: .rounded).monospacedDigit())
					}
				}
				if let date = self.monitor.date {
					Text("iPhone mis à jour \(date, format: .relative(presentation: .named))")
						.font(.footnote)
						.foregroundStyle(.secondary)
						.listRowBackground(Color.clear)
				}
			}
			.navigationTitle("Batteries")
		}
		.onAppear {
			self.monitor.refresh {
			}
		}
	}
}