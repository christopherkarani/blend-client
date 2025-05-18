import Foundation

/// Cache policy for data retrieval
public enum CachePolicy {
    /// Don't use cache, always fetch from source
    case noCache
    
    /// Use cache if available and not expired, otherwise fetch from source
    case useCache(ttl: TimeInterval? = nil)
    
    /// Force refresh cache, fetch from source and update cache
    case refreshCache
}

/// Protocol for cache storage
public protocol CacheStorageProtocol {
    /// Gets a value of type T from cache
    /// - Parameter key: Cache key
    /// - Returns: Cached value if exists and is of type T, nil otherwise
    func get<T: Decodable>(key: String) -> T?
    
    /// Sets a value in cache with a TTL
    /// - Parameters:
    ///   - key: Cache key
    ///   - value: Value to cache
    ///   - ttl: Time-to-live in seconds
    func set<T: Encodable>(key: String, value: T, ttl: TimeInterval)
    
    /// Removes a value from cache
    /// - Parameter key: Cache key
    func remove(key: String)
    
    /// Clears all cached values
    func clear()
    
    /// Checks if a key exists in cache and is not expired
    /// - Parameter key: Cache key
    /// - Returns: True if key exists and is not expired, false otherwise
    func isValid(key: String) -> Bool
}

/// In-memory implementation of CacheStorage
public class InMemoryCacheStorage: CacheStorageProtocol {
    /// Cached item with expiration
    private struct CachedItem {
        let value: Any
        let expiresAt: Date
        
        var isExpired: Bool {
            Date() > expiresAt
        }
    }
    
    /// Dictionary of cached items
    private var cache: [String: CachedItem] = [:]
    
    /// Creates a new in-memory cache storage
    public init() {}
    
    /// Gets a value of type T from cache
    public func get<T: Decodable>(key: String) -> T? {
        guard let cachedItem = cache[key], !cachedItem.isExpired else {
            return nil
        }
        
        return cachedItem.value as? T
    }
    
    /// Sets a value in cache with a TTL
    public func set<T: Encodable>(key: String, value: T, ttl: TimeInterval) {
        let expiresAt = Date().addingTimeInterval(ttl)
        let cachedItem = CachedItem(value: value, expiresAt: expiresAt)
        cache[key] = cachedItem
    }
    
    /// Removes a value from cache
    public func remove(key: String) {
        cache.removeValue(forKey: key)
    }
    
    /// Clears all cached values
    public func clear() {
        cache.removeAll()
    }
    
    /// Checks if a key exists in cache and is not expired
    public func isValid(key: String) -> Bool {
        guard let cachedItem = cache[key] else {
            return false
        }
        
        return !cachedItem.isExpired
    }
} 