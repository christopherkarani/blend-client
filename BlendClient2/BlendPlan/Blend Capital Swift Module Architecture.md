# Blend Capital Swift Module Architecture

## Overview

This document outlines the architecture for a Swift module that integrates with Blend Capital's protocol. The module is designed to be easily dropped into existing Swift applications, providing functionality to retrieve pool statistics, manage user accounts, and handle deposits and withdrawals. The architecture follows Swift best practices, leveraging protocols, generics, and the Combine framework for reactive programming.

## Core Design Principles

The architecture is built on the following principles:

1. **Protocol-Oriented Design**: Interfaces are defined as protocols, allowing for easy mocking and testing.
2. **Functional Programming**: Pure functions are used where possible, with clear separation of data transformation and side effects.
3. **Reactive Programming**: Combine framework is used for asynchronous operations and data streams.
4. **Modularity**: Components are designed to be independent and reusable.
5. **Testability**: The architecture facilitates unit testing through dependency injection and protocol abstractions.
6. **Caching**: Efficient caching mechanisms are implemented to reduce network calls and improve performance.
7. **Network Flexibility**: Support for both testnet and mainnet environments with easy switching.

## Module Structure

The module is organized into the following layers:

### 1. Core Layer

The core layer contains fundamental types, protocols, and utilities that are used throughout the module.

```swift
// Core namespace
public enum BlendCore {
    // Core types and protocols
}
```

#### Key Components:

- **Configuration**: Handles environment settings (testnet/mainnet), network endpoints, and global parameters.
- **Error Handling**: Defines custom error types and error handling strategies.
- **Logging**: Provides logging capabilities for debugging and monitoring.
- **Utilities**: Contains helper functions and extensions.

### 2. Data Layer

The data layer is responsible for defining the data models and the interfaces for data access.

```swift
// Data namespace
public enum BlendData {
    // Data models and repositories
}
```

#### Key Components:

- **Models**: Defines the domain models such as Pool, Asset, Position, etc.
- **Repositories**: Protocols that define how to access and manipulate data.
- **DTOs**: Data Transfer Objects for serialization/deserialization.
- **Mappers**: Functions to convert between DTOs and domain models.

### 3. Network Layer

The network layer handles communication with the Stellar network and Blend Capital contracts.

```swift
// Network namespace
public enum BlendNetwork {
    // Network services and clients
}
```

#### Key Components:

- **StellarService**: Handles interactions with the Stellar network.
- **SorobanService**: Manages Soroban contract calls.
- **BlendContractClient**: Specific client for Blend Capital contracts.
- **NetworkMonitor**: Monitors network connectivity and status.

### 4. Cache Layer

The cache layer implements caching strategies to improve performance and reduce network calls.

```swift
// Cache namespace
public enum BlendCache {
    // Caching mechanisms
}
```

#### Key Components:

- **CachePolicy**: Defines caching policies (time-based, access-based, etc.).
- **CacheStorage**: Provides storage mechanisms for cached data.
- **CacheManager**: Coordinates caching operations.

### 5. Feature Layer

The feature layer implements specific features of the Blend Capital protocol.

```swift
// Features namespace
public enum BlendFeatures {
    // Feature implementations
}
```

#### Key Components:

- **PoolStats**: Retrieves and calculates pool statistics.
- **AccountManager**: Manages user account information.
- **FundManager**: Handles deposits and withdrawals.
- **YieldCalculator**: Calculates yield and interest rates.

### 6. Public API Layer

The public API layer provides a clean, easy-to-use interface for client applications.

```swift
// Main public API
public class BlendCapital {
    // Public API methods
}
```

## Detailed Component Design

### Configuration

The configuration component allows for flexible environment settings and easy switching between testnet and mainnet.

```swift
public protocol BlendConfigurationProtocol {
    var environment: BlendEnvironment { get }
    var networkEndpoint: URL { get }
    var sorobanEndpoint: URL { get }
    var contractIds: [String: String] { get }
    var cacheTTL: TimeInterval { get }
    
    func withEnvironment(_ environment: BlendEnvironment) -> Self
}

public enum BlendEnvironment {
    case testnet
    case mainnet
    
    var horizonURL: URL {
        switch self {
        case .testnet:
            return URL(string: "https://horizon-testnet.stellar.org")!
        case .mainnet:
            return URL(string: "https://horizon.stellar.org")!
        }
    }
    
    var sorobanURL: URL {
        switch self {
        case .testnet:
            return URL(string: "https://soroban-testnet.stellar.org")!
        case .mainnet:
            return URL(string: "https://soroban.stellar.org")!
        }
    }
}
```

### Data Models

The data models represent the core domain entities of the Blend Capital protocol.

```swift
public struct Pool: Identifiable, Equatable {
    public let id: String
    public let name: String
    public let assets: [Asset]
    public let totalSupplied: Decimal
    public let totalBorrowed: Decimal
    public let backstopAmount: Decimal
    public let currentYield: Decimal
    public let utilizationRate: Decimal
    public let status: PoolStatus
    
    // Additional properties and methods
}

public struct Asset: Identifiable, Equatable {
    public let id: String
    public let code: String
    public let issuer: String
    public let decimals: Int
    public let price: Decimal
    public let collateralFactor: Decimal
    public let liabilityFactor: Decimal
    
    // Additional properties and methods
}

public struct UserPosition: Equatable {
    public let accountId: String
    public let poolId: String
    public let collateralPositions: [AssetPosition]
    public let borrowPositions: [AssetPosition]
    public let depositPositions: [AssetPosition]
    public let healthFactor: Decimal
    public let yieldEarned: Decimal
    public let depositDate: Date
    
    // Additional properties and methods
}

public struct AssetPosition: Equatable {
    public let assetId: String
    public let amount: Decimal
    public let value: Decimal
    
    // Additional properties and methods
}

public enum PoolStatus: Int, Equatable {
    case active = 0
    case frozen = 1
    case onIce = 2
    case setup = 6
    
    // Additional properties and methods
}
```

### Repository Interfaces

The repository interfaces define how to access and manipulate data.

```swift
public protocol PoolRepositoryProtocol {
    func getPools() -> AnyPublisher<[Pool], Error>
    func getPool(id: String) -> AnyPublisher<Pool, Error>
    func getPoolStats(id: String) -> AnyPublisher<PoolStats, Error>
    
    // Additional methods
}

public protocol UserRepositoryProtocol {
    func getUserPosition(accountId: String, poolId: String) -> AnyPublisher<UserPosition, Error>
    func getUserPositions(accountId: String) -> AnyPublisher<[UserPosition], Error>
    
    // Additional methods
}

public protocol FundRepositoryProtocol {
    func deposit(accountId: String, poolId: String, assetId: String, amount: Decimal) -> AnyPublisher<TransactionResult, Error>
    func withdraw(accountId: String, poolId: String, assetId: String, amount: Decimal) -> AnyPublisher<TransactionResult, Error>
    func depositCollateral(accountId: String, poolId: String, assetId: String, amount: Decimal) -> AnyPublisher<TransactionResult, Error>
    func withdrawCollateral(accountId: String, poolId: String, assetId: String, amount: Decimal) -> AnyPublisher<TransactionResult, Error>
    func borrow(accountId: String, poolId: String, assetId: String, amount: Decimal) -> AnyPublisher<TransactionResult, Error>
    func repay(accountId: String, poolId: String, assetId: String, amount: Decimal) -> AnyPublisher<TransactionResult, Error>
    
    // Additional methods
}
```

### Network Services

The network services handle communication with the Stellar network and Blend Capital contracts.

```swift
public protocol StellarServiceProtocol {
    func getAccount(accountId: String) -> AnyPublisher<Account, Error>
    func submitTransaction(transaction: Transaction) -> AnyPublisher<TransactionResult, Error>
    
    // Additional methods
}

public protocol SorobanServiceProtocol {
    func getContractData(contractId: String, key: String) -> AnyPublisher<SCVal, Error>
    func invokeContract(contractId: String, method: String, arguments: [SCVal]) -> AnyPublisher<SCVal, Error>
    func simulateTransaction(transaction: Transaction) -> AnyPublisher<SimulationResult, Error>
    
    // Additional methods
}

public protocol BlendContractClientProtocol {
    func getPoolData(poolId: String) -> AnyPublisher<PoolData, Error>
    func getUserPositionData(accountId: String, poolId: String) -> AnyPublisher<UserPositionData, Error>
    func submitFundRequest(request: FundRequest) -> AnyPublisher<TransactionResult, Error>
    
    // Additional methods
}
```

### Cache Implementation

The cache implementation provides efficient caching mechanisms to improve performance.

```swift
public protocol CacheStorageProtocol {
    func get<T: Decodable>(key: String) -> T?
    func set<T: Encodable>(key: String, value: T, ttl: TimeInterval)
    func remove(key: String)
    func clear()
    
    // Additional methods
}

public protocol CacheManagerProtocol {
    func withCache<T>(_ publisher: AnyPublisher<T, Error>, key: String, ttl: TimeInterval?) -> AnyPublisher<T, Error>
    func invalidate(key: String)
    func invalidateAll()
    
    // Additional methods
}
```

### Feature Implementations

The feature implementations provide the core functionality of the Blend Capital protocol.

```swift
public protocol PoolStatsServiceProtocol {
    func getPoolStats(poolId: String) -> AnyPublisher<PoolStats, Error>
    func calculateYield(pool: Pool) -> Decimal
    func calculateUtilizationRate(pool: Pool) -> Decimal
    
    // Additional methods
}

public protocol AccountManagerServiceProtocol {
    func getUserPosition(accountId: String, poolId: String) -> AnyPublisher<UserPosition, Error>
    func calculateHealthFactor(position: UserPosition) -> Decimal
    func calculateYieldEarned(position: UserPosition) -> Decimal
    
    // Additional methods
}

public protocol FundManagerServiceProtocol {
    func createDepositRequest(accountId: String, poolId: String, assetId: String, amount: Decimal) -> FundRequest
    func createWithdrawRequest(accountId: String, poolId: String, assetId: String, amount: Decimal) -> FundRequest
    func createDepositCollateralRequest(accountId: String, poolId: String, assetId: String, amount: Decimal) -> FundRequest
    func createWithdrawCollateralRequest(accountId: String, poolId: String, assetId: String, amount: Decimal) -> FundRequest
    func createBorrowRequest(accountId: String, poolId: String, assetId: String, amount: Decimal) -> FundRequest
    func createRepayRequest(accountId: String, poolId: String, assetId: String, amount: Decimal) -> FundRequest
    func submitRequest(request: FundRequest) -> AnyPublisher<TransactionResult, Error>
    
    // Additional methods
}
```

### Public API

The public API provides a clean, easy-to-use interface for client applications.

```swift
public class BlendCapital {
    // Singleton instance
    public static let shared = BlendCapital()
    
    // Configuration
    public var configuration: BlendConfigurationProtocol
    
    // Services
    private let poolStatsService: PoolStatsServiceProtocol
    private let accountManagerService: AccountManagerServiceProtocol
    private let fundManagerService: FundManagerServiceProtocol
    
    // Initialization
    private init() {
        // Initialize with default configuration and services
    }
    
    // Configure with custom settings
    public func configure(with configuration: BlendConfigurationProtocol) {
        // Apply configuration
    }
    
    // Pool Stats API
    public func getPools() -> AnyPublisher<[Pool], Error> {
        // Implementation
    }
    
    public func getPool(id: String) -> AnyPublisher<Pool, Error> {
        // Implementation
    }
    
    public func getPoolStats(id: String) -> AnyPublisher<PoolStats, Error> {
        // Implementation
    }
    
    // Account Management API
    public func getUserPosition(accountId: String, poolId: String) -> AnyPublisher<UserPosition, Error> {
        // Implementation
    }
    
    public func getUserPositions(accountId: String) -> AnyPublisher<[UserPosition], Error> {
        // Implementation
    }
    
    // Fund Management API
    public func deposit(accountId: String, poolId: String, assetId: String, amount: Decimal) -> AnyPublisher<TransactionResult, Error> {
        // Implementation
    }
    
    public func withdraw(accountId: String, poolId: String, assetId: String, amount: Decimal) -> AnyPublisher<TransactionResult, Error> {
        // Implementation
    }
    
    public func depositCollateral(accountId: String, poolId: String, assetId: String, amount: Decimal) -> AnyPublisher<TransactionResult, Error> {
        // Implementation
    }
    
    public func withdrawCollateral(accountId: String, poolId: String, assetId: String, amount: Decimal) -> AnyPublisher<TransactionResult, Error> {
        // Implementation
    }
    
    public func borrow(accountId: String, poolId: String, assetId: String, amount: Decimal) -> AnyPublisher<TransactionResult, Error> {
        // Implementation
    }
    
    public func repay(accountId: String, poolId: String, assetId: String, amount: Decimal) -> AnyPublisher<TransactionResult, Error> {
        // Implementation
    }
    
    // Additional methods
}
```

## Dependency Injection

The architecture uses dependency injection to facilitate testing and flexibility.

```swift
public protocol DependencyContainerProtocol {
    func resolve<T>() -> T
    func register<T>(factory: @escaping () -> T)
}

public class DependencyContainer: DependencyContainerProtocol {
    private var factories: [String: () -> Any] = [:]
    
    public func resolve<T>() -> T {
        let key = String(describing: T.self)
        guard let factory = factories[key] as? () -> T else {
            fatalError("No factory registered for type \(key)")
        }
        return factory()
    }
    
    public func register<T>(factory: @escaping () -> T) {
        let key = String(describing: T.self)
        factories[key] = factory
    }
}
```

## Error Handling

The architecture defines a comprehensive error handling strategy.

```swift
public enum BlendError: Error {
    case networkError(underlying: Error)
    case contractError(message: String)
    case serializationError(message: String)
    case validationError(message: String)
    case insufficientFunds(message: String)
    case unauthorized(message: String)
    case notFound(message: String)
    case unknown(message: String)
    
    // Additional error types and methods
}

public extension Publisher {
    func mapToBlendError() -> Publishers.MapError<Self, BlendError> {
        mapError { error in
            if let blendError = error as? BlendError {
                return blendError
            } else {
                return BlendError.unknown(message: error.localizedDescription)
            }
        }
    }
}
```

## Caching Strategy

The architecture implements a flexible caching strategy to improve performance.

```swift
public enum CachePolicy {
    case noCache
    case useCache(ttl: TimeInterval)
    case refreshCache
    
    // Additional policies and methods
}

public class CacheManager: CacheManagerProtocol {
    private let storage: CacheStorageProtocol
    
    public init(storage: CacheStorageProtocol) {
        self.storage = storage
    }
    
    public func withCache<T>(_ publisher: AnyPublisher<T, Error>, key: String, ttl: TimeInterval?) -> AnyPublisher<T, Error> {
        if let ttl = ttl, let cachedValue: T = storage.get(key: key) {
            return Just(cachedValue)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        return publisher
            .handleEvents(receiveOutput: { [weak self] value in
                if let ttl = ttl {
                    self?.storage.set(key: key, value: value, ttl: ttl)
                }
            })
            .eraseToAnyPublisher()
    }
    
    public func invalidate(key: String) {
        storage.remove(key: key)
    }
    
    public func invalidateAll() {
        storage.clear()
    }
}
```

## Network Switching

The architecture supports easy switching between testnet and mainnet environments.

```swift
public class BlendConfiguration: BlendConfigurationProtocol {
    public var environment: BlendEnvironment
    public var networkEndpoint: URL { environment.horizonURL }
    public var sorobanEndpoint: URL { environment.sorobanURL }
    public var contractIds: [String: String]
    public var cacheTTL: TimeInterval
    
    public init(environment: BlendEnvironment = .testnet,
                contractIds: [String: String] = [:],
                cacheTTL: TimeInterval = 300) {
        self.environment = environment
        self.contractIds = contractIds
        self.cacheTTL = cacheTTL
    }
    
    public func withEnvironment(_ environment: BlendEnvironment) -> Self {
        var config = self
        config.environment = environment
        return config
    }
}
```

## Conclusion

This architecture provides a solid foundation for a Swift module that integrates with Blend Capital's protocol. It follows Swift best practices, leveraging protocols, generics, and the Combine framework for reactive programming. The modular design allows for easy testing, maintenance, and extension.

The architecture is designed to be easily dropped into existing Swift applications, providing functionality to retrieve pool statistics, manage user accounts, and handle deposits and withdrawals. It supports both testnet and mainnet environments with easy switching, and implements efficient caching mechanisms to improve performance.
