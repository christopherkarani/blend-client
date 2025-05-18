import Foundation

/// Represents a blockchain asset
public struct Asset: Identifiable, Equatable, Codable {
    /// Unique identifier of the asset
    public let id: String
    
    /// Asset code (e.g., "XLM", "USDC")
    public let code: String
    
    /// Asset issuer account ID
    public let issuer: String
    
    /// Number of decimal places
    public let decimals: Int
    
    /// Current price in USD
    public let price: Decimal
    
    /// Collateral factor (0.0-1.0)
    public let collateralFactor: Decimal
    
    /// Liability factor (0.0-1.0)
    public let liabilityFactor: Decimal
    
    /// Creates a new asset
    /// - Parameters:
    ///   - id: Unique identifier
    ///   - code: Asset code
    ///   - issuer: Asset issuer
    ///   - decimals: Decimal places
    ///   - price: Current price
    ///   - collateralFactor: Collateral factor
    ///   - liabilityFactor: Liability factor
    public init(
        id: String,
        code: String,
        issuer: String,
        decimals: Int,
        price: Decimal,
        collateralFactor: Decimal,
        liabilityFactor: Decimal
    ) {
        self.id = id
        self.code = code
        self.issuer = issuer
        self.decimals = decimals
        self.price = price
        self.collateralFactor = collateralFactor
        self.liabilityFactor = liabilityFactor
    }
    
    /// Returns the asset's name in format "CODE:ISSUER" or just "CODE" for native assets
    public var fullName: String {
        if issuer.isEmpty {
            return code
        } else {
            return "\(code):\(issuer)"
        }
    }
}

/// Statistics for an asset in a pool
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
    
    /// Creates new asset statistics
    /// - Parameters:
    ///   - id: Asset ID
    ///   - code: Asset code
    ///   - issuer: Asset issuer
    ///   - price: Current price
    ///   - supplied: Total supplied
    ///   - borrowed: Total borrowed
    ///   - collateralFactor: Collateral factor
    ///   - liabilityFactor: Liability factor
    ///   - interestRateModel: Interest rate model
    public init(
        id: String,
        code: String,
        issuer: String,
        price: Decimal,
        supplied: Decimal,
        borrowed: Decimal,
        collateralFactor: Decimal,
        liabilityFactor: Decimal,
        interestRateModel: InterestRateModel
    ) {
        self.id = id
        self.code = code
        self.issuer = issuer
        self.price = price
        self.supplied = supplied
        self.borrowed = borrowed
        self.collateralFactor = collateralFactor
        self.liabilityFactor = liabilityFactor
        self.interestRateModel = interestRateModel
    }
    
    /// Computes the utilization rate for this asset
    public var utilizationRate: Decimal {
        guard supplied > 0 else { return 0 }
        return min(borrowed / supplied, 1)
    }
}

/// Interest rate model parameters
public struct InterestRateModel: Equatable, Codable {
    /// Base interest rate
    public let baseRate: Decimal
    
    /// Utilization rate multiplier
    public let utilizationMultiplier: Decimal
    
    /// Jump utilization rate threshold
    public let jumpUtilizationPoint: Decimal
    
    /// Jump multiplier
    public let jumpMultiplier: Decimal
    
    /// Creates a new interest rate model
    /// - Parameters:
    ///   - baseRate: Base interest rate
    ///   - utilizationMultiplier: Utilization multiplier
    ///   - jumpUtilizationPoint: Jump point
    ///   - jumpMultiplier: Jump multiplier
    public init(
        baseRate: Decimal,
        utilizationMultiplier: Decimal,
        jumpUtilizationPoint: Decimal,
        jumpMultiplier: Decimal
    ) {
        self.baseRate = baseRate
        self.utilizationMultiplier = utilizationMultiplier
        self.jumpUtilizationPoint = jumpUtilizationPoint
        self.jumpMultiplier = jumpMultiplier
    }
    
    /// Calculates the interest rate for a given utilization rate
    /// - Parameter utilizationRate: Current utilization rate
    /// - Returns: The calculated interest rate
    public func calculateInterestRate(utilizationRate: Decimal) -> Decimal {
        if utilizationRate <= jumpUtilizationPoint {
            return baseRate + (utilizationRate * utilizationMultiplier)
        } else {
            let normalRate = baseRate + (jumpUtilizationPoint * utilizationMultiplier)
            let excessUtil = utilizationRate - jumpUtilizationPoint
            return normalRate + (excessUtil * jumpMultiplier)
        }
    }
} 