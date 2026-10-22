import SwiftUI
import WidgetKit

public struct BatteryRing: View {
	private let device: BatteryDevice
	private let lineWidth: CGFloat
	private let showsValue: Bool

	public init(device: BatteryDevice, lineWidth: CGFloat, showsValue: Bool) {
		self.device = device
		self.lineWidth = lineWidth
		self.showsValue = showsValue
	}

	public var body: some View {
		GeometryReader { geometry in
			let size = min(geometry.size.width, geometry.size.height)
			let gap = self.device.isCharging ? 0.14 : 0
			ZStack {
				BatteryArc(start: gap / 2, end: 1 - gap / 2)
					.stroke(Color.gray.opacity(0.35), style: StrokeStyle(lineWidth: self.lineWidth, lineCap: .round))
					.padding(self.lineWidth / 2)
				BatteryArc(start: gap / 2, end: gap / 2 + (1 - gap) * self.device.level)
					.stroke(self.device.color, style: StrokeStyle(lineWidth: self.lineWidth, lineCap: .round))
					.padding(self.lineWidth / 2)
					.widgetAccentable()
				if self.showsValue {
					VStack(spacing: -1) {
						Image(systemName: self.device.symbol)
							.font(.system(size: size * 0.24, weight: .medium))
						Text("\(self.device.value)")
							.font(.system(size: size * 0.3, weight: .semibold, design: .rounded))
							.minimumScaleFactor(0.5)
					}
				} else {
					Image(systemName: self.device.symbol)
						.font(.system(size: size * 0.4, weight: .medium))
				}
				if self.device.isCharging {
					Image(systemName: "bolt.fill")
						.font(.system(size: size * 0.2, weight: .bold))
						.foregroundStyle(self.device.color)
						.widgetAccentable()
						.offset(y: self.lineWidth / 2 - size / 2)
				}
			}
			.frame(width: size, height: size)
			.position(x: geometry.size.width / 2, y: geometry.size.height / 2)
		}
	}
}

private struct BatteryArc: Shape {
	public let start: Double
	public let end: Double

	public func path(in rect: CGRect) -> Path {
		var path = Path()
		path.addArc(center: CGPoint(x: rect.midX, y: rect.midY), radius: min(rect.width, rect.height) / 2, startAngle: .degrees(self.start * 360 - 90), endAngle: .degrees(self.end * 360 - 90), clockwise: false)
		return path
	}
}