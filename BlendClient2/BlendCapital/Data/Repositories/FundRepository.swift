import Foundation
import Combine

/// Protocol for fund operations repository
public protocol FundRepositoryProtocol {
    /// Deposit funds into a pool without collateralization
    /// - Parameters:
    ///   - accountId: The Stellar account ID of the user
    ///   - poolId: The unique identifier of the pool
    ///   - assetId: The asset to deposit
    ///   - amount: The amount to deposit
    /// - Returns: A publisher that emits a TransactionResult object or an error
    func deposit(accountId: String, poolId: String, assetId: String, amount: Decimal) -> AnyPublisher<TransactionResult, BlendError>
    
    /// Withdraw uncollateralized funds from a pool
    /// - Parameters:
    ///   - accountId: The Stellar account ID of the user
    ///   - poolId: The unique identifier of the pool
    ///   - assetId: The asset to withdraw
    ///   - amount: The amount to withdraw
    /// - Returns: A publisher that emits a TransactionResult object or an error
    func withdraw(accountId: String, poolId: String, assetId: String, amount: Decimal) -> AnyPublisher<TransactionResult, BlendError>
    
    /// Deposit funds as collateral into a pool
    /// - Parameters:
    ///   - accountId: The Stellar account ID of the user
    ///   - poolId: The unique identifier of the pool
    ///   - assetId: The asset to deposit
    ///   - amount: The amount to deposit
    /// - Returns: A publisher that emits a TransactionResult object or an error
    func depositCollateral(accountId: String, poolId: String, assetId: String, amount: Decimal) -> AnyPublisher<TransactionResult, BlendError>
    
    /// Withdraw collateral from a pool
    /// - Parameters:
    ///   - accountId: The Stellar account ID of the user
    ///   - poolId: The unique identifier of the pool
    ///   - assetId: The asset to withdraw
    ///   - amount: The amount to withdraw
    /// - Returns: A publisher that emits a TransactionResult object or an error
    func withdrawCollateral(accountId: String, poolId: String, assetId: String, amount: Decimal) -> AnyPublisher<TransactionResult, BlendError>
    
    /// Borrow funds from a pool
    /// - Parameters:
    ///   - accountId: The Stellar account ID of the user
    ///   - poolId: The unique identifier of the pool
    ///   - assetId: The asset to borrow
    ///   - amount: The amount to borrow
    /// - Returns: A publisher that emits a TransactionResult object or an error
    func borrow(accountId: String, poolId: String, assetId: String, amount: Decimal) -> AnyPublisher<TransactionResult, BlendError>
    
    /// Repay borrowed funds
    /// - Parameters:
    ///   - accountId: The Stellar account ID of the user
    ///   - poolId: The unique identifier of the pool
    ///   - assetId: The asset to repay
    ///   - amount: The amount to repay
    /// - Returns: A publisher that emits a TransactionResult object or an error
    func repay(accountId: String, poolId: String, assetId: String, amount: Decimal) -> AnyPublisher<TransactionResult, BlendError>
    
    /// Creates a fund request
    /// - Parameters:
    ///   - requestType: The type of fund operation
    ///   - accountId: The account ID of the user initiating the request
    ///   - poolId: The pool ID where the operation will be performed
    ///   - assetId: The asset ID to operate on
    ///   - amount: The amount of the asset
    /// - Returns: A FundRequest object
    func createFundRequest(
        requestType: FundRequestType,
        accountId: String,
        poolId: String,
        assetId: String,
        amount: Decimal
    ) -> FundRequest
    
    /// Submits a fund request
    /// - Parameter request: The fund request to submit
    /// - Returns: A publisher that emits a TransactionResult object or an error
    func submitRequest(request: FundRequest) -> AnyPublisher<TransactionResult, BlendError>
    
    /// Submits multiple fund requests in a single transaction
    /// - Parameter requests: The fund requests to submit
    /// - Returns: A publisher that emits a TransactionResult object or an error
    func submitRequests(requests: [FundRequest]) -> AnyPublisher<TransactionResult, BlendError>
} 