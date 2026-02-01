# Non-goals

## No general persistence
- Not a database
- Not a document store
- Not a cache for large objects

## No unbounded values
- No nested dictionaries or arrays
- No arbitrary object graphs
- No Codable-via-Data for now

## No async APIs
- Storage is synchronous by design
- Callers control scheduling if needed

## No encryption abstraction
- SecureStore relies on platform Keychain
- No custom crypto layer

## No cross-device sync
- No iCloud or remote synchronization
