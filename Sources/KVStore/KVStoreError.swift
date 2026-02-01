//
//  KVStoreError.swift
//  KVStore
//
//  Created by vsmbd on 01/02/26.
//

import Foundation
import SwiftCore

// MARK: - KVStoreError

/// Structured errors for KVStore operations. Conforms to `ErrorEntity` for use with `CheckpointedResult` and structured reporting.
public enum KVStoreError: ErrorEntity {
	/// The key was not found in the store.
	case keyNotFound(key: String)
	/// The stored value could not be decoded as the requested type.
	case typeMismatch(
		key: String,
		expected: String
	)
	/// The value type is not supported by this store.
	case unsupportedType(typeName: String)
	/// Underlying storage error (e.g. UserDefaults/Keychain failure). Message is for diagnostics.
	case underlying(message: String)
#if canImport(Security)
	/// Keychain returned an OSStatus error.
	case keychainError(status: Int32)
#endif
}

// MARK: - KVStoreError + Encodable

extension KVStoreError: Encodable {
	// MARK: + Private scope

	private enum CodingKeys: String,
							 CodingKey {
		case kind
		case key
		case expected
		case typeName
		case message
		case status
	}

	private static let kindKeyNotFound = "keyNotFound"
	private static let kindTypeMismatch = "typeMismatch"
	private static let kindUnsupportedType = "unsupportedType"
	private static let kindUnderlying = "underlying"
	private static let kindKeychainError = "keychainError"

	// MARK: + Public scope

	public func encode(to encoder: Encoder) throws {
		var container = encoder
			.container(keyedBy: CodingKeys.self)

		switch self {
		case let .keyNotFound(key: key):
			try container.encode(
				Self.kindKeyNotFound,
				forKey: .kind
			)
			try container.encode(
				key,
				forKey: .key
			)

		case let .typeMismatch(
			key: key,
			expected: expected
		):
			try container.encode(
				Self.kindTypeMismatch,
				forKey: .kind
			)
			try container.encode(
				key,
				forKey: .key
			)
			try container.encode(
				expected,
				forKey: .expected
			)

		case let .unsupportedType(typeName: typeName):
			try container.encode(
				Self.kindUnsupportedType,
				forKey: .kind
			)
			try container.encode(
				typeName,
				forKey: .typeName
			)

		case let .underlying(message: message):
			try container.encode(
				Self.kindUnderlying,
				forKey: .kind
			)
			try container.encode(
				message,
				forKey: .message
			)

#if canImport(Security)
		case let .keychainError(status: status):
			try container.encode(
				Self.kindKeychainError,
				forKey: .kind
			)
			try container.encode(
				status,
				forKey: .status
			)
#endif
		}
	}
}
