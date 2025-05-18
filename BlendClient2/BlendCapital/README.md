# Blend Capital Swift Module

A Swift module for interacting with the Blend Capital lending protocol on the Stellar network. This module provides functionality to retrieve pool statistics, manage user accounts, and handle deposits and withdrawals.

## Features

- **Pool Statistics**: Retrieve comprehensive statistics about Blend Capital lending pools, including current yield, supplied amount, borrowed amount, and backstop amount.
- **Account Management**: Access user account information, including positions, collateral, borrowing, and yield earned.
- **Fund Management**: Deposit and withdraw funds, manage collateral, and handle borrowing and repayment.
- **Caching**: Efficient caching mechanisms to reduce network calls and improve performance.
- **Network Flexibility**: Support for both testnet and mainnet environments with easy switching.
- **Error Handling**: Comprehensive error handling with clear error messages.

## Installation

### Swift Package Manager

Add the package dependency to your Package.swift file:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/blend-capital-swift.git", from: "1.0.0")
]
```

## Usage

### Configuration

```swift
// Get the shared instance of BlendCapital
let blendCapital = BlendCapital.shared

// Configure for testnet
blendCapital.configure(with: BlendConfiguration(environment: .testnet))
```

### Retrieving Pool Statistics

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

### Managing User Accounts

```swift
// Retrieve a user's position in a specific pool
blendCapital.getUserPosition(accountId: "GACVHHIZGSRWXGN...", poolId: "pool123")
    .receive(on: DispatchQueue.main)
    .sink(
        receiveCompletion: { completion in
            switch completion {
            case .finished:
                print("Successfully retrieved user position")
            case .failure(let error):
                print("Error retrieving user position: \(error)")
            }
        },
        receiveValue: { position in
            print("User Position:")
            print("Health Factor: \(position.healthFactor)")
            print("Yield Earned: \(position.yieldEarned)")
            print("Collateral Value: $\(position.totalCollateralValue)")
            print("Borrowed Value: $\(position.totalBorrowedValue)")
        }
    )
    .store(in: &cancellables)
```

### Fund Management

```swift
// Deposit 100 USDC into a pool
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
    }
)
.store(in: &cancellables)
```

### Multiple Operations in a Single Transaction

```swift
// Create deposit and borrow requests
let depositRequest = blendCapital.createFundRequest(
    requestType: .depositCollateral,
    accountId: "GACVHHIZGSRWXGN...",
    poolId: "pool123",
    assetId: "USDC",
    amount: 100
)

let borrowRequest = blendCapital.createFundRequest(
    requestType: .borrow,
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
    }
)
.store(in: &cancellables)
```

## Architecture

The module follows a layered architecture:

1. **Core Layer**: Fundamental types, protocols, and utilities.
2. **Data Layer**: Data models and repository interfaces.
3. **Network Layer**: Communication with the Stellar network and Blend Capital contracts.
4. **Cache Layer**: Caching mechanisms for improved performance.
5. **Feature Layer**: Specific features of the Blend Capital protocol.
6. **Public API Layer**: Clean, easy-to-use interface for client applications.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- [Blend Capital](https://blend.capital) - The Blend Capital protocol documentation.
- [Stellar Development Foundation](https://stellar.org) - The Stellar network documentation. 