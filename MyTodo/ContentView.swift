//
//  ContentView.swift
//  MyTodo
//
//  Created by 重村浩二 on 2025/03/19.
//

import SwiftUI

struct ContentView: View {
    // EnvironmentObjectからViewModelを取得
    @EnvironmentObject private var viewModel: TodoViewModel
    @State private var isEditing = false
    @State private var animateBackground = false
    
    // または代わりに以下のようにEnvironmentInjectを使うこともできます
    // @EnvironmentInject private var viewModel: TodoViewModel
    
    var body: some View {
        ZStack {
            // 背景グラデーション
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.5)]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
                .hueRotation(.degrees(animateBackground ? 15 : 0))
                .animation(Animation.easeInOut(duration: 5).repeatForever(autoreverses: true), value: animateBackground)
                .onAppear { animateBackground = true }
            
            VStack(spacing: 0) {
                // ヘッダー
                HStack {
                    Text("タスク")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Spacer()
                    Button(action: { isEditing.toggle() }) {
                        Text(isEditing ? "完了" : "編集")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .buttonStyle(.bordered)
                    .tint(.white.opacity(0.3))
                }
                .padding(.horizontal)
                .padding(.top)
                
                // タスク入力エリア
                HStack(spacing: 10) {
                    TextField("新しいタスクを追加", text: $viewModel.newTodoTitle)
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                        .accentColor(.white)
                        .font(.system(.body, design: .rounded))
                    
                    Button(action: viewModel.addTodo) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .shadow(radius: 2)
                    }
                    .disabled(viewModel.newTodoTitle.isEmpty)
                }
                .padding()
                
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                        .padding()
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                } else {
                    // タスクリスト
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.todos) { todo in
                                VStack(spacing: 0) {
                                    taskCard(for: todo)
                                        .transition(.scale.combined(with: .opacity))
                                    
                                    if todo.isExpanded && !todo.subTasks.isEmpty {
                                        // サブタスクリスト
                                        VStack(spacing: 8) {
                                            ForEach(todo.subTasks) { subTask in
                                                subTaskCard(todo: todo, subTask: subTask)
                                            }
                                        }
                                        .padding(.leading, 20)
                                        .padding(.top, 8)
                                    }
                                    
                                    if todo.isExpanded {
                                        // サブタスク追加ボタン
                                        Button(action: {
                                            viewModel.selectedTodoId = todo.id
                                            viewModel.showingSubTaskInput = true
                                        }) {
                                            HStack {
                                                Image(systemName: "plus")
                                                    .font(.system(size: 14))
                                                Text("サブタスクを追加")
                                                    .font(.system(.subheadline, design: .rounded))
                                            }
                                            .padding(.vertical, 8)
                                            .padding(.horizontal, 16)
                                            .foregroundColor(.white.opacity(0.8))
                                            .background(Color.white.opacity(0.1))
                                            .cornerRadius(8)
                                        }
                                        .padding(.top, 8)
                                        .padding(.leading, 40)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                }
                            }
                            .onDelete(perform: viewModel.deleteTodo)
                        }
                        .padding(.horizontal)
                        .animation(.spring(), value: viewModel.todos)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .padding(.bottom)
                }
            }
            
            // サブタスク入力シート
            if viewModel.showingSubTaskInput, let todoId = viewModel.selectedTodoId {
                VStack(spacing: 16) {
                    Text("サブタスクを追加")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    TextField("サブタスクを入力", text: $viewModel.newSubTaskTitle)
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                        .accentColor(.white)
                    
                    HStack(spacing: 20) {
                        Button("キャンセル") {
                            viewModel.showingSubTaskInput = false
                            viewModel.newSubTaskTitle = ""
                        }
                        .foregroundColor(.white.opacity(0.7))
                        
                        Button("追加") {
                            viewModel.addSubTask(todoId: todoId)
                        }
                        .disabled(viewModel.newSubTaskTitle.isEmpty)
                        .foregroundColor(viewModel.newSubTaskTitle.isEmpty ? .gray : .white)
                        .fontWeight(.bold)
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.black.opacity(0.7))
                )
                .shadow(radius: 10)
                .frame(width: 300)
                .transition(.scale)
                .zIndex(1)
            }
        }
        .onAppear(perform: viewModel.loadTodos)
        .animation(.spring(), value: viewModel.showingSubTaskInput)
    }
    
    private func taskCard(for todo: TodoItem) -> some View {
        HStack {
            Button(action: {
                viewModel.toggleTodoCompletion(todoId: todo.id)
            }) {
                Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24))
                    .foregroundColor(todo.isCompleted ? .green : .white.opacity(0.8))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(todo.title)
                    .font(.system(.headline, design: .rounded))
                    .foregroundColor(.white)
                    .strikethrough(todo.isCompleted)
                    .opacity(todo.isCompleted ? 0.6 : 1)
                
                if !todo.subTasks.isEmpty {
                    Text("\(todo.subTasks.filter { $0.isCompleted }.count)/\(todo.subTasks.count) 完了")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            
            Spacer()
            
            // サブタスクの展開ボタンを表示（サブタスクがある場合のみ）
            if !todo.subTasks.isEmpty || isEditing {
                Button(action: {
                    viewModel.toggleTodoExpanded(todoId: todo.id)
                }) {
                    Image(systemName: todo.isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            
            if isEditing {
                Button(action: {
                    if let index = viewModel.todos.firstIndex(where: { $0.id == todo.id }) {
                        viewModel.deleteTodo(at: IndexSet([index]))
                    }
                }) {
                    Image(systemName: "trash.fill")
                        .foregroundColor(.red.opacity(0.7))
                }
                .transition(.scale)
                .padding(.leading, 8)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.15))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
        .animation(.spring(), value: isEditing)
    }
    
    private func subTaskCard(todo: TodoItem, subTask: SubTask) -> some View {
        HStack {
            Button(action: {
                viewModel.toggleSubTaskCompletion(todoId: todo.id, subTaskId: subTask.id)
            }) {
                Image(systemName: subTask.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 18))
                    .foregroundColor(subTask.isCompleted ? .green.opacity(0.8) : .white.opacity(0.6))
            }
            
            Text(subTask.title)
                .font(.system(.subheadline, design: .rounded))
                .foregroundColor(.white.opacity(0.9))
                .strikethrough(subTask.isCompleted)
                .opacity(subTask.isCompleted ? 0.6 : 1)
            
            Spacer()
            
            if isEditing {
                Button(action: {
                    viewModel.deleteSubTask(todoId: todo.id, subTaskId: subTask.id)
                }) {
                    Image(systemName: "minus.circle.fill")
                        .foregroundColor(.red.opacity(0.6))
                        .font(.system(size: 18))
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(0.08))
        )
    }
}

#Preview {
    ContentView()
        .environmentObject(DIContainer.shared.resolve(TodoViewModel.self))
}