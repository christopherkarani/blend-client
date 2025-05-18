import Foundation
import Combine

/// Protocol for account manager service
public protocol AccountManagerServiceProtocol {
    /// Retrieves a user's position in a specific pool
    /// - Parameters:
    ///   - accountId: The user's account ID
    ///   - poolId: The pool ID
    ///   - cachePolicy: Cache policy to use
    /// - Returns: A publisher that emits a user position or an error
    func getUserPosition(accountId: String, poolId: String, cachePolicy: CachePolicy) -> AnyPublisher<UserPosition, BlendError>
    
    /// Retrieves all positions for a user across all pools
    /// - Parameters:
    ///   - accountId: The user's account ID
    ///   - cachePolicy: Cache policy to use
    /// - Returns: A publisher that emits an array of user positions or an error
    func getUserPositions(accountId: String, cachePolicy: CachePolicy) -> AnyPublisher<[UserPosition], BlendError>
    
    /// Calculates health factor for a user position
    /// - Parameter position: The user position
    /// - Returns: The calculated health factor
    func calculateHealthFactor(position: UserPosition) -> Decimal
    
    /// Calculates yield earned for a user position
    /// - Parameter position: The user position
    /// - Returns: The calculated yield earned
    func calculateYieldEarned(position: UserPosition) -> Decimal
    
    /// Retrieves transaction history for a user in a specific pool
    /// - Parameters:
    ///   - accountId: The user's account ID
    ///   - poolId: The pool ID
    ///   - limit: Maximum number of transactions to retrieve
    ///   - offset: Offset for pagination
    ///   - cachePolicy: Cache policy to use
    /// - Returns: A publisher that emits an array of transactions or an error
    func getTransactionHistory(
        accountId: String,
        poolId: String,
        limit: Int,
        offset: Int,
        cachePolicy: CachePolicy
    ) -> AnyPublisher<[Transaction], BlendError>
} 