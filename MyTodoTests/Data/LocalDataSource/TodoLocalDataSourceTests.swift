//
//  TodoLocalDataSourceTests.swift
//  MyTodoTests
//
//  Created by 重村浩二 on 2025/03/19.
//

import XCTest
@testable import MyTodo

// テスト用のLocalDataSourceサブクラス
class TestTodoLocalDataSource: TodoLocalDataSource {
    // テスト用のキーに上書き
    override var todosKey: String {
        return "todos_test"
    }
}

final class TodoLocalDataSourceTests: XCTestCase {
    
    var localDataSource: TestTodoLocalDataSource!
    
    override func setUp() {
        super.setUp()
        localDataSource = TestTodoLocalDataSource()
        
        // テストで使用するUserDefaultsのキーをクリア
        UserDefaults.standard.removeObject(forKey: localDataSource.todosKey)
    }
    
    override func tearDown() {
        // テスト後にUserDefaultsをクリーンアップ
        UserDefaults.standard.removeObject(forKey: localDataSource.todosKey)
        localDataSource = nil
        super.tearDown()
    }
    
    func testSaveAndLoadTodos() throws {
        // テスト用のTodoItemを作成
        let todo1 = TodoItem(title: "テストタスク1")
        let todo2 = TodoItem(title: "テストタスク2", isCompleted: true)
        let todos = [todo1, todo2]
        
        // 保存
        try localDataSource.saveTodos(todos)
        
        // 読み込み
        let loadedTodos = try localDataSource.loadTodos()
        
        // 検証
        XCTAssertEqual(loadedTodos.count, 2)
        XCTAssertEqual(loadedTodos[0].title, "テストタスク1")
        XCTAssertFalse(loadedTodos[0].isCompleted)
        XCTAssertEqual(loadedTodos[1].title, "テストタスク2")
        XCTAssertTrue(loadedTodos[1].isCompleted)
    }
    
    func testLoadTodosEmpty() throws {
        // 何も保存していない状態で読み込み
        let loadedTodos = try localDataSource.loadTodos()
        
        // 空の配列が返されることを検証
        XCTAssertEqual(loadedTodos.count, 0)
    }
    
    func testSaveAndLoadTodosWithSubTasks() throws {
        // サブタスクを含むTodoItemを作成
        var todo = TodoItem(title: "親タスク")
        let subTask1 = SubTask(title: "サブタスク1")
        let subTask2 = SubTask(title: "サブタスク2", isCompleted: true)
        todo.subTasks = [subTask1, subTask2]
        todo.isExpanded = true
        
        let todos = [todo]
        
        // 保存
        try localDataSource.saveTodos(todos)
        
        // 読み込み
        let loadedTodos = try localDataSource.loadTodos()
        
        // 検証
        XCTAssertEqual(loadedTodos.count, 1)
        XCTAssertEqual(loadedTodos[0].title, "親タスク")
        XCTAssertEqual(loadedTodos[0].subTasks.count, 2)
        XCTAssertEqual(loadedTodos[0].subTasks[0].title, "サブタスク1")
        XCTAssertFalse(loadedTodos[0].subTasks[0].isCompleted)
        XCTAssertEqual(loadedTodos[0].subTasks[1].title, "サブタスク2")
        XCTAssertTrue(loadedTodos[0].subTasks[1].isCompleted)
        XCTAssertTrue(loadedTodos[0].isExpanded)
    }
}