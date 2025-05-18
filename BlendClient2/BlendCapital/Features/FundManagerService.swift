import Foundation
import Combine

/// Protocol for fund manager service
public protocol FundManagerServiceProtocol {
    /// Creates a deposit request
    /// - Parameters:
    ///   - accountId: The account ID of the user
    ///   - poolId: The pool ID
    ///   - assetId: The asset ID
    ///   - amount: The amount to deposit
    /// - Returns: A fund request
    func createDepositRequest(accountId: String, poolId: String, assetId: String, amount: Decimal) -> FundRequest
    
    /// Creates a withdraw request
    /// - Parameters:
    ///   - accountId: The account ID of the user
    ///   - poolId: The pool ID
    ///   - assetId: The asset ID
    ///   - amount: The amount to withdraw
    /// - Returns: A fund request
    func createWithdrawRequest(accountId: String, poolId: String, assetId: String, amount: Decimal) -> FundRequest
    
    /// Creates a deposit collateral request
    /// - Parameters:
    ///   - accountId: The account ID of the user
    ///   - poolId: The pool ID
    ///   - assetId: The asset ID
    ///   - amount: The amount to deposit as collateral
    /// - Returns: A fund request
    func createDepositCollateralRequest(accountId: String, poolId: String, assetId: String, amount: Decimal) -> FundRequest
    
    /// Creates a withdraw collateral request
    /// - Parameters:
    ///   - accountId: The account ID of the user
    ///   - poolId: The pool ID
    ///   - assetId: The asset ID
    ///   - amount: The amount to withdraw from collateral
    /// - Returns: A fund request
    func createWithdrawCollateralRequest(accountId: String, poolId: String, assetId: String, amount: Decimal) -> FundRequest
    
    /// Creates a borrow request
    /// - Parameters:
    ///   - accountId: The account ID of the user
    ///   - poolId: The pool ID
    ///   - assetId: The asset ID
    ///   - amount: The amount to borrow
    /// - Returns: A fund request
    func createBorrowRequest(accountId: String, poolId: String, assetId: String, amount: Decimal) -> FundRequest
    
    /// Creates a repay request
    /// - Parameters:
    ///   - accountId: The account ID of the user
    ///   - poolId: The pool ID
    ///   - assetId: The asset ID
    ///   - amount: The amount to repay
    /// - Returns: A fund request
    func createRepayRequest(accountId: String, poolId: String, assetId: String, amount: Decimal) -> FundRequest
    
    /// Submits a fund request
    /// - Parameter request: The fund request to submit
    /// - Returns: A publisher that emits a transaction result or an error
    func submitRequest(request: FundRequest) -> AnyPublisher<TransactionResult, BlendError>
    
    /// Submits multiple fund requests in a single transaction
    /// - Parameter requests: The fund requests to submit
    /// - Returns: A publisher that emits a transaction result or an error
    func submitRequests(requests: [FundRequest]) -> AnyPublisher<TransactionResult, BlendError>
    
    /// Validates a fund request against current pool status
    /// - Parameter request: The fund request to validate
    /// - Returns: A success result or an error
    func validateRequest(_ request: FundRequest) -> AnyPublisher<Void, BlendError>
} 