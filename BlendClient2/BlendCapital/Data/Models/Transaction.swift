import Foundation

/// Represents a transaction in the Blend Capital protocol
public struct Transaction: Identifiable, Equatable, Codable {
    /// Unique identifier of the transaction
    public let id: String
    
    /// Stellar account ID of the user
    public let accountId: String
    
    /// Pool ID where the transaction occurred
    public let poolId: String
    
    /// Asset ID involved in the transaction
    public let assetId: String
    
    /// Type of the transaction
    public let type: TransactionType
    
    /// Amount of the asset
    public let amount: Decimal
    
    /// Value of the transaction in USD
    public let value: Decimal
    
    /// Transaction hash on the Stellar network
    public let transactionHash: String
    
    /// Date of the transaction
    public let date: Date
    
    /// Creates a new transaction
    /// - Parameters:
    ///   - id: Transaction ID
    ///   - accountId: User account ID
    ///   - poolId: Pool ID
    ///   - assetId: Asset ID
    ///   - type: Transaction type
    ///   - amount: Asset amount
    ///   - value: USD value
    ///   - transactionHash: Transaction hash
    ///   - date: Transaction date
    public init(
        id: String,
        accountId: String,
        poolId: String,
        assetId: String,
        type: TransactionType,
        amount: Decimal,
        value: Decimal,
        transactionHash: String,
        date: Date
    ) {
        self.id = id
        self.accountId = accountId
        self.poolId = poolId
        self.assetId = assetId
        self.type = type
        self.amount = amount
        self.value = value
        self.transactionHash = transactionHash
        self.date = date
    }
}

/// Type of transaction
public enum TransactionType: String, Equatable, Codable {
    /// Deposit funds without collateralization
    case deposit
    
    /// Withdraw uncollateralized funds
    case withdraw
    
    /// Deposit funds as collateral
    case depositCollateral
    
    /// Withdraw collateral
    case withdrawCollateral
    
    /// Borrow funds
    case borrow
    
    /// Repay borrowed funds
    case repay
    
    /// Liquidation of a position
    case liquidation
}

/// Result of a transaction submission
public struct TransactionResult: Equatable, Codable {
    /// Whether the transaction was successful
    public let success: Bool
    
    /// The transaction hash on the Stellar network
    public let transactionHash: String
    
    /// The ledger where the transaction was included
    public let ledger: UInt64
    
    /// The date and time when the transaction was created
    public let createdAt: Date
    
    /// The XDR representation of the transaction result
    public let resultXDR: String
    
    /// Optional error message if the transaction failed
    public let errorMessage: String?
    
    /// Creates a new transaction result
    /// - Parameters:
    ///   - success: Whether successful
    ///   - transactionHash: Transaction hash
    ///   - ledger: Ledger number
    ///   - createdAt: Creation timestamp
    ///   - resultXDR: Result XDR
    ///   - errorMessage: Optional error message
    public init(
        success: Bool,
        transactionHash: String,
        ledger: UInt64,
        createdAt: Date,
        resultXDR: String,
        errorMessage: String? = nil
    ) {
        self.success = success
        self.transactionHash = transactionHash
        self.ledger = ledger
        self.createdAt = createdAt
        self.resultXDR = resultXDR
        self.errorMessage = errorMessage
    }
} 