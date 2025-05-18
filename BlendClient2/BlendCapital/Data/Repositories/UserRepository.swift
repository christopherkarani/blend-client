import Foundation
import Combine

/// Protocol for user data repository
public protocol UserRepositoryProtocol {
    /// Retrieves all positions for a user across all pools
    /// - Parameters:
    ///   - accountId: The Stellar account ID of the user
    ///   - cachePolicy: Cache policy to use
    /// - Returns: A publisher that emits an array of UserPosition objects or an error
    func getUserPositions(accountId: String, cachePolicy: CachePolicy) -> AnyPublisher<[UserPosition], BlendError>
    
    /// Retrieves a user's position in a specific pool
    /// - Parameters:
    ///   - accountId: The Stellar account ID of the user
    ///   - poolId: The unique identifier of the pool
    ///   - cachePolicy: Cache policy to use
    /// - Returns: A publisher that emits a UserPosition object or an error
    func getUserPosition(accountId: String, poolId: String, cachePolicy: CachePolicy) -> AnyPublisher<UserPosition, BlendError>
    
    /// Calculates the health factor of a user's position
    /// - Parameter position: The user's position
    /// - Returns: The health factor as a Decimal
    func calculateHealthFactor(position: UserPosition) -> Decimal
    
    /// Calculates the yield earned by a user since deposit
    /// - Parameter position: The user's position
    /// - Returns: The yield earned as a Decimal
    func calculateYieldEarned(position: UserPosition) -> Decimal
    
    /// Retrieves the transaction history for a user in a specific pool
    /// - Parameters:
    ///   - accountId: The Stellar account ID of the user
    ///   - poolId: The unique identifier of the pool
    ///   - limit: Maximum number of transactions to retrieve (default: 20)
    ///   - offset: Offset for pagination (default: 0)
    ///   - cachePolicy: Cache policy to use
    /// - Returns: A publisher that emits an array of Transaction objects or an error
    func getTransactionHistory(
        accountId: String,
        poolId: String,
        limit: Int,
        offset: Int,
        cachePolicy: CachePolicy
    ) -> AnyPublisher<[Transaction], BlendError>
} 