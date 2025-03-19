//
//  TodoUseCaseTests.swift
//  MyTodoTests
//
//  Created by 重村浩二 on 2025/03/19.
//

import XCTest
@testable import MyTodo

final class TodoUseCaseTests: XCTestCase {
    
    var useCase: TodoUseCase!
    var mockRepository: MockTodoRepository!
    
    override func setUp() {
        super.setUp()
        mockRepository = MockTodoRepository()
        useCase = TodoUseCase(repository: mockRepository)
    }
    
    override func tearDown() {
        useCase = nil
        mockRepository = nil
        super.tearDown()
    }
    
    func testGetTodos() throws {
        // モックが返すデータを設定
        let todo = TodoItem(title: "テストタスク")
        mockRepository.todosToReturn = [todo]
        
        // UseCaseからデータを取得
        let todos = try useCase.getTodos()
        
        // リポジトリが呼び出され、正しいデータが返されることを検証
        XCTAssertTrue(mockRepository.loadTodosCalled)
        XCTAssertEqual(todos.count, 1)
        XCTAssertEqual(todos.first?.title, "テストタスク")
    }
    
    func testAddTodo() throws {
        // テスト用のデータを準備
        mockRepository.todosToReturn = []
        
        // タスクを追加
        let todos = try useCase.addTodo(title: "新しいタスク")
        
        // 保存が呼び出され、新しいタスクが追加されたことを検証
        XCTAssertTrue(mockRepository.saveTodosCalled)
        XCTAssertEqual(todos.count, 1)
        XCTAssertEqual(todos.first?.title, "新しいタスク")
        XCTAssertFalse(todos.first?.isCompleted ?? true)
    }
    
    func testToggleTodoCompletion() throws {
        // テスト用のデータを準備
        let todo = TodoItem(id: UUID(), title: "テストタスク", isCompleted: false)
        mockRepository.todosToReturn = [todo]
        
        // 初期状態を取得
        _ = try useCase.getTodos()
        
        // 完了状態を切り替え
        let updatedTodos = try useCase.toggleTodoCompletion(todoId: todo.id)
        
        // 保存が呼び出され、完了状態が変更されたことを検証
        XCTAssertTrue(mockRepository.saveTodosCalled)
        XCTAssertEqual(updatedTodos.count, 1)
        XCTAssertTrue(updatedTodos.first?.isCompleted ?? false)
    }
    
    func testToggleTodoCompletionWithSubTasks() throws {
        // サブタスクを持つテスト用データを準備
        var subTasks = [SubTask(title: "サブタスク1"), SubTask(title: "サブタスク2")]
        var todo = TodoItem(id: UUID(), title: "親タスク", isCompleted: false)
        todo.subTasks = subTasks
        mockRepository.todosToReturn = [todo]
        
        // 初期状態を取得
        _ = try useCase.getTodos()
        
        // 親タスクの完了状態を切り替え
        let updatedTodos = try useCase.toggleTodoCompletion(todoId: todo.id)
        
        // 親タスクと子タスクが両方完了状態になっていることを検証
        XCTAssertTrue(mockRepository.saveTodosCalled)
        XCTAssertTrue(updatedTodos.first?.isCompleted ?? false)
        XCTAssertTrue(updatedTodos.first?.subTasks.allSatisfy { $0.isCompleted } ?? false)
    }
    
    func testDeleteTodo() throws {
        // テスト用のデータを準備
        let todo1 = TodoItem(id: UUID(), title: "タスク1")
        let todo2 = TodoItem(id: UUID(), title: "タスク2")
        mockRepository.todosToReturn = [todo1, todo2]
        
        // 初期状態を取得
        _ = try useCase.getTodos()
        
        // 最初のタスクを削除
        let updatedTodos = try useCase.deleteTodo(at: IndexSet([0]))
        
        // 保存が呼び出され、タスクが削除されたことを検証
        XCTAssertTrue(mockRepository.saveTodosCalled)
        XCTAssertEqual(updatedTodos.count, 1)
        XCTAssertEqual(updatedTodos.first?.title, "タスク2")
    }
    
    func testToggleTodoExpanded() throws {
        // テスト用のデータを準備
        let todo = TodoItem(id: UUID(), title: "テストタスク", isExpanded: false)
        mockRepository.todosToReturn = [todo]
        
        // 初期状態を取得
        _ = try useCase.getTodos()
        
        // 展開状態を切り替え
        let updatedTodos = try useCase.toggleTodoExpanded(todoId: todo.id)
        
        // 保存が呼び出され、展開状態が変更されたことを検証
        XCTAssertTrue(mockRepository.saveTodosCalled)
        XCTAssertEqual(updatedTodos.count, 1)
        XCTAssertTrue(updatedTodos.first?.isExpanded ?? false)
    }
    
    func testAddSubTask() throws {
        // テスト用のデータを準備
        let todoId = UUID()
        let todo = TodoItem(id: todoId, title: "親タスク")
        mockRepository.todosToReturn = [todo]
        
        // 初期状態を取得
        _ = try useCase.getTodos()
        
        // サブタスクを追加
        let updatedTodos = try useCase.addSubTask(todoId: todoId, title: "新しいサブタスク")
        
        // 保存が呼び出され、サブタスクが追加されたことを検証
        XCTAssertTrue(mockRepository.saveTodosCalled)
        XCTAssertEqual(updatedTodos.count, 1)
        XCTAssertEqual(updatedTodos.first?.subTasks.count, 1)
        XCTAssertEqual(updatedTodos.first?.subTasks.first?.title, "新しいサブタスク")
    }
    
    func testToggleSubTaskCompletion() throws {
        // テスト用のデータを準備
        let todoId = UUID()
        let subTaskId = UUID()
        var subTask = SubTask(id: subTaskId, title: "サブタスク", isCompleted: false)
        var todo = TodoItem(id: todoId, title: "親タスク")
        todo.subTasks = [subTask]
        mockRepository.todosToReturn = [todo]
        
        // 初期状態を取得
        _ = try useCase.getTodos()
        
        // サブタスクの完了状態を切り替え
        let updatedTodos = try useCase.toggleSubTaskCompletion(todoId: todoId, subTaskId: subTaskId)
        
        // 保存が呼び出され、サブタスクの完了状態が変更されたことを検証
        XCTAssertTrue(mockRepository.saveTodosCalled)
        XCTAssertEqual(updatedTodos.count, 1)
        XCTAssertTrue(updatedTodos.first?.subTasks.first?.isCompleted ?? false)
    }
    
    func testDeleteSubTask() throws {
        // テスト用のデータを準備
        let todoId = UUID()
        let subTaskId = UUID()
        var subTask = SubTask(id: subTaskId, title: "サブタスク")
        var todo = TodoItem(id: todoId, title: "親タスク")
        todo.subTasks = [subTask]
        mockRepository.todosToReturn = [todo]
        
        // 初期状態を取得
        _ = try useCase.getTodos()
        
        // サブタスクを削除
        let updatedTodos = try useCase.deleteSubTask(todoId: todoId, subTaskId: subTaskId)
        
        // 保存が呼び出され、サブタスクが削除されたことを検証
        XCTAssertTrue(mockRepository.saveTodosCalled)
        XCTAssertEqual(updatedTodos.count, 1)
        XCTAssertEqual(updatedTodos.first?.subTasks.count, 0)
    }
    
    func testAllSubTasksCompletedMakesParentCompleted() throws {
        // テスト用のデータを準備
        let todoId = UUID()
        let subTaskId1 = UUID()
        let subTaskId2 = UUID()
        var subTask1 = SubTask(id: subTaskId1, title: "サブタスク1", isCompleted: true)
        var subTask2 = SubTask(id: subTaskId2, title: "サブタスク2", isCompleted: false)
        var todo = TodoItem(id: todoId, title: "親タスク", isCompleted: false)
        todo.subTasks = [subTask1, subTask2]
        mockRepository.todosToReturn = [todo]
        
        // 初期状態を取得
        _ = try useCase.getTodos()
        
        // 2つ目のサブタスクも完了にする
        let updatedTodos = try useCase.toggleSubTaskCompletion(todoId: todoId, subTaskId: subTaskId2)
        
        // すべてのサブタスクが完了すると親タスクも完了になることを検証
        XCTAssertTrue(updatedTodos.first?.isCompleted ?? false)
        XCTAssertTrue(updatedTodos.first?.subTasks.allSatisfy { $0.isCompleted } ?? false)
    }
}

// リポジトリのモッククラス
class MockTodoRepository: TodoRepositoryProtocol {
    var saveTodosCalled = false
    var loadTodosCalled = false
    var savedTodos: [TodoItem]?
    var todosToReturn: [TodoItem] = []
    var shouldThrowError = false
    
    enum MockError: Error {
        case testError
    }
    
    func saveTodos(_ todos: [TodoItem]) throws {
        if shouldThrowError {
            throw MockError.testError
        }
        saveTodosCalled = true
        savedTodos = todos
    }
    
    func loadTodos() throws -> [TodoItem] {
        if shouldThrowError {
            throw MockError.testError
        }
        loadTodosCalled = true
        return todosToReturn
    }
}