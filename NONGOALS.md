# Non-goals

## No general persistence

- Not a database.
- Not a document store.
- Not a cache for large or arbitrary objects.

## No unbounded value types

- No nested dictionaries or arrays.
- No arbitrary object graphs or generic Codable encoding.
- Only the fixed set is supported: SwiftCore’s `ScalarValue` (String, Bool, Int64, UInt64, Double, Float) plus Data.

## No async APIs

- Storage is synchronous by design.
- Callers can wrap calls in async or background queues if needed.

## No encryption abstraction

- SecureStore relies on the platform Keychain for encryption and protection.
- No custom crypto layer or pluggable backends.

## No cross-device or remote sync

- No iCloud, CloudKit, or remote synchronization.
- Each store is local to the process/device.
