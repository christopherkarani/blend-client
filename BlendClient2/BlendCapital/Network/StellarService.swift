import Foundation
import Combine

/// Protocol for Stellar network service
public protocol StellarServiceProtocol {
    /// Retrieves account information
    /// - Parameter accountId: The Stellar account ID
    /// - Returns: A publisher that emits an Account object or an error
    func getAccount(accountId: String) -> AnyPublisher<StellarAccount, BlendError>
    
    /// Submits a transaction to the Stellar network
    /// - Parameter transaction: The transaction to submit
    /// - Returns: A publisher that emits a TransactionResult object or an error
    func submitTransaction(transaction: StellarTransaction) -> AnyPublisher<TransactionResult, BlendError>
    
    /// Checks if an account exists
    /// - Parameter accountId: The Stellar account ID to check
    /// - Returns: A publisher that emits a boolean or an error
    func accountExists(accountId: String) -> AnyPublisher<Bool, BlendError>
    
    /// Retrieves the current sequence number for an account
    /// - Parameter accountId: The Stellar account ID
    /// - Returns: A publisher that emits a sequence number or an error
    func getSequenceNumber(accountId: String) -> AnyPublisher<UInt64, BlendError>
    
    /// Retrieves recent transaction history for an account
    /// - Parameters:
    ///   - accountId: The Stellar account ID
    ///   - limit: Maximum number of transactions to retrieve (default: -1)
    /// - Returns: A publisher that emits an array of transaction records or an error
    func getTransactionHistory(accountId: String, limit: Int) -> AnyPublisher<[StellarTransactionRecord], BlendError>
}

/// Placeholder for Stellar account information
public struct StellarAccount: Equatable, Codable {
    /// Account ID
    public let id: String
    
    /// Sequence number
    public let sequenceNumber: UInt64
    
    /// Balances
    public let balances: [StellarBalance]
    
    /// Creates a new Stellar account
    /// - Parameters:
    ///   - id: Account ID
    ///   - sequenceNumber: Sequence number
    ///   - balances: Balances
    public init(id: String, sequenceNumber: UInt64, balances: [StellarBalance]) {
        self.id = id
        self.sequenceNumber = sequenceNumber
        self.balances = balances
    }
}

/// Placeholder for Stellar balance information
public struct StellarBalance: Equatable, Codable {
    /// Asset code
    public let assetCode: String
    
    /// Asset issuer (empty for native asset)
    public let assetIssuer: String
    
    /// Balance amount
    public let balance: Decimal
    
    /// Creates a new Stellar balance
    /// - Parameters:
    ///   - assetCode: Asset code
    ///   - assetIssuer: Asset issuer
    ///   - balance: Balance amount
    public init(assetCode: String, assetIssuer: String, balance: Decimal) {
        self.assetCode = assetCode
        self.assetIssuer = assetIssuer
        self.balance = balance
    }
}

/// Placeholder for Stellar transaction
public struct StellarTransaction: Equatable, Codable {
    /// Transaction envelope XDR
    public let envelopeXDR: String
    
    /// Creates a new Stellar transaction
    /// - Parameter envelopeXDR: Transaction envelope XDR
    public init(envelopeXDR: String) {
        self.envelopeXDR = envelopeXDR
    }
}

/// Placeholder for Stellar transaction record
public struct StellarTransactionRecord: Identifiable, Equatable, Codable {
    /// Transaction ID
    public let id: String
    
    /// Transaction hash
    public let hash: String
    
    /// Ledger sequence
    public let ledger: UInt64
    
    /// Creation date
    public let createdAt: Date
    
    /// Transaction envelope XDR
    public let envelopeXDR: String
    
    /// Result XDR
    public let resultXDR: String
    
    /// Creates a new Stellar transaction record
    /// - Parameters:
    ///   - id: Transaction ID
    ///   - hash: Transaction hash
    ///   - ledger: Ledger sequence
    ///   - createdAt: Creation date
    ///   - envelopeXDR: Envelope XDR
    ///   - resultXDR: Result XDR
    public init(id: String, hash: String, ledger: UInt64, createdAt: Date, envelopeXDR: String, resultXDR: String) {
        self.id = id
        self.hash = hash
        self.ledger = ledger
        self.createdAt = createdAt
        self.envelopeXDR = envelopeXDR
        self.resultXDR = resultXDR
    }
} 