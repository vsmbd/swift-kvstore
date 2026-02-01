# Goals

## Strong typing
- String keys with generic value type at the call site
- Prevent type mismatches at compile time
- Make storage usage self-documenting

## Predictable behavior
- Scalar-only values
- Explicit encoding rules
- No silent failures
- All APIs return `CheckpointedResult<T, KVStoreError>`; `KVStoreError` conforms to `ErrorEntity` (SwiftCore) for structured error reporting

## Clear security boundaries
- Separate non-sensitive and sensitive storage
- Make secure storage explicit in code

## Small and focused API
- Minimal surface area
- Easy to audit and reason about

## Platform-aligned semantics
- Respect UserDefaults and Keychain behavior
- Avoid leaky abstractions over platform storage
