//
//  KVStoreTests.swift
//  KVStoreTests
//

import Foundation
import SwiftCore
import Testing
@testable import KVStore

// MARK: - SettingsStoreTests

@Test
func settingsStore_getMissing_returnsSuccessNil() async throws {
	let defaults = UserDefaults(suiteName: "KVStoreTests.settingsStore.getMissing")!
	defaults.removePersistentDomain(forName: "KVStoreTests.settingsStore.getMissing")
	let store = SettingsStore(defaults: defaults)
	let result: CheckpointedResult<String?, KVStoreError> = store.get("nonexistent")
	switch result {
	case let .success(value, _):
		#expect(value == nil)
	case .failure:
		Issue.record("expected success(nil), got failure")
	}
}

@Test
func settingsStore_setThenGet_roundTrips() async throws {
	let defaults = UserDefaults(suiteName: "KVStoreTests.settingsStore.roundTrip")!
	defaults.removePersistentDomain(forName: "KVStoreTests.settingsStore.roundTrip")
	let store = SettingsStore(defaults: defaults)
	switch store.set("k", value: Int64(42)) {
	case .success: break
	case .failure(let errorInfo): Issue.record("set failed: \(errorInfo.error)")
	}
	let getResult: CheckpointedResult<Int64?, KVStoreError> = store.get("k")
	switch getResult {
	case let .success(value, _):
		#expect(value == 42)
	case .failure:
		Issue.record("expected success(42), got failure")
	}
}

@Test
func settingsStore_remove_thenGetReturnsNil() async throws {
	let defaults = UserDefaults(suiteName: "KVStoreTests.settingsStore.remove")!
	defaults.removePersistentDomain(forName: "KVStoreTests.settingsStore.remove")
	let store = SettingsStore(defaults: defaults)
	_ = store.set("k", value: true)
	switch store.remove("k") {
	case .success: break
	case .failure(let errorInfo): Issue.record("remove failed: \(errorInfo.error)")
	}
	let getResult: CheckpointedResult<Bool?, KVStoreError> = store.get("k")
	switch getResult {
	case let .success(value, _):
		#expect(value == nil)
	case .failure:
		Issue.record("expected success(nil), got failure")
	}
}

// MARK: - SecureStoreTests

#if canImport(Security)

@Test
func secureStore_setThenGet_roundTrips() async throws {
	let store = SecureStore(service: "KVStoreTests.secureStore")
	let key = "roundTrip"
	_ = store.remove(key)
	switch store.set(key, value: "secret") {
	case .success: break
	case .failure(let errorInfo): Issue.record("set failed: \(errorInfo.error)")
	}
	let getResult: CheckpointedResult<String?, KVStoreError> = store.get(key)
	switch getResult {
	case let .success(value, _):
		#expect(value == "secret")
	case .failure(let errorInfo):
		Issue.record("get failed: \(errorInfo.error)")
	}
	_ = store.remove(key)
}

@Test
func secureStore_typeMismatch_returnsFailure() async throws {
	let store = SecureStore(service: "KVStoreTests.secureStore")
	let key = "typeMismatch"
	_ = store.remove(key)
	_ = store.set(key, value: Int64(100))
	let getResult: CheckpointedResult<Float?, KVStoreError> = store.get(key)
	switch getResult {
	case .success:
		Issue.record("expected typeMismatch failure")
	case .failure(let errorInfo):
		if case .typeMismatch(key: key, expected: _) = errorInfo.error { } else {
			Issue.record("expected .typeMismatch, got \(errorInfo.error)")
		}
	}
	_ = store.remove(key)
}

#endif
