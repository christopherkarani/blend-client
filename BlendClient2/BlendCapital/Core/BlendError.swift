import Foundation
import Combine

/// Custom error types for Blend Capital operations
public enum BlendError: Error, Equatable {
    /// Network-related errors
    case networkError(String)
    
    /// Contract-related errors
    case contractError(String)
    
    /// Serialization/deserialization errors
    case serializationError(String)
    
    /// Validation errors
    case validationError(String)
    
    /// Insufficient funds errors
    case insufficientFunds(String)
    
    /// Unauthorized access errors
    case unauthorized(String)
    
    /// Resource not found errors
    case notFound(String)
    
    /// Unknown errors
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

/// Fund operation specific errors
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

/// Publisher extension for mapping errors to BlendError
public extension Publisher {
    /// Maps any error to a BlendError
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