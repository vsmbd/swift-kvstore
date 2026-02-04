//
//  KVStore.swift
//  KVStore
//
//  Created by vsmbd on 01/02/26.
//

import Foundation
import SwiftCore

/// Result type for KVStore operations: `CheckpointedResult<T, KVStoreError>`.
public typealias KVStoreResult<T> = CheckpointedResult<T, KVStoreError>

// MARK: - KVStore

/// Storage contract for key–value operations. String keys; one getType/setType pair per supported type; all return `KVStoreResult<T>`.
/// Supported types: SwiftCore.ScalarValue (String, Bool, Int64, UInt64, Double, Float) plus Data. Call site uses the typed method name (e.g. getBool/setBool), enforcing type safety at compile time.
public protocol KVStore: Entity,
						 Sendable {
	func getBool(_ key: String) -> KVStoreResult<Bool?>
	func setBool(
		_ key: String,
		value: Bool
	) -> KVStoreResult<Void>

	func getInt64(_ key: String) -> KVStoreResult<Int64?>
	func setInt64(
		_ key: String,
		value: Int64
	) -> KVStoreResult<Void>

	func getUInt64(_ key: String) -> KVStoreResult<UInt64?>
	func setUInt64(
		_ key: String,
		value: UInt64
	) -> KVStoreResult<Void>

	func getDouble(_ key: String) -> KVStoreResult<Double?>
	func setDouble(
		_ key: String,
		value: Double
	) -> KVStoreResult<Void>

	func getFloat(_ key: String) -> KVStoreResult<Float?>
	func setFloat(
		_ key: String,
		value: Float
	) -> KVStoreResult<Void>

	func getString(_ key: String) -> KVStoreResult<String?>
	func setString(
		_ key: String,
		value: String
	) -> KVStoreResult<Void>

	func getData(_ key: String) -> KVStoreResult<Data?>
	func setData(
		_ key: String,
		value: Data
	) -> KVStoreResult<Void>

	func remove(_ key: String) -> KVStoreResult<Void>
}
