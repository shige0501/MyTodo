//
//  TodoViewModel.swift
//  MyTodo
//
//  Created by 重村浩二 on 2025/03/19.
//

import Foundation
import SwiftUI
import Combine

class TodoViewModel: ObservableObject {
    @Published var todos: [TodoItem] = []
    @Published var newTodoTitle: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var showingSubTaskInput: Bool = false
    @Published var selectedTodoId: UUID? = nil
    @Published var newSubTaskTitle: String = ""
    
    private let todoUseCase: TodoUseCaseProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(todoUseCase: TodoUseCaseProtocol) {
        self.todoUseCase = todoUseCase
    }
    
    // MARK: - Public Methods
    
    func loadTodos() {
        isLoading = true
        errorMessage = nil
        
        do {
            todos = try todoUseCase.getTodos()
            isLoading = false
        } catch {
            handleError(error: error, action: "タスクの読み込み")
        }
    }
    
    func addTodo() {
        guard !newTodoTitle.isEmpty else { return }
        
        do {
            todos = try todoUseCase.addTodo(title: newTodoTitle)
            newTodoTitle = ""
        } catch {
            handleError(error: error, action: "タスクの追加")
        }
    }
    
    func toggleTodoCompletion(todoId: UUID) {
        do {
            todos = try todoUseCase.toggleTodoCompletion(todoId: todoId)
        } catch {
            handleError(error: error, action: "タスクの状態変更")
        }
    }
    
    func deleteTodo(at offsets: IndexSet) {
        do {
            todos = try todoUseCase.deleteTodo(at: offsets)
        } catch {
            handleError(error: error, action: "タスクの削除")
        }
    }
    
    func toggleTodoExpanded(todoId: UUID) {
        do {
            todos = try todoUseCase.toggleTodoExpanded(todoId: todoId)
        } catch {
            handleError(error: error, action: "タスクの展開状態の変更")
        }
    }
    
    func addSubTask(todoId: UUID) {
        guard !newSubTaskTitle.isEmpty else { return }
        
        do {
            todos = try todoUseCase.addSubTask(todoId: todoId, title: newSubTaskTitle)
            newSubTaskTitle = ""
            showingSubTaskInput = false
        } catch {
            handleError(error: error, action: "サブタスクの追加")
        }
    }
    
    func toggleSubTaskCompletion(todoId: UUID, subTaskId: UUID) {
        do {
            todos = try todoUseCase.toggleSubTaskCompletion(todoId: todoId, subTaskId: subTaskId)
        } catch {
            handleError(error: error, action: "サブタスクの状態変更")
        }
    }
    
    func deleteSubTask(todoId: UUID, subTaskId: UUID) {
        do {
            todos = try todoUseCase.deleteSubTask(todoId: todoId, subTaskId: subTaskId)
        } catch {
            handleError(error: error, action: "サブタスクの削除")
        }
    }
    
    // MARK: - Private Methods
    
    private func handleError(error: Error, action: String) {
        isLoading = false
        errorMessage = "\(action)に失敗しました: \(error.localizedDescription)"
        print(errorMessage ?? "")
    }
}