//
//  TodoLocalDataSource.swift
//  MyTodo
//
//  Created by 重村浩二 on 2025/03/19.
//

import Foundation

protocol TodoLocalDataSourceProtocol {
    func saveTodos(_ todos: [TodoItem]) throws
    func loadTodos() throws -> [TodoItem]
}

class TodoLocalDataSource: TodoLocalDataSourceProtocol {
    private let userDefaults = UserDefaults.standard
    
    // オーバーライド可能にするためinternalにして変数化
    var todosKey: String {
        return "todos"
    }
    
    func saveTodos(_ todos: [TodoItem]) throws {
        let encoded = try JSONEncoder().encode(todos)
        userDefaults.set(encoded, forKey: todosKey)
    }
    
    func loadTodos() throws -> [TodoItem] {
        guard let todosData = userDefaults.data(forKey: todosKey) else {
            return []
        }
        
        return try JSONDecoder().decode([TodoItem].self, from: todosData)
    }
}