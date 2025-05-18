import Foundation

/// Represents a Blend Capital lending pool
public struct Pool: Identifiable, Equatable, Codable {
    /// Unique identifier of the pool
    public let id: String
    
    /// Human-readable name of the pool
    public let name: String
    
    /// Current status of the pool
    public let status: PoolStatus
    
    /// Total value supplied to the pool in USD
    public let totalSupplied: Decimal
    
    /// Total value borrowed from the pool in USD
    public let totalBorrowed: Decimal
    
    /// Total value in the backstop module in USD
    public let backstopAmount: Decimal
    
    /// Current utilization rate of the pool (borrowed/supplied)
    public let utilizationRate: Decimal
    
    /// Current yield (APY) for lenders
    public let currentYield: Decimal
    
    /// Timestamp of the last update
    public let lastUpdated: Date
    
    /// Creates a new pool
    /// - Parameters:
    ///   - id: Unique identifier
    ///   - name: Human-readable name
    ///   - status: Current status
    ///   - totalSupplied: Total supplied value
    ///   - totalBorrowed: Total borrowed value
    ///   - backstopAmount: Backstop amount
    ///   - utilizationRate: Utilization rate
    ///   - currentYield: Current yield
    ///   - lastUpdated: Last update timestamp
    public init(
        id: String,
        name: String,
        status: PoolStatus,
        totalSupplied: Decimal,
        totalBorrowed: Decimal,
        backstopAmount: Decimal,
        utilizationRate: Decimal,
        currentYield: Decimal,
        lastUpdated: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.status = status
        self.totalSupplied = totalSupplied
        self.totalBorrowed = totalBorrowed
        self.backstopAmount = backstopAmount
        self.utilizationRate = utilizationRate
        self.currentYield = currentYield
        self.lastUpdated = lastUpdated
    }
}

/// Represents detailed statistics for a Blend Capital lending pool
public struct PoolStats: Identifiable, Equatable, Codable {
    /// Unique identifier of the pool (same as Pool.id)
    public let id: String
    
    /// Current yield (APY) for lenders
    public let lendingAPY: Decimal
    
    /// Current interest rate for borrowers
    public let borrowingAPY: Decimal
    
    /// Current utilization rate of the pool (borrowed/supplied)
    public let utilizationRate: Decimal
    
    /// Total value supplied to the pool in USD
    public let totalSupplied: Decimal
    
    /// Total value borrowed from the pool in USD
    public let totalBorrowed: Decimal
    
    /// Total value in the backstop module in USD
    public let backstopAmount: Decimal
    
    /// Backstop take rate as a percentage
    public let backstopTakeRate: Decimal
    
    /// Maximum number of positions allowed per user
    public let maxPositions: Int
    
    /// Minimum collateral required in USD
    public let minCollateral: Decimal
    
    /// Statistics for each asset in the pool
    public let assetStats: [AssetStats]
    
    /// Timestamp of the last update
    public let lastUpdated: Date
    
    /// Creates new pool statistics
    /// - Parameters:
    ///   - id: Pool identifier
    ///   - lendingAPY: Lending APY
    ///   - borrowingAPY: Borrowing APY
    ///   - utilizationRate: Utilization rate
    ///   - totalSupplied: Total supplied
    ///   - totalBorrowed: Total borrowed
    ///   - backstopAmount: Backstop amount
    ///   - backstopTakeRate: Backstop take rate
    ///   - maxPositions: Maximum positions
    ///   - minCollateral: Minimum collateral
    ///   - assetStats: Asset statistics
    ///   - lastUpdated: Last update timestamp
    public init(
        id: String,
        lendingAPY: Decimal,
        borrowingAPY: Decimal,
        utilizationRate: Decimal,
        totalSupplied: Decimal,
        totalBorrowed: Decimal,
        backstopAmount: Decimal,
        backstopTakeRate: Decimal,
        maxPositions: Int,
        minCollateral: Decimal,
        assetStats: [AssetStats],
        lastUpdated: Date = Date()
    ) {
        self.id = id
        self.lendingAPY = lendingAPY
        self.borrowingAPY = borrowingAPY
        self.utilizationRate = utilizationRate
        self.totalSupplied = totalSupplied
        self.totalBorrowed = totalBorrowed
        self.backstopAmount = backstopAmount
        self.backstopTakeRate = backstopTakeRate
        self.maxPositions = maxPositions
        self.minCollateral = minCollateral
        self.assetStats = assetStats
        self.lastUpdated = lastUpdated
    }
}

/// Status of a Blend Capital pool
public enum PoolStatus: Int, Equatable, Codable {
    /// Pool is active and all operations are allowed
    case active = 0
    
    /// Pool is on ice, borrowing is disabled
    case onIce = 1
    
    /// Pool is frozen, deposit and borrowing are disabled
    case frozen = 3
    
    /// Pool is in setup, all operations are disabled
    case setup = 6
    
    /// Human-readable description
    public var description: String {
        switch self {
        case .active:
            return "Active"
        case .onIce:
            return "On Ice"
        case .frozen:
            return "Frozen"
        case .setup:
            return "Setup"
        }
    }
} 