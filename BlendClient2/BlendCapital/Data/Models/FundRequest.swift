import Foundation

/// Represents a fund operation request in the Blend Capital protocol
public struct FundRequest: Equatable, Codable {
    /// The type of fund operation
    public let requestType: FundRequestType
    
    /// The asset ID or liquidatee address
    public let address: String
    
    /// The amount of the asset
    public let amount: Decimal
    
    /// The account ID of the user initiating the request
    public let accountId: String
    
    /// The pool ID where the operation will be performed
    public let poolId: String
    
    /// Optional memo for the transaction
    public let memo: String?
    
    /// Creates a new fund request
    /// - Parameters:
    ///   - requestType: The type of fund operation
    ///   - address: The asset ID or liquidatee address
    ///   - amount: The amount of the asset
    ///   - accountId: The account ID of the user initiating the request
    ///   - poolId: The pool ID where the operation will be performed
    ///   - memo: Optional memo for the transaction
    public init(
        requestType: FundRequestType,
        address: String,
        amount: Decimal,
        accountId: String,
        poolId: String,
        memo: String? = nil
    ) {
        self.requestType = requestType
        self.address = address
        self.amount = amount
        self.accountId = accountId
        self.poolId = poolId
        self.memo = memo
    }
}

/// Type of fund operation
public enum FundRequestType: Int, Equatable, Codable {
    /// Deposit funds without collateralization
    case deposit = 0
    
    /// Withdraw uncollateralized funds
    case withdraw = 1
    
    /// Deposit funds as collateral
    case depositCollateral = 2
    
    /// Withdraw collateral
    case withdrawCollateral = 3
    
    /// Borrow funds
    case borrow = 4
    
    /// Repay borrowed funds
    case repay = 5
    
    /// Human-readable description
    public var description: String {
        switch self {
        case .deposit:
            return "Deposit"
        case .withdraw:
            return "Withdraw"
        case .depositCollateral:
            return "Deposit Collateral"
        case .withdrawCollateral:
            return "Withdraw Collateral"
        case .borrow:
            return "Borrow"
        case .repay:
            return "Repay"
        }
    }
} 