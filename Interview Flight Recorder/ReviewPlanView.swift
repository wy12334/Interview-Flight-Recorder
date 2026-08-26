//
//  ReviewPlanView.swift
//  Interview Flight Recorder
//
//  Created by wyy on 2026/6/11.
//复习页

import SwiftData
import SwiftUI

struct ReviewPlanView: View {
    @Environment(\.modelContext) private var modelContext
    // @Query 会按截止日期读取任务，并在任务状态变化后自动刷新页面。
    @Query(sort: \ReviewTaskRecord.dueDate) private var tasks: [ReviewTaskRecord]
    @State private var isAddingTask = false
    @State private var editingTask: ReviewTaskRecord?
    // 只属于当前页面的筛选状态，不需要保存进 SwiftData。
    @State private var showsOnlyOverdue = false

    private var startOfToday: Date {
        // 用“今天零点”比较日期，避免今天到期的任务在当天稍晚时被误判为逾期。
        Calendar.current.startOfDay(for: Date())
    }

    private var unfinishedTasks: [ReviewTaskRecord] {
        // isDone 为 false 的任务显示在“待完成”。
        tasks.filter { !$0.isDone }
    }

    private var displayedUnfinishedTasks: [ReviewTaskRecord] {
        // 开启筛选时，在未完成任务的基础上继续筛出截止日期早于今天的任务。
        guard showsOnlyOverdue else { return unfinishedTasks }
        return unfinishedTasks.filter { $0.dueDate < startOfToday }
    }

    private var finishedTasks: [ReviewTaskRecord] {
        // isDone 为 true 的任务显示在“已完成”。
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

                    Toggle("只看逾期任务", isOn: $showsOnlyOverdue)
                        .padding(16)
                        .background(.white, in: RoundedRectangle(cornerRadius: 18, style: .continuous))

                    if showsOnlyOverdue {
                        Text("当前显示 \(displayedUnfinishedTasks.count) / 全部 \(unfinishedTasks.count) 项待完成任务")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    TaskSection(title: showsOnlyOverdue ? "逾期未完成" : "待完成", tasks: displayedUnfinishedTasks, editingTask: $editingTask)

                    // 已完成任务不属于“逾期未完成”，筛选开启时不显示这个分组。
                    if !showsOnlyOverdue {
                        TaskSection(title: "已完成", tasks: finishedTasks, editingTask: $editingTask)
                    }
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

    private var isOverdue: Bool {
        // 业务规则：只有“截止日期早于今天”并且“尚未完成”才算逾期。
        !task.isDone && task.dueDate < Calendar.current.startOfDay(for: Date())
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // 学习重点：这里必须使用 Button，单独的 Image 只能显示图标，不能响应点击。
            Button {
                // false/true 相互切换；@Query 随后驱动任务在两个分组之间移动。
                task.isDone.toggle()
            } label: {
                Image(systemName: task.isDone ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(task.isDone ? Color.flightGreen : Color.secondary)
            }
            // 保留圆圈图标原有外观，不使用系统默认按钮样式。
            .buttonStyle(.plain)
            // 告诉 VoiceOver 点击后会执行的操作，提升无障碍体验。
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
                    .foregroundStyle(isOverdue ? Color.flightRed : Color.secondary)

                if isOverdue {
                    Label("已逾期", systemImage: "exclamationmark.triangle.fill")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.flightRed)
                }
            }
        }
        .padding(16)
        .background(
            isOverdue ? Color.flightRed.opacity(0.08) : Color.white,
            in: RoundedRectangle(cornerRadius: 18, style: .continuous)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(isOverdue ? Color.flightRed.opacity(0.35) : Color.clear, lineWidth: 1)
        }
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
        // task 存在时更新原任务；为 nil 时插入一条新任务。
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
