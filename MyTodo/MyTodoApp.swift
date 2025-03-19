//
//  MyTodoApp.swift
//  MyTodo
//
//  Created by 重村浩二 on 2025/03/19.
//

import SwiftUI

@main
struct MyTodoApp: App {
    // DIコンテナを使用
    private let container = DIContainer.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(container.resolve(TodoViewModel.self))
        }
    }
}
