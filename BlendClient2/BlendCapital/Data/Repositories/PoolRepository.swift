import Foundation
import Combine

/// Protocol for pool data repository
public protocol PoolRepositoryProtocol {
    /// Retrieves all available pools
    /// - Parameter cachePolicy: Cache policy to use
    /// - Returns: A publisher that emits an array of Pool objects or an error
    func getPools(cachePolicy: CachePolicy) -> AnyPublisher<[Pool], BlendError>
    
    /// Retrieves a specific pool by ID
    /// - Parameters:
    ///   - id: The unique identifier of the pool
    ///   - cachePolicy: Cache policy to use
    /// - Returns: A publisher that emits a Pool object or an error
    func getPool(id: String, cachePolicy: CachePolicy) -> AnyPublisher<Pool, BlendError>
    
    /// Retrieves detailed statistics for a specific pool
    /// - Parameters:
    ///   - id: The unique identifier of the pool
    ///   - cachePolicy: Cache policy to use
    /// - Returns: A publisher that emits a PoolStats object or an error
    func getPoolStats(id: String, cachePolicy: CachePolicy) -> AnyPublisher<PoolStats, BlendError>
    
    /// Retrieves all assets supported by a specific pool
    /// - Parameters:
    ///   - poolId: The unique identifier of the pool
    ///   - cachePolicy: Cache policy to use
    /// - Returns: A publisher that emits an array of Asset objects or an error
    func getPoolAssets(poolId: String, cachePolicy: CachePolicy) -> AnyPublisher<[Asset], BlendError>
    
    /// Retrieves a specific asset in a pool
    /// - Parameters:
    ///   - poolId: The unique identifier of the pool
    ///   - assetId: The unique identifier of the asset
    ///   - cachePolicy: Cache policy to use
    /// - Returns: A publisher that emits an Asset object or an error
    func getPoolAsset(poolId: String, assetId: String, cachePolicy: CachePolicy) -> AnyPublisher<Asset, BlendError>
} 