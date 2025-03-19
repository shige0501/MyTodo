//
//  TodoUseCase.swift
//  MyTodo
//
//  Created by 重村浩二 on 2025/03/19.
//

import Foundation

protocol TodoUseCaseProtocol {
    func getTodos() throws -> [TodoItem]
    func addTodo(title: String) throws -> [TodoItem]
    func toggleTodoCompletion(todoId: UUID) throws -> [TodoItem]
    func deleteTodo(at indices: IndexSet) throws -> [TodoItem]
    func toggleTodoExpanded(todoId: UUID) throws -> [TodoItem]
    func addSubTask(todoId: UUID, title: String) throws -> [TodoItem]
    func toggleSubTaskCompletion(todoId: UUID, subTaskId: UUID) throws -> [TodoItem]
    func deleteSubTask(todoId: UUID, subTaskId: UUID) throws -> [TodoItem]
}

class TodoUseCase: TodoUseCaseProtocol {
    private let repository: TodoRepositoryProtocol
    private var todos: [TodoItem] = []
    
    init(repository: TodoRepositoryProtocol = TodoRepository()) {
        self.repository = repository
        do {
            self.todos = try repository.loadTodos()
        } catch {
            print("初回読み込みエラー: \(error)")
        }
    }
    
    func getTodos() throws -> [TodoItem] {
        self.todos = try repository.loadTodos()
        return todos
    }
    
    func addTodo(title: String) throws -> [TodoItem] {
        let newTodo = TodoItem(title: title)
        todos.append(newTodo)
        try repository.saveTodos(todos)
        return todos
    }
    
    func toggleTodoCompletion(todoId: UUID) throws -> [TodoItem] {
        if let index = todos.firstIndex(where: { $0.id == todoId }) {
            todos[index].isCompleted.toggle()
            // 親タスクが完了したら子タスクも完了にする
            if todos[index].isCompleted {
                for i in 0..<todos[index].subTasks.count {
                    todos[index].subTasks[i].isCompleted = true
                }
            }
            try repository.saveTodos(todos)
        }
        return todos
    }
    
    func deleteTodo(at indices: IndexSet) throws -> [TodoItem] {
        todos.remove(atOffsets: indices)
        try repository.saveTodos(todos)
        return todos
    }
    
    func toggleTodoExpanded(todoId: UUID) throws -> [TodoItem] {
        if let index = todos.firstIndex(where: { $0.id == todoId }) {
            todos[index].isExpanded.toggle()
            try repository.saveTodos(todos)
        }
        return todos
    }
    
    func addSubTask(todoId: UUID, title: String) throws -> [TodoItem] {
        if let index = todos.firstIndex(where: { $0.id == todoId }) {
            let newSubTask = SubTask(title: title)
            todos[index].subTasks.append(newSubTask)
            try repository.saveTodos(todos)
        }
        return todos
    }
    
    func toggleSubTaskCompletion(todoId: UUID, subTaskId: UUID) throws -> [TodoItem] {
        if let todoIndex = todos.firstIndex(where: { $0.id == todoId }),
           let subTaskIndex = todos[todoIndex].subTasks.firstIndex(where: { $0.id == subTaskId }) {
            todos[todoIndex].subTasks[subTaskIndex].isCompleted.toggle()
            
            // すべてのサブタスクが完了しているか確認
            let allSubTasksCompleted = todos[todoIndex].subTasks.allSatisfy { $0.isCompleted }
            if allSubTasksCompleted && !todos[todoIndex].subTasks.isEmpty {
                todos[todoIndex].isCompleted = true
            } else {
                todos[todoIndex].isCompleted = false
            }
            
            try repository.saveTodos(todos)
        }
        return todos
    }
    
    func deleteSubTask(todoId: UUID, subTaskId: UUID) throws -> [TodoItem] {
        if let todoIndex = todos.firstIndex(where: { $0.id == todoId }) {
            todos[todoIndex].subTasks.removeAll { $0.id == subTaskId }
            try repository.saveTodos(todos)
        }
        return todos
    }
}