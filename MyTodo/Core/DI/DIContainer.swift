//
//  DIContainer.swift
//  MyTodo
//
//  Created by 重村浩二 on 2025/03/19.
//

import Foundation
import SwiftUI

/// DIコンテナの管理クラス - Swinjectを使用しない実装
final class DIContainer {
    /// シングルトンインスタンス
    static let shared = DIContainer()
    
    // 依存性の辞書
    private var factories: [String: () -> Any] = [:]
    private var cache: [String: Any] = [:]
    
    /// 初期化（プライベート）
    private init() {
        setupDependencies()
    }
    
    /// 依存性の設定
    private func setupDependencies() {
        // LocalDataSource
        register(TodoLocalDataSourceProtocol.self) {
            TodoLocalDataSource()
        }
        
        // Repository
        register(TodoRepositoryProtocol.self) {
            TodoRepository(localDataSource: self.resolve(TodoLocalDataSourceProtocol.self))
        }
        
        // UseCase
        register(TodoUseCaseProtocol.self) {
            TodoUseCase(repository: self.resolve(TodoRepositoryProtocol.self))
        }
        
        // ViewModel
        register(TodoViewModel.self) {
            TodoViewModel(todoUseCase: self.resolve(TodoUseCaseProtocol.self))
        }
    }
    
    /// 依存性を登録
    func register<T>(_ type: T.Type, factory: @escaping () -> T) {
        let key = String(describing: type)
        factories[key] = factory
        cache[key] = factory()
    }
    
    /// 依存性を解決
    func resolve<T>(_ type: T.Type) -> T {
        let key = String(describing: type)
        
        // キャッシュから取得
        if let cachedValue = cache[key] as? T {
            return cachedValue
        }
        
        // ファクトリから生成
        guard let factory = factories[key] as? () -> T else {
            fatalError("Dependency for type \(key) not registered")
        }
        
        let instance = factory()
        cache[key] = instance
        return instance
    }
    
    /// オプショナルとして依存性を解決
    func optional<T>(_ type: T.Type) -> T? {
        let key = String(describing: type)
        return cache[key] as? T
    }
    
    /// 名前付きで依存性を解決（このシンプルな実装では名前は無視されます）
    func resolve<T>(_ type: T.Type, name: String) -> T {
        return resolve(type)
    }
}

/// 依存性を注入するためのプロパティラッパー
@propertyWrapper
struct Inject<T> {
    private let container: DIContainer
    
    var wrappedValue: T {
        container.resolve(T.self)
    }
    
    init(container: DIContainer = DIContainer.shared) {
        self.container = container
    }
}

/// 環境オブジェクトとして依存性を注入するためのプロパティラッパー
@propertyWrapper
struct EnvironmentInject<T: ObservableObject> {
    @StateObject var wrappedValue: T
    
    init(container: DIContainer = DIContainer.shared) {
        self._wrappedValue = StateObject(wrappedValue: container.resolve(T.self))
    }
    
    var projectedValue: ObservedObject<T>.Wrapper {
        return $wrappedValue
    }
}