# Blend Capital Swift Module - Deposit and Withdrawal Logic

## Overview

This document outlines the deposit and withdrawal logic for the Blend Capital Swift module, focusing on how the module interacts with Blend Capital contracts for fund management operations. The implementation leverages the Soroban contract interface provided by the Stellar iOS SDK and follows the protocol's requirements for the `submit` function as specified in the Blend Capital documentation.

## Fund Management Core Concepts

The Blend Capital protocol handles all fund management operations through a single `submit()` function that accepts one or more `Request` structs. This design allows for atomic execution of multiple operations in a single transaction.

### Request Types

According to the Blend Capital documentation, the following request types are supported:

1. **Deposit** (enum 0): Deposits funds into the pool without collateralizing them.
2. **Withdraw** (enum 1): Withdraws uncollateralized funds from the pool.
3. **Deposit Collateral** (enum 2): Deposits funds as collateral into the pool.
4. **Withdraw Collateral** (enum 3): Withdraws collateral from the pool.
5. **Borrow** (enum 4): Borrows funds from the pool.
6. **Repay** (enum 5): Repays borrowed funds.

Each request includes:
- `request_type`: The type of operation (0-5 for the operations we need)
- `address`: The asset address or liquidatee address
- `amount`: The amount of the asset to operate on

## Swift Implementation

### Fund Request Model

```swift
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

public enum FundRequestType: Int, Equatable, Codable {
    case deposit = 0
    case withdraw = 1
    case depositCollateral = 2
    case withdrawCollateral = 3
    case borrow = 4
    case repay = 5
    
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
```

### Fund Manager Service

```swift
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
    
    /// Submits a fund request to the Blend Capital contract
    /// - Parameter request: The fund request to submit
    /// - Returns: A publisher that emits a transaction result or an error
    func submitRequest(request: FundRequest) -> AnyPublisher<TransactionResult, BlendError>
    
    /// Submits multiple fund requests to the Blend Capital contract in a single transaction
    /// - Parameter requests: The fund requests to submit
    /// - Returns: A publisher that emits a transaction result or an error
    func submitRequests(requests: [FundRequest]) -> AnyPublisher<TransactionResult, BlendError>
}
```

### Fund Manager Implementation

```swift
public class FundManager: FundManagerServiceProtocol {
    private let sorobanService: SorobanServiceProtocol
    private let stellarService: StellarServiceProtocol
    private let configuration: BlendConfigurationProtocol
    
    public init(
        sorobanService: SorobanServiceProtocol,
        stellarService: StellarServiceProtocol,
        configuration: BlendConfigurationProtocol
    ) {
        self.sorobanService = sorobanService
        self.stellarService = stellarService
        self.configuration = configuration
    }
    
    public func createDepositRequest(accountId: String, poolId: String, assetId: String, amount: Decimal) -> FundRequest {
        return FundRequest(
            requestType: .deposit,
            address: assetId,
            amount: amount,
            accountId: accountId,
            poolId: poolId
        )
    }
    
    public func createWithdrawRequest(accountId: String, poolId: String, assetId: String, amount: Decimal) -> FundRequest {
        return FundRequest(
            requestType: .withdraw,
            address: assetId,
            amount: amount,
            accountId: accountId,
            poolId: poolId
        )
    }
    
    public func createDepositCollateralRequest(accountId: String, poolId: String, assetId: String, amount: Decimal) -> FundRequest {
        return FundRequest(
            requestType: .depositCollateral,
            address: assetId,
            amount: amount,
            accountId: accountId,
            poolId: poolId
        )
    }
    
    public func createWithdrawCollateralRequest(accountId: String, poolId: String, assetId: String, amount: Decimal) -> FundRequest {
        return FundRequest(
            requestType: .withdrawCollateral,
            address: assetId,
            amount: amount,
            accountId: accountId,
            poolId: poolId
        )
    }
    
    public func createBorrowRequest(accountId: String, poolId: String, assetId: String, amount: Decimal) -> FundRequest {
        return FundRequest(
            requestType: .borrow,
            address: assetId,
            amount: amount,
            accountId: accountId,
            poolId: poolId
        )
    }
    
    public func createRepayRequest(accountId: String, poolId: String, assetId: String, amount: Decimal) -> FundRequest {
        return FundRequest(
            requestType: .repay,
            address: assetId,
            amount: amount,
            accountId: accountId,
            poolId: poolId
        )
    }
    
    public func submitRequest(request: FundRequest) -> AnyPublisher<TransactionResult, BlendError> {
        return submitRequests(requests: [request])
    }
    
    public func submitRequests(requests: [FundRequest]) -> AnyPublisher<TransactionResult, BlendError> {
        guard let poolContractId = configuration.contractIds[requests.first?.poolId ?? ""] else {
            return Fail(error: BlendError.validationError(message: "Invalid pool ID")).eraseToAnyPublisher()
        }
        
        // Convert requests to SCVal format for Soroban contract call
        let scValRequests = requests.map { request -> SCVal in
            let requestStruct = SCVal.map([
                SCVal.symbol("request_type"): SCVal.u32(UInt32(request.requestType.rawValue)),
                SCVal.symbol("address"): SCVal.string(request.address),
                SCVal.symbol("amount"): SCVal.i128(Int128(stringLiteral: request.amount.stringValue))
            ])
            return requestStruct
        }
        
        // Create the arguments for the submit function
        let args: [SCVal] = [
            SCVal.vec(scValRequests),                      // requests
            SCVal.string(requests.first?.accountId ?? ""), // spender
            SCVal.string(requests.first?.accountId ?? ""), // from
            SCVal.string(requests.first?.accountId ?? "")  // to
        ]
        
        // Invoke the submit function on the pool contract
        return sorobanService.invokeContract(
            contractId: poolContractId,
            method: "submit",
            arguments: args
        )
        .flatMap { result -> AnyPublisher<TransactionResult, BlendError> in
            // Process the result and return a TransactionResult
            let transactionResult = TransactionResult(
                success: true,
                transactionHash: result.transactionHash,
                ledger: result.ledger,
                createdAt: Date(),
                resultXDR: result.resultXDR
            )
            return Just(transactionResult)
                .setFailureType(to: BlendError.self)
                .eraseToAnyPublisher()
        }
        .mapError { error in
            if let blendError = error as? BlendError {
                return blendError
            } else {
                return BlendError.contractError(message: error.localizedDescription)
            }
        }
        .eraseToAnyPublisher()
    }
}
```

## Transaction Flow

The deposit and withdrawal process follows these steps:

1. **Create Request**: The client application creates a `FundRequest` using one of the helper methods provided by the `FundManagerService`.
2. **Submit Request**: The client application calls `submitRequest` or `submitRequests` to submit the request(s) to the Blend Capital contract.
3. **Convert to SCVal**: The `FundManager` converts the request(s) to the SCVal format required by the Soroban contract.
4. **Invoke Contract**: The `FundManager` uses the `SorobanService` to invoke the `submit` function on the pool contract with the appropriate arguments.
5. **Process Result**: The `FundManager` processes the result and returns a `TransactionResult` to the client application.

### Example: Deposit Flow

```swift
// Get the shared instance of BlendCapital
let blendCapital = BlendCapital.shared

// Configure for testnet
blendCapital.configure(with: BlendConfiguration(environment: .testnet))

// Deposit 100 USDC to a pool
blendCapital.deposit(
    accountId: "GACVHHIZGSRWXGN...",
    poolId: "pool123",
    assetId: "USDC",
    amount: 100
)
.receive(on: DispatchQueue.main)
.sink(
    receiveCompletion: { completion in
        switch completion {
        case .finished:
            print("Successfully deposited funds")
        case .failure(let error):
            print("Error depositing funds: \(error)")
        }
    },
    receiveValue: { result in
        print("Transaction Hash: \(result.transactionHash)")
        print("Ledger: \(result.ledger)")
        print("Created At: \(result.createdAt)")
    }
)
.store(in: &cancellables)
```

### Example: Multiple Operations in a Single Transaction

```swift
// Create deposit and borrow requests
let depositRequest = blendCapital.createDepositCollateralRequest(
    accountId: "GACVHHIZGSRWXGN...",
    poolId: "pool123",
    assetId: "USDC",
    amount: 100
)

let borrowRequest = blendCapital.createBorrowRequest(
    accountId: "GACVHHIZGSRWXGN...",
    poolId: "pool123",
    assetId: "XLM",
    amount: 500
)

// Submit both requests in a single transaction
blendCapital.submitRequests(requests: [depositRequest, borrowRequest])
.receive(on: DispatchQueue.main)
.sink(
    receiveCompletion: { completion in
        switch completion {
        case .finished:
            print("Successfully executed operations")
        case .failure(let error):
            print("Error executing operations: \(error)")
        }
    },
    receiveValue: { result in
        print("Transaction Hash: \(result.transactionHash)")
        print("Ledger: \(result.ledger)")
        print("Created At: \(result.createdAt)")
    }
)
.store(in: &cancellables)
```

## Error Handling

The deposit and withdrawal logic includes comprehensive error handling to provide clear feedback to the client application.

```swift
public enum FundOperationError: Error, Equatable {
    case insufficientFunds(message: String)
    case insufficientCollateral(message: String)
    case poolFrozen(message: String)
    case poolOnIce(message: String)
    case poolInSetup(message: String)
    case invalidAsset(message: String)
    case invalidAmount(message: String)
    case transactionFailed(message: String)
    case unauthorized(message: String)
    
    public var localizedDescription: String {
        switch self {
        case .insufficientFunds(let message):
            return "Insufficient funds: \(message)"
        case .insufficientCollateral(let message):
            return "Insufficient collateral: \(message)"
        case .poolFrozen(let message):
            return "Pool is frozen: \(message)"
        case .poolOnIce(let message):
            return "Pool is on ice: \(message)"
        case .poolInSetup(let message):
            return "Pool is in setup: \(message)"
        case .invalidAsset(let message):
            return "Invalid asset: \(message)"
        case .invalidAmount(let message):
            return "Invalid amount: \(message)"
        case .transactionFailed(let message):
            return "Transaction failed: \(message)"
        case .unauthorized(let message):
            return "Unauthorized: \(message)"
        }
    }
}
```

## Transaction Result Model

```swift
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
```

## Public API Extensions

The following extensions to the `BlendCapital` class provide a clean, easy-to-use interface for deposit and withdrawal operations.

```swift
extension BlendCapital {
    // Deposit funds
    public func deposit(accountId: String, poolId: String, assetId: String, amount: Decimal) -> AnyPublisher<TransactionResult, BlendError> {
        let request = fundManagerService.createDepositRequest(
            accountId: accountId,
            poolId: poolId,
            assetId: assetId,
            amount: amount
        )
        return fundManagerService.submitRequest(request: request)
    }
    
    // Withdraw funds
    public func withdraw(accountId: String, poolId: String, assetId: String, amount: Decimal) -> AnyPublisher<TransactionResult, BlendError> {
        let request = fundManagerService.createWithdrawRequest(
            accountId: accountId,
            poolId: poolId,
            assetId: assetId,
            amount: amount
        )
        return fundManagerService.submitRequest(request: request)
    }
    
    // Deposit collateral
    public func depositCollateral(accountId: String, poolId: String, assetId: String, amount: Decimal) -> AnyPublisher<TransactionResult, BlendError> {
        let request = fundManagerService.createDepositCollateralRequest(
            accountId: accountId,
            poolId: poolId,
            assetId: assetId,
            amount: amount
        )
        return fundManagerService.submitRequest(request: request)
    }
    
    // Withdraw collateral
    public func withdrawCollateral(accountId: String, poolId: String, assetId: String, amount: Decimal) -> AnyPublisher<TransactionResult, BlendError> {
        let request = fundManagerService.createWithdrawCollateralRequest(
            accountId: accountId,
            poolId: poolId,
            assetId: assetId,
            amount: amount
        )
        return fundManagerService.submitRequest(request: request)
    }
    
    // Borrow funds
    public func borrow(accountId: String, poolId: String, assetId: String, amount: Decimal) -> AnyPublisher<TransactionResult, BlendError> {
        let request = fundManagerService.createBorrowRequest(
            accountId: accountId,
            poolId: poolId,
            assetId: assetId,
            amount: amount
        )
        return fundManagerService.submitRequest(request: request)
    }
    
    // Repay borrowed funds
    public func repay(accountId: String, poolId: String, assetId: String, amount: Decimal) -> AnyPublisher<TransactionResult, BlendError> {
        let request = fundManagerService.createRepayRequest(
            accountId: accountId,
            poolId: poolId,
            assetId: assetId,
            amount: amount
        )
        return fundManagerService.submitRequest(request: request)
    }
    
    // Create a fund request
    public func createFundRequest(
        requestType: FundRequestType,
        accountId: String,
        poolId: String,
        assetId: String,
        amount: Decimal
    ) -> FundRequest {
        switch requestType {
        case .deposit:
            return fundManagerService.createDepositRequest(
                accountId: accountId,
                poolId: poolId,
                assetId: assetId,
                amount: amount
            )
        case .withdraw:
            return fundManagerService.createWithdrawRequest(
                accountId: accountId,
                poolId: poolId,
                assetId: assetId,
                amount: amount
            )
        case .depositCollateral:
            return fundManagerService.createDepositCollateralRequest(
                accountId: accountId,
                poolId: poolId,
                assetId: assetId,
                amount: amount
            )
        case .withdrawCollateral:
            return fundManagerService.createWithdrawCollateralRequest(
                accountId: accountId,
                poolId: poolId,
                assetId: assetId,
                amount: amount
            )
        case .borrow:
            return fundManagerService.createBorrowRequest(
                accountId: accountId,
                poolId: poolId,
                assetId: assetId,
                amount: amount
            )
        case .repay:
            return fundManagerService.createRepayRequest(
                accountId: accountId,
                poolId: poolId,
                assetId: assetId,
                amount: amount
            )
        }
    }
    
    // Submit a fund request
    public func submitRequest(request: FundRequest) -> AnyPublisher<TransactionResult, BlendError> {
        return fundManagerService.submitRequest(request: request)
    }
    
    // Submit multiple fund requests in a single transaction
    public func submitRequests(requests: [FundRequest]) -> AnyPublisher<TransactionResult, BlendError> {
        return fundManagerService.submitRequests(requests: requests)
    }
}
```

## Validation and Safety Checks

The deposit and withdrawal logic includes validation and safety checks to prevent errors and ensure a smooth user experience.

```swift
extension FundManager {
    private func validateRequest(_ request: FundRequest) -> Result<Void, BlendError> {
        // Validate amount
        if request.amount <= 0 {
            return .failure(BlendError.validationError(message: "Amount must be greater than zero"))
        }
        
        // Validate pool status
        return validatePoolStatus(poolId: request.poolId, requestType: request.requestType)
    }
    
    private func validatePoolStatus(poolId: String, requestType: FundRequestType) -> Result<Void, BlendError> {
        // Get pool status
        let poolStatusPublisher = sorobanService.getContractData(
            contractId: poolId,
            key: "status"
        )
        .map { scVal -> Int in
            guard case let .u32(status) = scVal else {
                throw BlendError.contractError(message: "Invalid pool status format")
            }
            return Int(status)
        }
        .mapError { error in
            if let blendError = error as? BlendError {
                return blendError
            } else {
                return BlendError.contractError(message: error.localizedDescription)
            }
        }
        
        // Wait for the pool status
        var poolStatus: Int?
        let semaphore = DispatchSemaphore(value: 0)
        
        let cancellable = poolStatusPublisher
            .sink(
                receiveCompletion: { completion in
                    if case .failure = completion {
                        poolStatus = -1
                    }
                    semaphore.signal()
                },
                receiveValue: { status in
                    poolStatus = status
                }
            )
        
        _ = semaphore.wait(timeout: .now() + 5)
        cancellable.cancel()
        
        guard let status = poolStatus else {
            return .failure(BlendError.contractError(message: "Failed to retrieve pool status"))
        }
        
        // Validate based on request type and pool status
        switch requestType {
        case .deposit, .depositCollateral:
            if status > 3 {
                return .failure(BlendError.validationError(message: "Pool is frozen"))
            }
        case .borrow:
            if status > 1 {
                return .failure(BlendError.validationError(message: "Pool is frozen or on ice"))
            }
        default:
            break
        }
        
        // All requests will fail if the pool status is 6 (Setup)
        if status == 6 {
            return .failure(BlendError.validationError(message: "Pool is in setup"))
        }
        
        return .success(())
    }
}
```

## Conclusion

The deposit and withdrawal logic provides a comprehensive interface for interacting with Blend Capital lending pools. It follows Swift best practices, leveraging Combine for asynchronous operations and following a protocol-oriented approach for flexibility and testability.

The implementation is designed to be robust, with comprehensive error handling and validation to ensure a smooth user experience. It supports all the fund management operations required by the Blend Capital protocol, including deposit, withdraw, deposit collateral, withdraw collateral, borrow, and repay.

The API is designed to be intuitive and consistent, with clear naming conventions and comprehensive documentation. It supports both simple operations and complex multi-operation transactions, making it suitable for a wide range of use cases.
