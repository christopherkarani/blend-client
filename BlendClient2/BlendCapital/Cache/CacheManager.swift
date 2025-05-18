import Foundation
import Combine

/// Protocol for cache manager
public protocol CacheManagerProtocol {
    /// Wraps a publisher with caching logic
    /// - Parameters:
    ///   - publisher: Original publisher
    ///   - key: Cache key
    ///   - ttl: Time-to-live in seconds
    /// - Returns: Publisher with caching logic
    func withCache<T: Codable>(_ publisher: AnyPublisher<T, Error>, key: String, ttl: TimeInterval?) -> AnyPublisher<T, Error>
    
    /// Invalidates a specific cache entry
    /// - Parameter key: Cache key
    func invalidate(key: String)
    
    /// Invalidates all cache entries
    func invalidateAll()
}

/// Implementation of cache manager
public class CacheManager: CacheManagerProtocol {
    /// Storage for cached values
    private let storage: CacheStorageProtocol
    
    /// Creates a new cache manager
    /// - Parameter storage: Storage implementation
    public init(storage: CacheStorageProtocol) {
        self.storage = storage
    }
    
    /// Wraps a publisher with caching logic
    public func withCache<T: Codable>(_ publisher: AnyPublisher<T, Error>, key: String, ttl: TimeInterval?) -> AnyPublisher<T, Error> {
        if let ttl = ttl, let cachedValue: T = storage.get(key: key) {
            return Just(cachedValue)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        return publisher
            .handleEvents(receiveOutput: { [weak self] value in
                if let ttl = ttl {
                    self?.storage.set(key: key, value: value, ttl: ttl)
                }
            })
            .eraseToAnyPublisher()
    }
    
    /// Invalidates a specific cache entry
    public func invalidate(key: String) {
        storage.remove(key: key)
    }
    
    /// Invalidates all cache entries
    public func invalidateAll() {
        storage.clear()
    }
    
    /// Applies cache policy to a publisher
    /// - Parameters:
    ///   - publisher: Original publisher
    ///   - key: Cache key
    ///   - policy: Cache policy
    ///   - defaultTTL: Default time-to-live
    /// - Returns: Publisher with caching policy applied
    public func applyCachePolicy<T: Codable>(
        _ publisher: AnyPublisher<T, Error>,
        key: String,
        policy: CachePolicy,
        defaultTTL: TimeInterval
    ) -> AnyPublisher<T, Error> {
        switch policy {
        case .noCache:
            return publisher
                
        case .useCache(let ttl):
            let effectiveTTL = ttl ?? defaultTTL
            return self.withCache(publisher, key: key, ttl: effectiveTTL)
                
        case .refreshCache:
            invalidate(key: key)
            return publisher
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.storage.set(key: key, value: value, ttl: defaultTTL)
                })
                .eraseToAnyPublisher()
        }
    }
} 