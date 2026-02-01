# KVStore

KVStore is a small, opinionated key–value storage abstraction for application settings and secrets.

It intentionally limits what can be stored in order to provide:
- predictable behavior
- strong typing
- clear security boundaries
- minimal runtime surprises

KVStore is designed for small values only. It is not a general persistence layer.

## Structure

KVStore consists of:
- a KVStore protocol defining the storage contract
- SettingsStore, backed by UserDefaults
- SecureStore, backed by Keychain

Each store uses string keys with generic value types and returns `CheckpointedResult<T, KVStoreError>` from SwiftCore.

## Core concepts

### Key: String with generic value

All access uses a string key and a generic value type:
- keys are strings (caller-defined; namespacing is up to the caller)
- the value type is generic at the call site for compile-time safety
- APIs return `CheckpointedResult<T, KVStoreError>`; `KVStoreError` conforms to `ErrorEntity` from SwiftCore

This keeps the key shape simple while preserving type safety and structured error reporting.

### Supported values

KVStore intentionally supports only:
- Bool
- Int
- UInt
- Double
- String
- Data
- Date

Codable-via-Data is not supported for now. Nested collections, dictionaries, and arbitrary objects are explicitly disallowed.

## Stores

### SettingsStore

- UserDefaults-backed
- Intended for non-sensitive configuration and flags
- Fast, synchronous access
- Not encrypted by default

Typical use cases:
- feature flags
- onboarding state
- UI preferences
- cached non-sensitive values

### SecureStore

- Keychain-backed
- Intended for secrets and credentials
- Stores values as encrypted Data
- Higher latency than SettingsStore

Typical use cases:
- auth tokens
- refresh tokens
- private identifiers
- cryptographic material

### Errors

- All store APIs return `CheckpointedResult<T, KVStoreError>` (from SwiftCore).
- `KVStoreError` is an enum conforming to `ErrorEntity` (Error, Sendable, Encodable) for structured reporting.

## Platform support

- Apple platforms: full support
- Non-Apple platforms: SecureStore is unavailable and fails at compile time

## Intended usage

KVStore is intended for:
- application configuration
- lightweight state
- secure secret storage

It is not intended for large data, high-frequency writes, or complex persistence needs.
