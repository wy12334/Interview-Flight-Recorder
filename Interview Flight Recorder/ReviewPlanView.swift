//
//  ReviewPlanView.swift
//  Interview Flight Recorder
//
//  Created by wyy on 2026/6/11.
//

import SwiftData
import SwiftUI

struct ReviewPlanView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ReviewTaskRecord.dueDate) private var tasks: [ReviewTaskRecord]
    @State private var isAddingTask = false
    @State private var editingTask: ReviewTaskRecord?

    private var unfinishedTasks: [ReviewTaskRecord] {
        tasks.filter { !$0.isDone }
    }

    private var finishedTasks: [ReviewTaskRecord] {
        tasks.filter(\.isDone)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    SectionHeader(title: "复习计划", subtitle: "把薄弱问题变成下一轮面试前的行动清单")

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        StatCard(title: "待完成", value: "\(unfinishedTasks.count)", icon: "clock", color: Color.flightOrange)
                        StatCard(title: "已完成", value: "\(finishedTasks.count)", icon: "checkmark.seal", color: Color.flightGreen)
                    }

                    TaskSection(title: "待完成", tasks: unfinishedTasks, editingTask: $editingTask)
                    TaskSection(title: "已完成", tasks: finishedTasks, editingTask: $editingTask)
                }
                .padding(16)
            }
            .background(Color.appBackground)
            .navigationTitle("复习")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isAddingTask = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $isAddingTask) {
                ReviewTaskEditorView(task: nil)
            }
            .sheet(item: $editingTask) { task in
                ReviewTaskEditorView(task: task)
            }
        }
    }
}

struct TaskSection: View {
    @Environment(\.modelContext) private var modelContext
    let title: String
    let tasks: [ReviewTaskRecord]
    @Binding var editingTask: ReviewTaskRecord?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)

            if tasks.isEmpty {
                EmptyStateView(icon: "checklist", title: "暂无任务", subtitle: "根据薄弱问题创建复习任务。")
            } else {
                VStack(spacing: 12) {
                    ForEach(tasks) { task in
                        ReviewTaskRow(task: task)
                            .contextMenu {
                                Button("编辑") {
                                    editingTask = task
                                }
                                Button(task.isDone ? "标记未完成" : "标记完成") {
                                    task.isDone.toggle()
                                }
                                Button(role: .destructive) {
                                    modelContext.delete(task)
                                } label: {
                                    Text("删除")
                                }
                            }
                    }
                }
            }
        }
    }
}

struct ReviewTaskRow: View {
    let task: ReviewTaskRecord

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Button {
                task.isDone.toggle()
            } label: {
                Image(systemName: task.isDone ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(task.isDone ? Color.flightGreen : Color.secondary)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(task.isDone ? "标记为未完成" : "标记为已完成")

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    CategoryPill(text: task.category.rawValue, color: Color.flightBlue)
                    Spacer()
                    Text("优先级 \(task.priority)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Text(task.title)
                    .font(.headline)

                Text(task.note)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text(task.dueDate, format: Date.FormatStyle(date: .numeric, time: .omitted))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .background(.white, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

struct ReviewTaskEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let task: ReviewTaskRecord?

    @State private var title: String
    @State private var category: QuestionCategory
    @State private var priority: Int
    @State private var isDone: Bool
    @State private var dueDate: Date
    @State private var note: String

    init(task: ReviewTaskRecord?) {
        self.task = task
        _title = State(initialValue: task?.title ?? "")
        _category = State(initialValue: task?.category ?? .swift)
        _priority = State(initialValue: task?.priority ?? 3)
        _isDone = State(initialValue: task?.isDone ?? false)
        _dueDate = State(initialValue: task?.dueDate ?? Date())
        _note = State(initialValue: task?.note ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("任务") {
                    TextField("任务名称", text: $title, axis: .vertical)
                    Picker("分类", selection: $category) {
                        ForEach(QuestionCategory.allCases) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                    Stepper("优先级：\(priority)", value: $priority, in: 1...5)
                    DatePicker("截止日期", selection: $dueDate, displayedComponents: .date)
                    Toggle("已完成", isOn: $isDone)
                }

                Section("备注") {
                    TextField("复习重点", text: $note, axis: .vertical)
                        .lineLimit(3...8)
                }
            }
            .navigationTitle(task == nil ? "新增任务" : "编辑任务")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        save()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }

    private func save() {
        if let task {
            task.title = title
            task.categoryRawValue = category.rawValue
            task.priority = priority
            task.isDone = isDone
            task.dueDate = dueDate
            task.note = note
        } else {
            modelContext.insert(
                ReviewTaskRecord(
                    title: title,
                    categoryRawValue: category.rawValue,
                    priority: priority,
                    isDone: isDone,
                    dueDate: dueDate,
                    note: note
                )
            )
        }

        dismiss()
    }
}
