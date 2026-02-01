# Goals

## Strong typing

- String keys with one `get`/`set` overload per supported type: SwiftCore’s `ScalarValue` (String, Bool, Int64, UInt64, Double, Float) plus Data.
- Overload resolution at the call site (return type or argument type) so type mismatches are caught at compile time.
- Storage usage is self-documenting from the call site.

## Predictable behavior

- Scalar-only values; no nested collections or arbitrary Codable.
- Explicit encoding rules (Keychain format is internal; API is typed).
- No silent type coercion at the API boundary; mismatches surface as `KVStoreError.typeMismatch`.
- All APIs return `CheckpointedResult<T, KVStoreError>`; `KVStoreError` conforms to `ErrorEntity` (SwiftCore) for structured error reporting.

## Clear security boundaries

- Separate non-sensitive storage (SettingsStore / UserDefaults) and sensitive storage (SecureStore / Keychain).
- Use of secure storage is explicit in code (choice of store type and API).

## Small and focused API

- Protocol: `get(_ key: String)` (overloaded by return type), `set(_ key: String, value:)` (overloaded by value type), `remove(_ key: String)`.
- Minimal surface area; easy to audit and reason about.

## Platform-aligned semantics

- Respect UserDefaults and Keychain behavior; no abstraction over their semantics.
- Avoid leaky wrappers (e.g. no hidden async, no custom crypto layer).
