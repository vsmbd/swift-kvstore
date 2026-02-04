//
//  SettingsStore.swift
//  KVStore
//
//  Created by vsmbd on 01/02/26.
//

import Foundation
import SwiftCore

// MARK: - SettingsStore

/// UserDefaults-backed store for non-sensitive configuration and flags. Fast, synchronous; not encrypted.
/// UserDefaults (NSUserDefaults) is thread-safe: you can use the same instance from multiple threads without acquiring a lock.
/// See: https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/Multithreading/ThreadSafetySummary/ThreadSafetySummary.html
/// Sendable is unchecked because `UserDefaults` is not marked Sendable.
public final class SettingsStore: KVStore,
								  @unchecked Sendable {
	// MARK: + Private scope

	private let defaults: UserDefaults

	// MARK: + Public scope

	public let identifier: UInt64

	public init(defaults: UserDefaults = .standard) {
		self.defaults = defaults
		self.identifier = Self.nextID
	}

	public func getBool(_ key: String) -> KVStoreResult<Bool?> {
		guard defaults.object(forKey: key) != nil else {
			return .success(nil, .checkpoint(self))
		}
		return .success(defaults.bool(forKey: key), .checkpoint(self))
	}

	public func setBool(_ key: String, value: Bool) -> KVStoreResult<Void> {
		defaults.set(value, forKey: key)
		return .success((), .checkpoint(self))
	}

	public func getInt64(_ key: String) -> KVStoreResult<Int64?> {
		guard let number = defaults.object(forKey: key) as? NSNumber else {
			return .success(nil, .checkpoint(self))
		}
		return .success(number.int64Value, .checkpoint(self))
	}

	public func setInt64(_ key: String, value: Int64) -> KVStoreResult<Void> {
		defaults.set(NSNumber(value: value), forKey: key)
		return .success((), .checkpoint(self))
	}

	public func getUInt64(_ key: String) -> KVStoreResult<UInt64?> {
		guard let number = defaults.object(forKey: key) as? NSNumber else {
			return .success(nil, .checkpoint(self))
		}
		return .success(number.uint64Value, .checkpoint(self))
	}

	public func setUInt64(_ key: String, value: UInt64) -> KVStoreResult<Void> {
		defaults.set(NSNumber(value: value), forKey: key)
		return .success((), .checkpoint(self))
	}

	public func getDouble(_ key: String) -> KVStoreResult<Double?> {
		guard defaults.object(forKey: key) != nil else {
			return .success(nil, .checkpoint(self))
		}
		return .success(defaults.double(forKey: key), .checkpoint(self))
	}

	public func setDouble(_ key: String, value: Double) -> KVStoreResult<Void> {
		defaults.set(value, forKey: key)
		return .success((), .checkpoint(self))
	}

	public func getFloat(_ key: String) -> KVStoreResult<Float?> {
		guard defaults.object(forKey: key) != nil else {
			return .success(nil, .checkpoint(self))
		}
		return .success(defaults.float(forKey: key), .checkpoint(self))
	}

	public func setFloat(_ key: String, value: Float) -> KVStoreResult<Void> {
		defaults.set(value, forKey: key)
		return .success((), .checkpoint(self))
	}

	public func getString(_ key: String) -> KVStoreResult<String?> {
		return .success(defaults.string(forKey: key), .checkpoint(self))
	}

	public func setString(_ key: String, value: String) -> KVStoreResult<Void> {
		defaults.set(value, forKey: key)
		return .success((), .checkpoint(self))
	}

	public func getData(_ key: String) -> KVStoreResult<Data?> {
		return .success(defaults.data(forKey: key), .checkpoint(self))
	}

	public func setData(_ key: String, value: Data) -> KVStoreResult<Void> {
		defaults.set(value, forKey: key)
		return .success((), .checkpoint(self))
	}

	public func remove(_ key: String) -> KVStoreResult<Void> {
		defaults.removeObject(forKey: key)
		return .success((), .checkpoint(self))
	}
}
