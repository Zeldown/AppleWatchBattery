import SwiftUI

public struct PhoneContentView: View {
	@ObservedObject public var monitor: PhoneBatteryMonitor

	public var body: some View {
		NavigationStack {
			List {
				Section {
					HStack(spacing: 0) {
						ForEach(self.monitor.devices.prefix(4)) { device in
							VStack(spacing: 10) {
								BatteryRing(device: device, lineWidth: 7, showsValue: false)
									.frame(width: 64, height: 64)
								Text(device.percent)
									.font(.system(size: 20, weight: .semibold, design: .rounded))
							}
							.frame(maxWidth: .infinity)
						}
					}
					.padding(.vertical, 12)
				}
				Section("Sources détectées") {
					ForEach(Array(self.monitor.sources.enumerated()), id: \.offset) { source in
						Text(source.element)
							.font(.caption.monospaced())
					}
				}
			}
			.navigationTitle("Batteries")
		}
		.onAppear {
			self.monitor.push()
		}
	}
}