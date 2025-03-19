//
//  TodoItem.swift
//  MyTodo
//
//  Created by 重村浩二 on 2025/03/19.
//

import Foundation

struct TodoItem: Identifiable, Codable, Equatable {
    var id = UUID()
    var title: String
    var isCompleted: Bool = false
    var subTasks: [SubTask] = []
    var isExpanded: Bool = false
    
    static func == (lhs: TodoItem, rhs: TodoItem) -> Bool {
        return lhs.id == rhs.id &&
               lhs.title == rhs.title &&
               lhs.isCompleted == rhs.isCompleted &&
               lhs.subTasks == rhs.subTasks &&
               lhs.isExpanded == rhs.isExpanded
    }
}

struct SubTask: Identifiable, Codable, Equatable {
    var id = UUID()
    var title: String
    var isCompleted: Bool = false
    
    static func == (lhs: SubTask, rhs: SubTask) -> Bool {
        return lhs.id == rhs.id &&
               lhs.title == rhs.title &&
               lhs.isCompleted == rhs.isCompleted
    }
}