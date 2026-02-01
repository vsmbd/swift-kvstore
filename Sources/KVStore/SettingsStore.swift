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

	public init(defaults: UserDefaults = .standard) {
		self.defaults = defaults
	}

	public func get(_ key: String) -> CheckpointedResult<Bool?, KVStoreError> {
		guard defaults.object(forKey: key) != nil else {
			return .success(nil)
		}
		return .success(defaults.bool(forKey: key))
	}

	public func set(_ key: String, value: Bool) -> CheckpointedResult<Void, KVStoreError> {
		defaults.set(value, forKey: key)
		return .success(())
	}

	public func get(_ key: String) -> CheckpointedResult<Int64?, KVStoreError> {
		guard let number = defaults.object(forKey: key) as? NSNumber else {
			return .success(nil)
		}
		return .success(number.int64Value)
	}

	public func set(_ key: String, value: Int64) -> CheckpointedResult<Void, KVStoreError> {
		defaults.set(NSNumber(value: value), forKey: key)
		return .success(())
	}

	public func get(_ key: String) -> CheckpointedResult<UInt64?, KVStoreError> {
		guard let number = defaults.object(forKey: key) as? NSNumber else {
			return .success(nil)
		}
		return .success(number.uint64Value)
	}

	public func set(_ key: String, value: UInt64) -> CheckpointedResult<Void, KVStoreError> {
		defaults.set(NSNumber(value: value), forKey: key)
		return .success(())
	}

	public func get(_ key: String) -> CheckpointedResult<Double?, KVStoreError> {
		guard defaults.object(forKey: key) != nil else {
			return .success(nil)
		}
		return .success(defaults.double(forKey: key))
	}

	public func set(_ key: String, value: Double) -> CheckpointedResult<Void, KVStoreError> {
		defaults.set(value, forKey: key)
		return .success(())
	}

	public func get(_ key: String) -> CheckpointedResult<Float?, KVStoreError> {
		guard defaults.object(forKey: key) != nil else {
			return .success(nil)
		}
		return .success(defaults.float(forKey: key))
	}

	public func set(_ key: String, value: Float) -> CheckpointedResult<Void, KVStoreError> {
		defaults.set(value, forKey: key)
		return .success(())
	}

	public func get(_ key: String) -> CheckpointedResult<String?, KVStoreError> {
		return .success(defaults.string(forKey: key))
	}

	public func set(_ key: String, value: String) -> CheckpointedResult<Void, KVStoreError> {
		defaults.set(value, forKey: key)
		return .success(())
	}

	public func get(_ key: String) -> CheckpointedResult<Data?, KVStoreError> {
		return .success(defaults.data(forKey: key))
	}

	public func set(_ key: String, value: Data) -> CheckpointedResult<Void, KVStoreError> {
		defaults.set(value, forKey: key)
		return .success(())
	}

	public func remove(_ key: String) -> CheckpointedResult<Void, KVStoreError> {
		defaults.removeObject(forKey: key)
		return .success(())
	}
}
