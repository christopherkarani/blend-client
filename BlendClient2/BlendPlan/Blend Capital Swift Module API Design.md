# Blend Capital Swift Module API Design

## Overview

This document outlines the API design for the Blend Capital Swift module, focusing on pool statistics retrieval and account management. The API is designed to be intuitive, consistent, and aligned with Swift best practices, leveraging Combine for asynchronous operations and following a protocol-oriented approach for flexibility and testability.

## Pool Stats API

The Pool Stats API provides access to information about Blend Capital lending pools, including current yield, supplied amount, borrowed amount, and backstop amount.

### Core Interfaces

#### PoolService Protocol

```swift
public protocol PoolServiceProtocol {
    /// Retrieves all available pools
    /// - Returns: A publisher that emits an array of Pool objects or an error
    func getPools() -> AnyPublisher<[Pool], BlendError>
    
    /// Retrieves a specific pool by ID
    /// - Parameter id: The unique identifier of the pool
    /// - Returns: A publisher that emits a Pool object or an error
    func getPool(id: String) -> AnyPublisher<Pool, BlendError>
    
    /// Retrieves detailed statistics for a specific pool
    /// - Parameter id: The unique identifier of the pool
    /// - Returns: A publisher that emits a PoolStats object or an error
    func getPoolStats(id: String) -> AnyPublisher<PoolStats, BlendError>
    
    /// Retrieves all assets supported by a specific pool
    /// - Parameter poolId: The unique identifier of the pool
    /// - Returns: A publisher that emits an array of Asset objects or an error
    func getPoolAssets(poolId: String) -> AnyPublisher<[Asset], BlendError>
    
    /// Retrieves a specific asset in a pool
    /// - Parameters:
    ///   - poolId: The unique identifier of the pool
    ///   - assetId: The unique identifier of the asset
    /// - Returns: A publisher that emits an Asset object or an error
    func getPoolAsset(poolId: String, assetId: String) -> AnyPublisher<Asset, BlendError>
}
```

#### Pool Data Models

```swift
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
}

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
}

public struct AssetStats: Identifiable, Equatable, Codable {
    /// Unique identifier of the asset
    public let id: String
    
    /// Asset code (e.g., "XLM", "USDC")
    public let code: String
    
    /// Asset issuer account ID
    public let issuer: String
    
    /// Current price in USD
    public let price: Decimal
    
    /// Total supplied amount of this asset
    public let supplied: Decimal
    
    /// Total borrowed amount of this asset
    public let borrowed: Decimal
    
    /// Collateral factor for this asset (0.0-1.0)
    public let collateralFactor: Decimal
    
    /// Liability factor for this asset (0.0-1.0)
    public let liabilityFactor: Decimal
    
    /// Current interest rate model parameters
    public let interestRateModel: InterestRateModel
}

public struct InterestRateModel: Equatable, Codable {
    /// Base interest rate
    public let baseRate: Decimal
    
    /// Utilization rate multiplier
    public let utilizationMultiplier: Decimal
    
    /// Jump utilization rate threshold
    public let jumpUtilizationPoint: Decimal
    
    /// Jump multiplier
    public let jumpMultiplier: Decimal
}

public enum PoolStatus: Int, Equatable, Codable {
    case active = 0
    case onIce = 1
    case frozen = 3
    case setup = 6
    
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
```

### Usage Examples

#### Retrieving All Pools

```swift
// Get the shared instance of BlendCapital
let blendCapital = BlendCapital.shared

// Configure for testnet
blendCapital.configure(with: BlendConfiguration(environment: .testnet))

// Retrieve all pools
blendCapital.getPools()
    .receive(on: DispatchQueue.main)
    .sink(
        receiveCompletion: { completion in
            switch completion {
            case .finished:
                print("Successfully retrieved pools")
            case .failure(let error):
                print("Error retrieving pools: \(error)")
            }
        },
        receiveValue: { pools in
            print("Retrieved \(pools.count) pools")
            pools.forEach { pool in
                print("Pool: \(pool.name), Yield: \(pool.currentYield)%")
            }
        }
    )
    .store(in: &cancellables)
```

#### Retrieving Pool Statistics

```swift
// Retrieve statistics for a specific pool
blendCapital.getPoolStats(id: "pool123")
    .receive(on: DispatchQueue.main)
    .sink(
        receiveCompletion: { completion in
            switch completion {
            case .finished:
                print("Successfully retrieved pool stats")
            case .failure(let error):
                print("Error retrieving pool stats: \(error)")
            }
        },
        receiveValue: { stats in
            print("Pool Stats:")
            print("Lending APY: \(stats.lendingAPY)%")
            print("Borrowing APY: \(stats.borrowingAPY)%")
            print("Utilization Rate: \(stats.utilizationRate * 100)%")
            print("Total Supplied: $\(stats.totalSupplied)")
            print("Total Borrowed: $\(stats.totalBorrowed)")
            print("Backstop Amount: $\(stats.backstopAmount)")
        }
    )
    .store(in: &cancellables)
```

## Account Management API

The Account Management API provides access to user account information, including positions, collateral, borrowing, and yield earned.

### Core Interfaces

#### AccountService Protocol

```swift
public protocol AccountServiceProtocol {
    /// Retrieves all positions for a user across all pools
    /// - Parameter accountId: The Stellar account ID of the user
    /// - Returns: A publisher that emits an array of UserPosition objects or an error
    func getUserPositions(accountId: String) -> AnyPublisher<[UserPosition], BlendError>
    
    /// Retrieves a user's position in a specific pool
    /// - Parameters:
    ///   - accountId: The Stellar account ID of the user
    ///   - poolId: The unique identifier of the pool
    /// - Returns: A publisher that emits a UserPosition object or an error
    func getUserPosition(accountId: String, poolId: String) -> AnyPublisher<UserPosition, BlendError>
    
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
    /// - Returns: A publisher that emits an array of Transaction objects or an error
    func getTransactionHistory(accountId: String, poolId: String, limit: Int = 20, offset: Int = 0) -> AnyPublisher<[Transaction], BlendError>
}
```

#### Account Data Models

```swift
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
}

public struct AssetPosition: Identifiable, Equatable, Codable {
    /// Unique identifier of the position (combination of assetId and type)
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
}

public enum AssetPositionType: String, Equatable, Codable {
    case collateral
    case borrow
    case deposit
}

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
}

public enum TransactionType: String, Equatable, Codable {
    case deposit
    case withdraw
    case depositCollateral
    case withdrawCollateral
    case borrow
    case repay
    case liquidation
}
```

### Usage Examples

#### Retrieving User Positions

```swift
// Retrieve all positions for a user
blendCapital.getUserPositions(accountId: "GACVHHIZGSRWXGN...")
    .receive(on: DispatchQueue.main)
    .sink(
        receiveCompletion: { completion in
            switch completion {
            case .finished:
                print("Successfully retrieved user positions")
            case .failure(let error):
                print("Error retrieving user positions: \(error)")
            }
        },
        receiveValue: { positions in
            print("Retrieved \(positions.count) positions")
            positions.forEach { position in
                print("Pool: \(position.poolId)")
                print("Health Factor: \(position.healthFactor)")
                print("Yield Earned: \(position.yieldEarned)")
                print("Total Collateral: $\(position.totalCollateralValue)")
                print("Total Borrowed: $\(position.totalBorrowedValue)")
            }
        }
    )
    .store(in: &cancellables)
```

#### Retrieving Transaction History

```swift
// Retrieve transaction history for a user in a specific pool
blendCapital.getTransactionHistory(accountId: "GACVHHIZGSRWXGN...", poolId: "pool123")
    .receive(on: DispatchQueue.main)
    .sink(
        receiveCompletion: { completion in
            switch completion {
            case .finished:
                print("Successfully retrieved transaction history")
            case .failure(let error):
                print("Error retrieving transaction history: \(error)")
            }
        },
        receiveValue: { transactions in
            print("Retrieved \(transactions.count) transactions")
            transactions.forEach { transaction in
                print("Date: \(transaction.date)")
                print("Type: \(transaction.type.rawValue)")
                print("Asset: \(transaction.assetId)")
                print("Amount: \(transaction.amount)")
                print("Value: $\(transaction.value)")
            }
        }
    )
    .store(in: &cancellables)
```

## Caching and Network Switching

The API includes built-in support for caching and network switching.

### Caching Configuration

```swift
// Configure caching
let configuration = BlendConfiguration(
    environment: .testnet,
    cacheTTL: 300 // Cache data for 5 minutes
)

blendCapital.configure(with: configuration)

// Retrieve pool stats with caching
blendCapital.getPoolStats(id: "pool123", cachePolicy: .useCache)
    .receive(on: DispatchQueue.main)
    .sink(
        receiveCompletion: { completion in
            // Handle completion
        },
        receiveValue: { stats in
            // Handle stats
        }
    )
    .store(in: &cancellables)

// Force refresh cache
blendCapital.getPoolStats(id: "pool123", cachePolicy: .refreshCache)
    .receive(on: DispatchQueue.main)
    .sink(
        receiveCompletion: { completion in
            // Handle completion
        },
        receiveValue: { stats in
            // Handle stats
        }
    )
    .store(in: &cancellables)
```

### Network Switching

```swift
// Switch to mainnet
blendCapital.configure(with: BlendConfiguration(environment: .mainnet))

// Switch to testnet
blendCapital.configure(with: BlendConfiguration(environment: .testnet))
```

## Error Handling

The API uses a consistent error handling approach with custom error types.

```swift
public enum BlendError: Error, Equatable {
    case networkError(String)
    case contractError(String)
    case serializationError(String)
    case validationError(String)
    case insufficientFunds(String)
    case unauthorized(String)
    case notFound(String)
    case unknown(String)
    
    public var localizedDescription: String {
        switch self {
        case .networkError(let message):
            return "Network error: \(message)"
        case .contractError(let message):
            return "Contract error: \(message)"
        case .serializationError(let message):
            return "Serialization error: \(message)"
        case .validationError(let message):
            return "Validation error: \(message)"
        case .insufficientFunds(let message):
            return "Insufficient funds: \(message)"
        case .unauthorized(let message):
            return "Unauthorized: \(message)"
        case .notFound(let message):
            return "Not found: \(message)"
        case .unknown(let message):
            return "Unknown error: \(message)"
        }
    }
}
```

### Error Handling Example

```swift
blendCapital.getPool(id: "nonexistent-pool")
    .receive(on: DispatchQueue.main)
    .sink(
        receiveCompletion: { completion in
            switch completion {
            case .finished:
                print("Successfully retrieved pool")
            case .failure(let error):
                switch error {
                case .notFound(let message):
                    print("Pool not found: \(message)")
                case .networkError(let message):
                    print("Network error: \(message)")
                default:
                    print("Error: \(error.localizedDescription)")
                }
            }
        },
        receiveValue: { pool in
            print("Pool: \(pool.name)")
        }
    )
    .store(in: &cancellables)
```

## Conclusion

The Pool Stats and Account Management API provides a comprehensive interface for interacting with Blend Capital lending pools. It follows Swift best practices, leveraging Combine for asynchronous operations and following a protocol-oriented approach for flexibility and testability.

The API is designed to be intuitive and consistent, with clear naming conventions and comprehensive documentation. It supports caching and network switching, making it suitable for use in production applications.

The next section will cover the Deposit and Withdrawal API, which builds on the foundation established here to provide functionality for depositing and withdrawing funds, as well as managing collateral and borrowing.
