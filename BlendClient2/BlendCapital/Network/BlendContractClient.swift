import Foundation
import Combine

/// Protocol for Blend Capital contract client
public protocol BlendContractClientProtocol {
    /// Retrieves data for a specific pool
    /// - Parameter poolId: The pool ID
    /// - Returns: A publisher that emits a PoolData object or an error
    func getPoolData(poolId: String) -> AnyPublisher<PoolData, BlendError>
    
    /// Retrieves a user's position data in a specific pool
    /// - Parameters:
    ///   - accountId: The user's account ID
    ///   - poolId: The pool ID
    /// - Returns: A publisher that emits a UserPositionData object or an error
    func getUserPositionData(accountId: String, poolId: String) -> AnyPublisher<UserPositionData, BlendError>
    
    /// Submits a fund request
    /// - Parameter request: The fund request to submit
    /// - Returns: A publisher that emits a TransactionResult object or an error
    func submitFundRequest(request: FundRequest) -> AnyPublisher<TransactionResult, BlendError>
    
    /// Submits multiple fund requests in a single transaction
    /// - Parameter requests: The fund requests to submit
    /// - Returns: A publisher that emits a TransactionResult object or an error
    func submitFundRequests(requests: [FundRequest]) -> AnyPublisher<TransactionResult, BlendError>
}

/// Raw pool data from contract
public struct PoolData: Equatable, Codable {
    /// Pool status
    public let status: UInt32
    
    /// Total supplied value in base units
    public let totalSupplied: UInt64
    
    /// Total borrowed value in base units
    public let totalBorrowed: UInt64
    
    /// Backstop amount in base units
    public let backstopAmount: UInt64
    
    /// Backstop take rate
    public let backstopTakeRate: UInt32
    
    /// Maximum positions per user
    public let maxPositions: UInt32
    
    /// Minimum collateral in base units
    public let minCollateral: UInt64
    
    /// Assets in the pool
    public let assets: [AssetData]
    
    /// Reserve data
    public let reserve: ReserveData
    
    /// Creates new pool data
    /// - Parameters:
    ///   - status: Pool status
    ///   - totalSupplied: Total supplied
    ///   - totalBorrowed: Total borrowed
    ///   - backstopAmount: Backstop amount
    ///   - backstopTakeRate: Backstop take rate
    ///   - maxPositions: Maximum positions
    ///   - minCollateral: Minimum collateral
    ///   - assets: Assets data
    ///   - reserve: Reserve data
    public init(
        status: UInt32,
        totalSupplied: UInt64,
        totalBorrowed: UInt64,
        backstopAmount: UInt64,
        backstopTakeRate: UInt32,
        maxPositions: UInt32,
        minCollateral: UInt64,
        assets: [AssetData],
        reserve: ReserveData
    ) {
        self.status = status
        self.totalSupplied = totalSupplied
        self.totalBorrowed = totalBorrowed
        self.backstopAmount = backstopAmount
        self.backstopTakeRate = backstopTakeRate
        self.maxPositions = maxPositions
        self.minCollateral = minCollateral
        self.assets = assets
        self.reserve = reserve
    }
}

/// Raw asset data from contract
public struct AssetData: Equatable, Codable {
    /// Asset ID
    public let id: String
    
    /// Asset decimals
    public let decimals: UInt32
    
    /// Asset price in base units
    public let price: UInt64
    
    /// Collateral factor as a percentage
    public let collateralFactor: UInt32
    
    /// Liability factor as a percentage
    public let liabilityFactor: UInt32
    
    /// Total supplied amount in asset units
    public let supplied: UInt64
    
    /// Total borrowed amount in asset units
    public let borrowed: UInt64
    
    /// Creates new asset data
    /// - Parameters:
    ///   - id: Asset ID
    ///   - decimals: Decimals
    ///   - price: Price
    ///   - collateralFactor: Collateral factor
    ///   - liabilityFactor: Liability factor
    ///   - supplied: Supplied amount
    ///   - borrowed: Borrowed amount
    public init(
        id: String,
        decimals: UInt32,
        price: UInt64,
        collateralFactor: UInt32,
        liabilityFactor: UInt32,
        supplied: UInt64,
        borrowed: UInt64
    ) {
        self.id = id
        self.decimals = decimals
        self.price = price
        self.collateralFactor = collateralFactor
        self.liabilityFactor = liabilityFactor
        self.supplied = supplied
        self.borrowed = borrowed
    }
}

/// Raw reserve data from contract
public struct ReserveData: Equatable, Codable {
    /// Base rate
    public let baseRate: UInt64
    
    /// Optimal rate
    public let optimalRate: UInt64
    
    /// Interest rate modifier
    public let irMod: UInt64
    
    /// Utilization rate
    public let util: UInt64
    
    /// Backstop take rate
    public let backstopTakeRate: UInt64
    
    /// Creates new reserve data
    /// - Parameters:
    ///   - baseRate: Base rate
    ///   - optimalRate: Optimal rate
    ///   - irMod: Interest rate modifier
    ///   - util: Utilization rate
    ///   - backstopTakeRate: Backstop take rate
    public init(
        baseRate: UInt64,
        optimalRate: UInt64,
        irMod: UInt64,
        util: UInt64,
        backstopTakeRate: UInt64
    ) {
        self.baseRate = baseRate
        self.optimalRate = optimalRate
        self.irMod = irMod
        self.util = util
        self.backstopTakeRate = backstopTakeRate
    }
}

/// Raw user position data from contract
public struct UserPositionData: Equatable, Codable {
    /// Account ID
    public let accountId: String
    
    /// Pool ID
    public let poolId: String
    
    /// Collateral positions
    public let collateralPositions: [AssetPositionData]
    
    /// Borrow positions
    public let borrowPositions: [AssetPositionData]
    
    /// Deposit positions
    public let depositPositions: [AssetPositionData]
    
    /// Deposit date as timestamp
    public let depositDate: UInt64
    
    /// Creates new user position data
    /// - Parameters:
    ///   - accountId: Account ID
    ///   - poolId: Pool ID
    ///   - collateralPositions: Collateral positions
    ///   - borrowPositions: Borrow positions
    ///   - depositPositions: Deposit positions
    ///   - depositDate: Deposit date
    public init(
        accountId: String,
        poolId: String,
        collateralPositions: [AssetPositionData],
        borrowPositions: [AssetPositionData],
        depositPositions: [AssetPositionData],
        depositDate: UInt64
    ) {
        self.accountId = accountId
        self.poolId = poolId
        self.collateralPositions = collateralPositions
        self.borrowPositions = borrowPositions
        self.depositPositions = depositPositions
        self.depositDate = depositDate
    }
}

/// Raw asset position data from contract
public struct AssetPositionData: Equatable, Codable {
    /// Asset ID
    public let assetId: String
    
    /// Amount in asset units
    public let amount: UInt64
    
    /// Creates new asset position data
    /// - Parameters:
    ///   - assetId: Asset ID
    ///   - amount: Amount
    public init(assetId: String, amount: UInt64) {
        self.assetId = assetId
        self.amount = amount
    }
} 