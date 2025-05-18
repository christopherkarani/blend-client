import Foundation
import Combine

/// Protocol for pool statistics service
public protocol PoolStatsServiceProtocol {
    /// Retrieves statistics for a specific pool
    /// - Parameters:
    ///   - poolId: The pool ID
    ///   - cachePolicy: Cache policy to use
    /// - Returns: A publisher that emits pool statistics or an error
    func getPoolStats(poolId: String, cachePolicy: CachePolicy) -> AnyPublisher<PoolStats, BlendError>
    
    /// Calculates yield for a pool
    /// - Parameter pool: The pool
    /// - Returns: The calculated yield
    func calculateYield(pool: Pool) -> Decimal
    
    /// Calculates utilization rate for a pool
    /// - Parameter pool: The pool
    /// - Returns: The calculated utilization rate
    func calculateUtilizationRate(pool: Pool) -> Decimal
} 