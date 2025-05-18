import Foundation

/// Protocol for dependency container
public protocol DependencyContainerProtocol {
    /// Resolves a dependency of type T
    func resolve<T>() -> T
    
    /// Registers a factory closure for type T
    func register<T>(factory: @escaping () -> T)
}

/// Implementation of dependency container using type names as keys
public class DependencyContainer: DependencyContainerProtocol {
    /// Dictionary of factory closures
    private var factories: [String: () -> Any] = [:]
    
    /// Creates a new dependency container
    public init() {}
    
    /// Resolves a dependency of type T
    public func resolve<T>() -> T {
        let key = String(describing: T.self)
        guard let factory = factories[key] as? () -> T else {
            fatalError("No factory registered for type \(key)")
        }
        return factory()
    }
    
    /// Registers a factory closure for type T
    public func register<T>(factory: @escaping () -> T) {
        let key = String(describing: T.self)
        factories[key] = factory
    }
} 