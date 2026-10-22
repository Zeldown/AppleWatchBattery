import Foundation

public enum PowerSourceReader {
	private typealias CopyByType = @convention(c) (Int32) -> Unmanaged<CFTypeRef>?
	private typealias CopyList = @convention(c) (CFTypeRef) -> Unmanaged<CFArray>?
	private typealias GetDescription = @convention(c) (CFTypeRef, CFTypeRef) -> Unmanaged<CFDictionary>?

	private static let handle = dlopen("/System/Library/Frameworks/IOKit.framework/IOKit", RTLD_NOW)

	public static func descriptions() -> [[String: Any]] {
		guard let handle = PowerSourceReader.handle, let copyByType = dlsym(handle, "IOPSCopyPowerSourcesByType"), let copyList = dlsym(handle, "IOPSCopyPowerSourcesList"), let getDescription = dlsym(handle, "IOPSGetPowerSourceDescription") else {
			return []
		}
		let byType = unsafeBitCast(copyByType, to: CopyByType.self)
		let list = unsafeBitCast(copyList, to: CopyList.self)
		let description = unsafeBitCast(getDescription, to: GetDescription.self)
		guard let blob = byType(0)?.takeRetainedValue(), let sources = list(blob)?.takeRetainedValue() else {
			return []
		}
		return (sources as NSArray).compactMap { source in
			return description(blob, source as CFTypeRef)?.takeUnretainedValue() as? [String: Any]
		}
	}

	public static func accessories() -> [BatteryDevice] {
		let parts = PowerSourceReader.descriptions().compactMap(PowerSourceReader.part)
		let whole = parts.filter { $0.part == .whole }
		let buds = parts.filter { $0.part == .left || $0.part == .right }
		let others = parts.filter { $0.part == .case || $0.part == .other }.map { $0.device }
		if !whole.isEmpty {
			return whole.map { $0.device } + others
		}
		if buds.count == 2, buds[0].device.value == buds[1].device.value, buds[0].device.isCharging == buds[1].device.isCharging {
			let bud = buds[0].device
			return [BatteryDevice(id: "airpods", kind: .airPods, name: bud.name, symbol: PowerSourceReader.symbol(.whole, bud.name), level: bud.level, isCharging: bud.isCharging, isLowPowerMode: false)] + others
		}
		return buds.map { $0.device } + others
	}

	private static func part(_ description: [String: Any]) -> PowerSourcePart? {
		let category = description["Accessory Category"] as? String ?? ""
		let type = description["Type"] as? String ?? ""
		guard let name = description["Name"] as? String, category != "Watch", type != "InternalBattery", let current = description["Current Capacity"] as? Int, let maximum = description["Max Capacity"] as? Int, maximum > 0 else {
			return nil
		}
		let text = ((description["Part Identifier"] as? String ?? "") + " " + name).lowercased()
		let part: PowerSourcePart.Part
		if text.contains("case") || text.contains("boîtier") || text.contains("étui") {
			part = .case
		} else if text.contains("left") || text.contains("gauche") {
			part = .left
		} else if text.contains("right") || text.contains("droit") {
			part = .right
		} else if category.lowercased().contains("audio") || category.lowercased().contains("headphone") || text.contains("airpods") || text.contains("beats") {
			part = .whole
		} else {
			part = .other
		}
		let kind: BatteryKind = part == .case ? .airPodsCase : part == .other ? .accessory : .airPods
		let charging = description["Is Charging"] as? Bool == true || description["Power Source State"] as? String == "AC Power"
		let identifier = description["Power Source ID"].map { "\($0)" } ?? name
		let device = BatteryDevice(id: "\(identifier)-\(part)", kind: kind, name: name, symbol: PowerSourceReader.symbol(part, name), level: min(1, Double(current) / Double(maximum)), isCharging: charging, isLowPowerMode: false)
		return PowerSourcePart(part: part, device: device)
	}

	private static func symbol(_ part: PowerSourcePart.Part, _ name: String) -> String {
		let lowered = name.lowercased()
		if lowered.contains("max") {
			return "airpodsmax"
		}
		let pro = lowered.contains("pro")
		switch part {
		case .whole: return pro ? "airpodspro" : "airpods"
		case .left: return pro ? "airpodpro.left" : "airpod.left"
		case .right: return pro ? "airpodpro.right" : "airpod.right"
		case .case: return pro ? "airpodspro.chargingcase.wireless.fill" : "airpods.chargingcase.fill"
		case .other: return BatteryKind.accessory.symbol
		}
	}
}

private struct PowerSourcePart {
	public enum Part {
		case whole
		case left
		case right
		case `case`
		case other
	}

	public let part: Part
	public let device: BatteryDevice
}