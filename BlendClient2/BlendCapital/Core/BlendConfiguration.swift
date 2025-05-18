import Foundation
import Combine

/// Environment settings for Blend Capital
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

/// Protocol defining configuration settings for Blend Capital
public protocol BlendConfigurationProtocol {
    /// Current environment (testnet/mainnet)
    var environment: BlendEnvironment { get }
    
    /// Stellar Horizon network endpoint
    var networkEndpoint: URL { get }
    
    /// Soroban network endpoint
    var sorobanEndpoint: URL { get }
    
    /// Dictionary mapping pool IDs to contract IDs
    var contractIds: [String: String] { get }
    
    /// Cache time-to-live in seconds
    var cacheTTL: TimeInterval { get }
    
    /// Creates a new configuration with a different environment
    func withEnvironment(_ environment: BlendEnvironment) -> Self
}

/// Default implementation of Blend Capital configuration
public struct BlendConfiguration: BlendConfigurationProtocol {
    public var environment: BlendEnvironment
    public var networkEndpoint: URL { environment.horizonURL }
    public var sorobanEndpoint: URL { environment.sorobanURL }
    public var contractIds: [String: String]
    public var cacheTTL: TimeInterval
    
    public init(
        environment: BlendEnvironment = .testnet,
        contractIds: [String: String] = [:],
        cacheTTL: TimeInterval = 300
    ) {
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