import Foundation

public struct BatterySnapshot: Codable {
	public let devices: [BatteryDevice]
	public let date: Date

	public static func decode(_ data: Data) -> BatterySnapshot? {
		return try? JSONDecoder().decode(BatterySnapshot.self, from: data)
	}

	public func encode() -> Data? {
		return try? JSONEncoder().encode(self)
	}
}