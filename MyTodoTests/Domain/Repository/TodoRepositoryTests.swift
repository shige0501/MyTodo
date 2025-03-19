//
//  TodoRepositoryTests.swift
//  MyTodoTests
//
//  Created by 重村浩二 on 2025/03/19.
//

import XCTest
@testable import MyTodo

final class TodoRepositoryTests: XCTestCase {
    
    var repository: TodoRepository!
    var mockLocalDataSource: MockTodoLocalDataSource!
    
    override func setUp() {
        super.setUp()
        mockLocalDataSource = MockTodoLocalDataSource()
        repository = TodoRepository(localDataSource: mockLocalDataSource)
    }
    
    override func tearDown() {
        repository = nil
        mockLocalDataSource = nil
        super.tearDown()
    }
    
    func testSaveTodos() throws {
        // テスト用のTodoItemを作成
        let todos = [TodoItem(title: "テストタスク")]
        
        // リポジトリを通して保存
        try repository.saveTodos(todos)
        
        // mockが正しく呼び出されたことを検証
        XCTAssertTrue(mockLocalDataSource.saveTodosCalled)
        XCTAssertEqual(mockLocalDataSource.savedTodos?.count, 1)
        XCTAssertEqual(mockLocalDataSource.savedTodos?.first?.title, "テストタスク")
    }
    
    func testLoadTodos() throws {
        // モックが返すデータを設定
        let todo = TodoItem(title: "テストタスク", isCompleted: true)
        mockLocalDataSource.todosToReturn = [todo]
        
        // リポジトリからデータを読み込み
        let loadedTodos = try repository.loadTodos()
        
        // mockが正しく呼び出され、適切なデータが返されたことを検証
        XCTAssertTrue(mockLocalDataSource.loadTodosCalled)
        XCTAssertEqual(loadedTodos.count, 1)
        XCTAssertEqual(loadedTodos.first?.title, "テストタスク")
        XCTAssertTrue(loadedTodos.first?.isCompleted ?? false)
    }
    
    func testLoadTodosError() throws {
        // モックがエラーをスローするように設定
        mockLocalDataSource.shouldThrowError = true
        
        // エラーがスローされることを検証
        XCTAssertThrowsError(try repository.loadTodos())
    }
    
    func testSaveTodosError() throws {
        // モックがエラーをスローするように設定
        mockLocalDataSource.shouldThrowError = true
        
        // エラーがスローされることを検証
        XCTAssertThrowsError(try repository.saveTodos([]))
    }
}

// LocalDataSourceのモッククラス
class MockTodoLocalDataSource: TodoLocalDataSourceProtocol {
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