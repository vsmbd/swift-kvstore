//
//  SecureStore.swift
//  KVStore
//
//  Created by vsmbd on 01/02/26.
//

import Foundation
import SwiftCore

#if canImport(Security)
import Security
#endif

#if canImport(Security)

// MARK: - SecureStore

/// Keychain-backed store for secrets and credentials. Higher latency than SettingsStore; values stored as encrypted Data by the platform.
public final class SecureStore: KVStore,
								Sendable {
	// MARK: + Private scope

	private let service: String

	// MARK: + Public scope

	public init(service: String) {
		self.service = service
	}

	public func get(_ key: String) -> CheckpointedResult<Bool?, KVStoreError> {
		switch readData(key) {
		case .success(nil):
			return .success(nil)
		case .success(let data?):
			guard let value = decodeBool(data) else {
				return .failure(.typeMismatch(key: key, expected: "Bool"))
			}
			return .success(value)
		case .failure(let error):
			return .failure(error)
		}
	}

	public func set(_ key: String, value: Bool) -> CheckpointedResult<Void, KVStoreError> {
		writeData(key, encodeBool(value))
	}

	public func get(_ key: String) -> CheckpointedResult<Int64?, KVStoreError> {
		switch readData(key) {
		case .success(nil):
			return .success(nil)
		case .success(let data?):
			guard let value = decodeInt64(data) else {
				return .failure(.typeMismatch(key: key, expected: "Int64"))
			}
			return .success(value)
		case .failure(let error):
			return .failure(error)
		}
	}

	public func set(_ key: String, value: Int64) -> CheckpointedResult<Void, KVStoreError> {
		writeData(key, encodeInt64(value))
	}

	public func get(_ key: String) -> CheckpointedResult<UInt64?, KVStoreError> {
		switch readData(key) {
		case .success(nil):
			return .success(nil)
		case .success(let data?):
			guard let value = decodeUInt64(data) else {
				return .failure(.typeMismatch(key: key, expected: "UInt64"))
			}
			return .success(value)
		case .failure(let error):
			return .failure(error)
		}
	}

	public func set(_ key: String, value: UInt64) -> CheckpointedResult<Void, KVStoreError> {
		writeData(key, encodeUInt64(value))
	}

	public func get(_ key: String) -> CheckpointedResult<Double?, KVStoreError> {
		switch readData(key) {
		case .success(nil):
			return .success(nil)
		case .success(let data?):
			guard let value = decodeDouble(data) else {
				return .failure(.typeMismatch(key: key, expected: "Double"))
			}
			return .success(value)
		case .failure(let error):
			return .failure(error)
		}
	}

	public func set(_ key: String, value: Double) -> CheckpointedResult<Void, KVStoreError> {
		writeData(key, encodeDouble(value))
	}

	public func get(_ key: String) -> CheckpointedResult<Float?, KVStoreError> {
		switch readData(key) {
		case .success(nil):
			return .success(nil)
		case .success(let data?):
			guard let value = decodeFloat(data) else {
				return .failure(.typeMismatch(key: key, expected: "Float"))
			}
			return .success(value)
		case .failure(let error):
			return .failure(error)
		}
	}

	public func set(_ key: String, value: Float) -> CheckpointedResult<Void, KVStoreError> {
		writeData(key, encodeFloat(value))
	}

	public func get(_ key: String) -> CheckpointedResult<String?, KVStoreError> {
		switch readData(key) {
		case .success(nil):
			return .success(nil)
		case .success(let data?):
			guard let value = decodeString(data) else {
				return .failure(.typeMismatch(key: key, expected: "String"))
			}
			return .success(value)
		case .failure(let error):
			return .failure(error)
		}
	}

	public func set(_ key: String, value: String) -> CheckpointedResult<Void, KVStoreError> {
		writeData(key, encodeString(value))
	}

	public func get(_ key: String) -> CheckpointedResult<Data?, KVStoreError> {
		switch readData(key) {
		case .success(nil):
			return .success(nil)
		case .success(let data?):
			guard let value = decodeData(data) else {
				return .failure(.typeMismatch(key: key, expected: "Data"))
			}
			return .success(value)
		case .failure(let error):
			return .failure(error)
		}
	}

	public func set(_ key: String, value: Data) -> CheckpointedResult<Void, KVStoreError> {
		writeData(key, encodeData(value))
	}

	public func remove(_ key: String) -> CheckpointedResult<Void, KVStoreError> {
		deleteItem(key)
	}

	// MARK: - Keychain ops

	private func readData(_ key: String) -> CheckpointedResult<Data?, KVStoreError> {
		let query: [String: Any] = [
			kSecClass as String: kSecClassGenericPassword,
			kSecAttrService as String: service,
			kSecAttrAccount as String: key,
			kSecReturnData as String: true,
			kSecMatchLimit as String: kSecMatchLimitOne
		]
		var result: AnyObject?
		let status = SecItemCopyMatching(query as CFDictionary, &result)
		switch status {
		case errSecSuccess:
			guard let data = result as? Data else {
				return .failure(.underlying(message: "Keychain returned non-Data for key \"\(key)\""))
			}
			return .success(data)
		case errSecItemNotFound:
			return .success(nil)
		default:
			return .failure(.keychainError(status: status))
		}
	}

	private func writeData(
		_ key: String,
		_ data: Data
	) -> CheckpointedResult<Void, KVStoreError> {
		let query: [String: Any] = [
			kSecClass as String: kSecClassGenericPassword,
			kSecAttrService as String: service,
			kSecAttrAccount as String: key
		]
		SecItemDelete(query as CFDictionary)
		var addQuery = query
		addQuery[kSecValueData as String] = data
		let status = SecItemAdd(addQuery as CFDictionary, nil)
		switch status {
		case errSecSuccess:
			return .success(())
		default:
			return .failure(.keychainError(status: status))
		}
	}

	private func deleteItem(
		_ key: String
	) -> CheckpointedResult<Void, KVStoreError> {
		let query: [String: Any] = [
			kSecClass as String: kSecClassGenericPassword,
			kSecAttrService as String: service,
			kSecAttrAccount as String: key
		]
		let status = SecItemDelete(query as CFDictionary)
		switch status {
		case errSecSuccess, errSecItemNotFound:
			return .success(())
		default:
			return .failure(.keychainError(status: status))
		}
	}

	// MARK: - Encode/decode by type (Keychain tag + payload; matches ScalarValue order)

	private func decodeBool(_ data: Data) -> Bool? {
		guard data.count == 2, data[0] == 0x01 else { return nil }
		return data[1] != 0
	}

	private func decodeInt64(_ data: Data) -> Int64? {
		guard data.count == 1 + 8, data[0] == 0x02 else { return nil }
		return data.withUnsafeBytes { $0.load(fromByteOffset: 1, as: Int64.self) }
	}

	private func decodeUInt64(_ data: Data) -> UInt64? {
		guard data.count == 1 + 8, data[0] == 0x03 else { return nil }
		return data.withUnsafeBytes { $0.load(fromByteOffset: 1, as: UInt64.self) }
	}

	private func decodeDouble(_ data: Data) -> Double? {
		guard data.count == 1 + 8, data[0] == 0x04 else { return nil }
		return data.withUnsafeBytes { $0.load(fromByteOffset: 1, as: Double.self) }
	}

	private func decodeFloat(_ data: Data) -> Float? {
		guard data.count == 1 + 4, data[0] == 0x05 else { return nil }
		return data.withUnsafeBytes { $0.load(fromByteOffset: 1, as: Float.self) }
	}

	private func decodeString(_ data: Data) -> String? {
		guard data.count >= 1, data[0] == 0x06 else { return nil }
		return String(data: data.dropFirst(1), encoding: .utf8)
	}

	private func decodeData(_ data: Data) -> Data? {
		guard data.count >= 1, data[0] == 0x07 else { return nil }
		return data.dropFirst(1)
	}

	private func encodeBool(_ value: Bool) -> Data { Data([0x01, value ? 1 : 0]) }

	private func encodeInt64(_ value: Int64) -> Data {
		var mutable = value
		return Data([0x02] + withUnsafeBytes(of: &mutable) { Array($0) })
	}

	private func encodeUInt64(_ value: UInt64) -> Data {
		var mutable = value
		return Data([0x03] + withUnsafeBytes(of: &mutable) { Array($0) })
	}

	private func encodeDouble(_ value: Double) -> Data {
		var mutable = value
		return Data([0x04] + withUnsafeBytes(of: &mutable) { Array($0) })
	}

	private func encodeFloat(_ value: Float) -> Data {
		var mutable = value
		return Data([0x05] + withUnsafeBytes(of: &mutable) { Array($0) })
	}

	private func encodeString(_ value: String) -> Data {
		Data([0x06] + (value.data(using: .utf8) ?? Data()))
	}

	private func encodeData(_ value: Data) -> Data { Data([0x07] + value) }
}

#endif
