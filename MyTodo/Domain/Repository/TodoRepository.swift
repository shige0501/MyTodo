//
//  TodoRepository.swift
//  MyTodo
//
//  Created by 重村浩二 on 2025/03/19.
//

import Foundation

protocol TodoRepositoryProtocol {
    func saveTodos(_ todos: [TodoItem]) throws
    func loadTodos() throws -> [TodoItem]
}

class TodoRepository: TodoRepositoryProtocol {
    private let localDataSource: TodoLocalDataSourceProtocol
    
    init(localDataSource: TodoLocalDataSourceProtocol = TodoLocalDataSource()) {
        self.localDataSource = localDataSource
    }
    
    func saveTodos(_ todos: [TodoItem]) throws {
        try localDataSource.saveTodos(todos)
    }
    
    func loadTodos() throws -> [TodoItem] {
        return try localDataSource.loadTodos()
    }
}