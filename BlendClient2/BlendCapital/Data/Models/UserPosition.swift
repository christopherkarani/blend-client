import Foundation

/// Represents a user's position in a Blend Capital pool
public struct UserPosition: Identifiable, Equatable, Codable {
    /// Unique identifier of the position (combination of accountId and poolId)
    public let id: String
    
    /// Stellar account ID of the user
    public let accountId: String
    
    /// Pool ID where the position is held
    public let poolId: String
    
    /// Collateral positions (assets used as collateral)
    public let collateralPositions: [AssetPosition]
    
    /// Borrow positions (assets borrowed)
    public let borrowPositions: [AssetPosition]
    
    /// Deposit positions (assets deposited but not used as collateral)
    public let depositPositions: [AssetPosition]
    
    /// Health factor of the position (>1 is healthy, <1 is at risk of liquidation)
    public let healthFactor: Decimal
    
    /// Total yield earned since deposit
    public let yieldEarned: Decimal
    
    /// Date of the initial deposit
    public let depositDate: Date
    
    /// Date of the last update
    public let lastUpdated: Date
    
    /// Creates a new user position
    /// - Parameters:
    ///   - accountId: User account ID
    ///   - poolId: Pool ID
    ///   - collateralPositions: Collateral positions
    ///   - borrowPositions: Borrow positions
    ///   - depositPositions: Deposit positions
    ///   - healthFactor: Health factor
    ///   - yieldEarned: Yield earned
    ///   - depositDate: Initial deposit date
    ///   - lastUpdated: Last update date
    public init(
        accountId: String,
        poolId: String,
        collateralPositions: [AssetPosition],
        borrowPositions: [AssetPosition],
        depositPositions: [AssetPosition],
        healthFactor: Decimal,
        yieldEarned: Decimal,
        depositDate: Date,
        lastUpdated: Date = Date()
    ) {
        self.id = "\(accountId)-\(poolId)"
        self.accountId = accountId
        self.poolId = poolId
        self.collateralPositions = collateralPositions
        self.borrowPositions = borrowPositions
        self.depositPositions = depositPositions
        self.healthFactor = healthFactor
        self.yieldEarned = yieldEarned
        self.depositDate = depositDate
        self.lastUpdated = lastUpdated
    }
    
    /// Computed property for total collateral value in USD
    public var totalCollateralValue: Decimal {
        collateralPositions.reduce(0) { $0 + $1.value }
    }
    
    /// Computed property for total borrowed value in USD
    public var totalBorrowedValue: Decimal {
        borrowPositions.reduce(0) { $0 + $1.value }
    }
    
    /// Computed property for total deposit value in USD
    public var totalDepositValue: Decimal {
        depositPositions.reduce(0) { $0 + $1.value }
    }
    
    /// Computed property for total position value in USD
    public var totalPositionValue: Decimal {
        totalCollateralValue + totalDepositValue - totalBorrowedValue
    }
}

/// Represents a position in a specific asset
public struct AssetPosition: Identifiable, Equatable, Codable {
    /// Unique identifier of the position
    public let id: String
    
    /// Asset ID
    public let assetId: String
    
    /// Asset code (e.g., "XLM", "USDC")
    public let code: String
    
    /// Amount of the asset
    public let amount: Decimal
    
    /// Value of the position in USD
    public let value: Decimal
    
    /// Type of the position
    public let type: AssetPositionType
    
    /// Date of the last update
    public let lastUpdated: Date
    
    /// Creates a new asset position
    /// - Parameters:
    ///   - assetId: Asset ID
    ///   - code: Asset code
    ///   - amount: Asset amount
    ///   - value: USD value
    ///   - type: Position type
    ///   - lastUpdated: Last update date
    public init(
        assetId: String,
        code: String,
        amount: Decimal,
        value: Decimal,
        type: AssetPositionType,
        lastUpdated: Date = Date()
    ) {
        self.id = "\(assetId)-\(type.rawValue)"
        self.assetId = assetId
        self.code = code
        self.amount = amount
        self.value = value
        self.type = type
        self.lastUpdated = lastUpdated
    }
}

/// Type of asset position
public enum AssetPositionType: String, Equatable, Codable {
    /// Asset used as collateral
    case collateral
    
    /// Asset borrowed
    case borrow
    
    /// Asset deposited but not used as collateral
    case deposit
} 