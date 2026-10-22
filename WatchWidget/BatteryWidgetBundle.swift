import SwiftUI
import WidgetKit

@main
public struct BatteryWidgetBundle: WidgetBundle {
	public var body: some Widget {
		BatteryDeviceWidget()
		BatteryOverviewWidget()
	}
}