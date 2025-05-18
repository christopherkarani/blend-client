import Foundation
import Combine

/// Protocol for Soroban smart contract service
public protocol SorobanServiceProtocol {
    /// Retrieves contract data
    /// - Parameters:
    ///   - contractId: The contract ID
    ///   - key: The data key
    /// - Returns: A publisher that emits a SCVal or an error
    func getContractData(contractId: String, key: String) -> AnyPublisher<SCVal, BlendError>
    
    /// Invokes a contract method
    /// - Parameters:
    ///   - contractId: The contract ID
    ///   - method: The method name
    ///   - arguments: The method arguments
    /// - Returns: A publisher that emits a SCVal or an error
    func invokeContract(contractId: String, method: String, arguments: [SCVal]) -> AnyPublisher<InvokeContractResult, BlendError>
    
    /// Simulates a transaction
    /// - Parameter transaction: The transaction to simulate
    /// - Returns: A publisher that emits a SimulationResult or an error
    func simulateTransaction(transaction: StellarTransaction) -> AnyPublisher<SimulationResult, BlendError>
}

/// Placeholder for Soroban Contract Value (SCVal)
public enum SCVal: Equatable {
    /// Boolean value
    case bool(Bool)
    
    /// 32-bit unsigned integer
    case u32(UInt32)
    
    /// 64-bit unsigned integer
    case u64(UInt64)
    
    /// 128-bit signed integer
    case i128(Int128)
    
    /// String value
    case string(String)
    
    /// Symbol value
    case symbol(String)
    
    /// Vector of SCVals
    case vec([SCVal])
    
    /// Map of SCVals
    case map([SCVal: SCVal])
    
    /// Address value
    case address(String)
    
    /// Contract ID
    case contractId(String)
}

/// 128-bit signed integer
public struct Int128: Equatable {
    /// High 64 bits
    public let high: Int64
    
    /// Low 64 bits
    public let low: UInt64
    
    /// Creates a new Int128 from high and low bits
    /// - Parameters:
    ///   - high: High 64 bits
    ///   - low: Low 64 bits
    public init(high: Int64, low: UInt64) {
        self.high = high
        self.low = low
    }
    
    /// Creates a new Int128 from a string
    /// - Parameter stringLiteral: String representation
    public init(stringLiteral: String) {
        // Simple implementation for now
        self.high = 0
        self.low = UInt64(stringLiteral) ?? 0
    }
}

/// Result of a contract invocation
public struct InvokeContractResult: Equatable {
    /// Return value
    public let value: SCVal
    
    /// Transaction hash
    public let transactionHash: String
    
    /// Ledger sequence
    public let ledger: UInt64
    
    /// Result XDR
    public let resultXDR: String
    
    /// Creates a new contract invocation result
    /// - Parameters:
    ///   - value: Return value
    ///   - transactionHash: Transaction hash
    ///   - ledger: Ledger sequence
    ///   - resultXDR: Result XDR
    public init(value: SCVal, transactionHash: String, ledger: UInt64, resultXDR: String) {
        self.value = value
        self.transactionHash = transactionHash
        self.ledger = ledger
        self.resultXDR = resultXDR
    }
}

/// Result of a transaction simulation
public struct SimulationResult: Equatable {
    /// Minimum fee
    public let minFee: UInt64
    
    /// Transaction result
    public let result: SCVal
    
    /// Creates a new simulation result
    /// - Parameters:
    ///   - minFee: Minimum fee
    ///   - result: Transaction result
    public init(minFee: UInt64, result: SCVal) {
        self.minFee = minFee
        self.result = result
    }
} 