# KVStore

KVStore is a small, opinionated key–value storage abstraction for application settings and secrets.

It intentionally limits what can be stored in order to provide:
- predictable behavior
- strong typing
- clear security boundaries
- minimal runtime surprises

KVStore is designed for small values only. It is not a general persistence layer.

## Structure

The package provides:

- **KVStore** – Protocol defining the storage contract: string keys, one `get`/`set` overload per supported type (SwiftCore’s `ScalarValue` plus Data), and `remove(_ key: String)`. All APIs return `CheckpointedResult<T, KVStoreError>` from SwiftCore. The compiler picks the overload from the call site (return type or argument type), enforcing type safety at compile time.
- **SettingsStore** – UserDefaults-backed implementation for non-sensitive data.
- **SecureStore** – Keychain-backed implementation for secrets (Apple platforms only; conditionally compiled with `#if canImport(Security)`).
- **KVStoreError** – Error type conforming to `ErrorEntity` (SwiftCore) for structured reporting.

**Dependency:** SwiftCore (Swift 6; dependency is resolved from the `swift-core` package, e.g. via GitHub).

## Supported value types

KVStore supports the scalar types from SwiftCore’s `ScalarValue` plus Data:

- **String**, **Bool**, **Int64**, **UInt64**, **Double**, **Float**, **Data**

`get(_ key: String)` returns `CheckpointedResult<T?, KVStoreError>` (nil when the key is absent). `set(_ key: String, value: T)` and `remove(_ key: String)` return `CheckpointedResult<Void, KVStoreError>`.

Nested collections, dictionaries, and arbitrary Codable types are not supported.

## Stores

### SettingsStore

- **Backing:** UserDefaults (defaults to `.standard`; custom instance via `init(defaults:)`).
- **Use:** Non-sensitive configuration and flags.
- **Behavior:** Synchronous, fast; not encrypted. UserDefaults is thread-safe; `SettingsStore` is `Sendable` (unchecked, because `UserDefaults` is not marked Sendable by the system).

Typical use: feature flags, onboarding state, UI preferences, cached non-sensitive values.

### SecureStore

- **Backing:** Keychain (generic password items).
- **Use:** Secrets and credentials.
- **Behavior:** Values stored as encrypted Data by the platform; higher latency than SettingsStore. `SecureStore` is `Sendable`. Initializer: `init(service: String)` (service name identifies the Keychain group).

Typical use: auth tokens, refresh tokens, private identifiers, cryptographic material.

**Platform:** Available only when `Security` is available (Apple platforms). On other platforms the module compiles but `SecureStore` is not present.

## Errors

All store APIs return `CheckpointedResult<T, KVStoreError>`. `KVStoreError` conforms to `ErrorEntity` (Error, Sendable, Encodable) and has these cases:

- **keyNotFound(key: String)** – Key was not in the store.
- **typeMismatch(key: String, expected: String)** – Stored value could not be decoded as the requested type.
- **unsupportedType(typeName: String)** – Value type not supported by the store.
- **underlying(message: String)** – Underlying storage failure (e.g. UserDefaults/Keychain); message is for diagnostics.
- **keychainError(status: Int32)** – Keychain returned an OSStatus (Apple only).

## Platform support

- **Apple platforms:** Full support (SettingsStore + SecureStore).
- **Other platforms:** SettingsStore only; SecureStore is excluded at compile time.

## Intended usage

KVStore is intended for:
- application configuration
- lightweight state
- secure secret storage

It is not intended for large data, high-frequency bulk writes, or complex persistence (databases, document stores, generic caches).
