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

/// Keychain-backed store for secrets and credentials.
/// Higher latency than SettingsStore; values stored as encrypted Data by the platform.
public final class SecureStore: KVStore,
								Sendable {
	// MARK: + Private scope

	private let service: String

	// MARK: ++ Keychain operations

	private func readData(_ key: String) -> KVStoreResult<Data?> {
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
				let storeError: KVStoreError = .underlying(message: "Keychain returned non-Data for key \"\(key)\"")
				return .failure(.init(
					error: storeError,
					.checkpoint(self),
					extras: [ErrorInfoKey.underlying: .string(String(describing: storeError))]
				))
			}
			return .success(data, .checkpoint(self))
		case errSecItemNotFound:
			return .success(nil, .checkpoint(self))
		default:
			let storeError: KVStoreError = .keychainError(status: status)
			return .failure(.init(
				error: storeError,
				.checkpoint(self),
				extras: [ErrorInfoKey.underlying: .string(String(describing: storeError))]
			))
		}
	}

	private func writeData(
		_ key: String,
		_ data: Data
	) -> KVStoreResult<Void> {
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
			return .success((), .checkpoint(self))
		default:
			let storeError: KVStoreError = .keychainError(status: status)
			return .failure(.init(
				error: storeError,
				.checkpoint(self),
				extras: [ErrorInfoKey.underlying: .string(String(describing: storeError))]
			))
		}
	}

	private func deleteItem(
		_ key: String
	) -> KVStoreResult<Void> {
		let query: [String: Any] = [
			kSecClass as String: kSecClassGenericPassword,
			kSecAttrService as String: service,
			kSecAttrAccount as String: key
		]
		let status = SecItemDelete(query as CFDictionary)
		switch status {
		case errSecSuccess, errSecItemNotFound:
			return .success((), .checkpoint(self))
		default:
			let storeError: KVStoreError = .keychainError(status: status)
			return .failure(.init(
				error: storeError,
				.checkpoint(self),
				extras: [ErrorInfoKey.underlying: .string(String(describing: storeError))]
			))
		}
	}

	// MARK: ++ Encode/Decode by type (Keychain tag + payload)

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

	private func encodeData(_ value: Data) -> Data {
		Data([0x07] + value)
	}

	// MARK: + Public scope

	public let identifier: UInt64

	public init(service: String) {
		self.service = service
		self.identifier = Self.nextID
	}

	public func getBool(_ key: String) -> KVStoreResult<Bool?> {
		switch readData(key) {
		case .success(nil, let checkpoint):
			return .success(nil, checkpoint)
		case .success(let data?, let checkpoint):
			guard let value = decodeBool(data) else {
				let storeError: KVStoreError = .typeMismatch(key: key, expected: "Bool")
				return .failure(.init(
					error: storeError,
					.checkpoint(self),
					extras: [ErrorInfoKey.underlying: .string(String(describing: storeError))]
				))
			}
			return .success(value, checkpoint)
		case .failure(let errorInfo):
			return .failure(errorInfo)
		}
	}

	public func setBool(_ key: String, value: Bool) -> KVStoreResult<Void> {
		switch writeData(key, encodeBool(value)) {
		case .success(_, let checkpoint):
			return .success((), checkpoint)
		case .failure(let errorInfo):
			return .failure(errorInfo)
		}
	}

	public func getInt64(_ key: String) -> KVStoreResult<Int64?> {
		switch readData(key) {
		case .success(nil, let checkpoint):
			return .success(nil, checkpoint)
		case .success(let data?, let checkpoint):
			guard let value = decodeInt64(data) else {
				let storeError: KVStoreError = .typeMismatch(key: key, expected: "Int64")
				return .failure(.init(
					error: storeError,
					.checkpoint(self),
					extras: [ErrorInfoKey.underlying: .string(String(describing: storeError))]
				))
			}
			return .success(value, checkpoint)
		case .failure(let errorInfo):
			return .failure(errorInfo)
		}
	}

	public func setInt64(_ key: String, value: Int64) -> KVStoreResult<Void> {
		switch writeData(key, encodeInt64(value)) {
		case .success(_, let checkpoint):
			return .success((), checkpoint)
		case .failure(let errorInfo):
			return .failure(errorInfo)
		}
	}

	public func getUInt64(_ key: String) -> KVStoreResult<UInt64?> {
		switch readData(key) {
		case .success(nil, let checkpoint):
			return .success(nil, checkpoint)
		case .success(let data?, let checkpoint):
			guard let value = decodeUInt64(data) else {
				let storeError: KVStoreError = .typeMismatch(key: key, expected: "UInt64")
				return .failure(.init(
					error: storeError,
					.checkpoint(self),
					extras: [ErrorInfoKey.underlying: .string(String(describing: storeError))]
				))
			}
			return .success(value, checkpoint)
		case .failure(let errorInfo):
			return .failure(errorInfo)
		}
	}

	public func setUInt64(_ key: String, value: UInt64) -> KVStoreResult<Void> {
		switch writeData(key, encodeUInt64(value)) {
		case .success(_, let checkpoint):
			return .success((), checkpoint)
		case .failure(let errorInfo):
			return .failure(errorInfo)
		}
	}

	public func getDouble(_ key: String) -> KVStoreResult<Double?> {
		switch readData(key) {
		case .success(nil, let checkpoint):
			return .success(nil, checkpoint)
		case .success(let data?, let checkpoint):
			guard let value = decodeDouble(data) else {
				let storeError: KVStoreError = .typeMismatch(key: key, expected: "Double")
				return .failure(.init(
					error: storeError,
					.checkpoint(self),
					extras: [ErrorInfoKey.underlying: .string(String(describing: storeError))]
				))
			}
			return .success(value, checkpoint)
		case .failure(let errorInfo):
			return .failure(errorInfo)
		}
	}

	public func setDouble(_ key: String, value: Double) -> KVStoreResult<Void> {
		switch writeData(key, encodeDouble(value)) {
		case .success(_, let checkpoint):
			return .success((), checkpoint)
		case .failure(let errorInfo):
			return .failure(errorInfo)
		}
	}

	public func getFloat(_ key: String) -> KVStoreResult<Float?> {
		switch readData(key) {
		case .success(nil, let checkpoint):
			return .success(nil, checkpoint)
		case .success(let data?, let checkpoint):
			guard let value = decodeFloat(data) else {
				let storeError: KVStoreError = .typeMismatch(key: key, expected: "Float")
				return .failure(.init(
					error: storeError,
					.checkpoint(self),
					extras: [ErrorInfoKey.underlying: .string(String(describing: storeError))]
				))
			}
			return .success(value, checkpoint)
		case .failure(let errorInfo):
			return .failure(errorInfo)
		}
	}

	public func setFloat(_ key: String, value: Float) -> KVStoreResult<Void> {
		switch writeData(key, encodeFloat(value)) {
		case .success(_, let checkpoint):
			return .success((), checkpoint)
		case .failure(let errorInfo):
			return .failure(errorInfo)
		}
	}

	public func getString(_ key: String) -> KVStoreResult<String?> {
		switch readData(key) {
		case .success(nil, let checkpoint):
			return .success(nil, checkpoint)
		case .success(let data?, let checkpoint):
			guard let value = decodeString(data) else {
				let storeError: KVStoreError = .typeMismatch(key: key, expected: "String")
				return .failure(.init(
					error: storeError,
					.checkpoint(self),
					extras: [ErrorInfoKey.underlying: .string(String(describing: storeError))]
				))
			}
			return .success(value, checkpoint)
		case .failure(let errorInfo):
			return .failure(errorInfo)
		}
	}

	public func setString(_ key: String, value: String) -> KVStoreResult<Void> {
		switch writeData(key, encodeString(value)) {
		case .success(_, let checkpoint):
			return .success((), checkpoint)
		case .failure(let errorInfo):
			return .failure(errorInfo)
		}
	}

	public func getData(_ key: String) -> KVStoreResult<Data?> {
		switch readData(key) {
		case .success(nil, let checkpoint):
			return .success(nil, checkpoint)
		case .success(let data?, let checkpoint):
			guard let value = decodeData(data) else {
				let storeError: KVStoreError = .typeMismatch(key: key, expected: "Data")
				return .failure(.init(
					error: storeError,
					.checkpoint(self),
					extras: [ErrorInfoKey.underlying: .string(String(describing: storeError))]
				))
			}
			return .success(value, checkpoint)
		case .failure(let errorInfo):
			return .failure(errorInfo)
		}
	}

	public func setData(_ key: String, value: Data) -> KVStoreResult<Void> {
		switch writeData(key, encodeData(value)) {
		case .success(_, let checkpoint):
			return .success((), checkpoint)
		case .failure(let errorInfo):
			return .failure(errorInfo)
		}
	}

	public func remove(_ key: String) -> KVStoreResult<Void> {
		switch deleteItem(key) {
		case .success(_, let checkpoint):
			return .success((), checkpoint)
		case .failure(let errorInfo):
			return .failure(errorInfo)
		}
	}
}

#endif
