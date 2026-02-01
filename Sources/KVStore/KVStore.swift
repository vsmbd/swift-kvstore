//
//  KVStore.swift
//  KVStore
//
//  Created by vsmbd on 01/02/26.
//

import Foundation
import SwiftCore

// MARK: - KVStore

/// Storage contract for key–value operations. String keys; one get/set overload per supported type; all return `CheckpointedResult<T, KVStoreError>`.
/// Supported types: SwiftCore.ScalarValue (String, Bool, Int64, UInt64, Double, Float) plus Data. Compiler picks the overload from the call site (return type or argument type), enforcing type safety at compile time.
public protocol KVStore: Sendable {
	func get(_ key: String) -> CheckpointedResult<Bool?, KVStoreError>
	func set(_ key: String, value: Bool) -> CheckpointedResult<Void, KVStoreError>

	func get(_ key: String) -> CheckpointedResult<Int64?, KVStoreError>
	func set(_ key: String, value: Int64) -> CheckpointedResult<Void, KVStoreError>

	func get(_ key: String) -> CheckpointedResult<UInt64?, KVStoreError>
	func set(_ key: String, value: UInt64) -> CheckpointedResult<Void, KVStoreError>

	func get(_ key: String) -> CheckpointedResult<Double?, KVStoreError>
	func set(_ key: String, value: Double) -> CheckpointedResult<Void, KVStoreError>

	func get(_ key: String) -> CheckpointedResult<Float?, KVStoreError>
	func set(_ key: String, value: Float) -> CheckpointedResult<Void, KVStoreError>

	func get(_ key: String) -> CheckpointedResult<String?, KVStoreError>
	func set(_ key: String, value: String) -> CheckpointedResult<Void, KVStoreError>

	func get(_ key: String) -> CheckpointedResult<Data?, KVStoreError>
	func set(_ key: String, value: Data) -> CheckpointedResult<Void, KVStoreError>

	func remove(_ key: String) -> CheckpointedResult<Void, KVStoreError>
}
