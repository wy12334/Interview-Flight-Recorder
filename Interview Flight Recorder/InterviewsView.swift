//
//  InterviewsView.swift
//  Interview Flight Recorder
//
//  Created by wyy on 2026/6/11.
//首页

import SwiftData
import SwiftUI

struct InterviewsView: View {
    // modelContext 负责执行 insert 和 delete 等数据写入操作。
    @Environment(\.modelContext) private var modelContext
    // 面试按日期倒序排列，所以最新记录显示在最前面。
    @Query(sort: \InterviewRecord.date, order: .reverse) private var interviews: [InterviewRecord]
    @Query private var questions: [QuestionRecord]
    // Bool 状态适合控制“是否显示新增页面”。
    @State private var isAddingInterview = false
    // 可选对象适合表示“当前正在编辑哪一条面试”。
    @State private var editingInterview: InterviewRecord?
    // 搜索文字属于当前页面的临时 UI 状态，不需要保存到 SwiftData。
    @State private var searchText = ""

    private var filteredInterviews: [InterviewRecord] {
        let keyword = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        // 没有关键词时显示 @Query 返回的完整列表；有关键词时只按公司名称过滤。
        guard !keyword.isEmpty else { return interviews }
        return interviews.filter { $0.company.localizedStandardContains(keyword) }
    }

    var body: some View {
        // NavigationStack 提供导航栏，并允许列表通过 NavigationLink 推进到详情页。
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    SectionHeader(title: "面试黑匣子", subtitle: "记录每一轮面试，沉淀问题、答案和改进计划")

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        StatCard(title: "面试次数", value: "\(interviews.count)", icon: "person.2", color: Color.flightBlue)
                        StatCard(title: "问题总数", value: "\(questions.count)", icon: "questionmark.bubble", color: Color.flightGreen)
                    }

                    if interviews.isEmpty {
                        EmptyStateView(icon: "tray", title: "暂无面试记录", subtitle: "点击右上角加号，创建第一条面试复盘。")
                    } else if filteredInterviews.isEmpty {
                        EmptyStateView(icon: "magnifyingglass", title: "没有找到公司", subtitle: "请尝试其他公司名称。")
                    } else {
                        LazyVStack(spacing: 12) {
                            // ForEach 使用搜索后的数组；数组元素是 SwiftData 的 InterviewRecord。
                            ForEach(filteredInterviews) { interview in
                                // 学习重点：这是层级跳转，点击卡片后进入详情并可返回列表。
                                NavigationLink {
                                    InterviewDetailView(interview: interview)
                                } label: {
                                    InterviewCard(interview: interview, questionCount: questions.filter { $0.interviewID == interview.id }.count)
                                }
                                .buttonStyle(.plain)
                                .contextMenu {
                                    Button("编辑") {
                                        editingInterview = interview
                                    }
                                    Button(role: .destructive) {
                                        // 删除当前 ForEach 正在展示的这条 SwiftData 模型。
                                        modelContext.delete(interview)
                                    } label: {
                                        Text("删除")
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(16)
            }
            .background(Color.appBackground)
            .navigationTitle("面试")
            // searchable 将系统搜索框绑定到 searchText，文字变化会重新计算 filteredInterviews。
            .searchable(text: $searchText, prompt: "搜索公司名称")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        // 点击新增只修改状态，状态变为 true 后由下面的 sheet 显示编辑器。
                        isAddingInterview = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            // sheet 适合新增、编辑这类临时表单，不会把它们当成主页面层级。
            .sheet(isPresented: $isAddingInterview) {
                // nil 表示没有旧对象，因此编辑器进入“新增”模式。
                InterviewEditorView(interview: nil)
            }
            .sheet(item: $editingInterview) { interview in
                // 传入已有对象，编辑器会读取旧值并进入“编辑”模式。
                InterviewEditorView(interview: interview)
            }
        }
    }
}

struct InterviewCard: View {
    let interview: InterviewRecord
    let questionCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(interview.company)
                        .font(.headline)
                    Text("\(interview.position) · \(interview.round)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                CategoryPill(text: interview.result.rawValue, color: interview.result.color)
            }

            HStack(spacing: 12) {
                Label("\(questionCount) 题", systemImage: "list.bullet.clipboard")
                Label("\(interview.score) 分", systemImage: "gauge.with.dots.needle.50percent")
            }
            .font(.caption)
            .foregroundStyle(.secondary)

            Text(interview.summary.isEmpty ? "暂无复盘总结" : interview.summary)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
        .padding(16)
        .background(.white, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

struct InterviewEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let interview: InterviewRecord?

    @State private var company: String
    @State private var position: String
    @State private var date: Date
    @State private var round: String
    @State private var result: InterviewResult
    @State private var score: Double
    @State private var summary: String

    init(interview: InterviewRecord?) {
        self.interview = interview
        _company = State(initialValue: interview?.company ?? "")
        _position = State(initialValue: interview?.position ?? "iOS 开发工程师")
        _date = State(initialValue: interview?.date ?? Date())
        _round = State(initialValue: interview?.round ?? "一面")
        _result = State(initialValue: interview?.result ?? .pending)
        _score = State(initialValue: Double(interview?.score ?? 70))
        _summary = State(initialValue: interview?.summary ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("基础信息") {
                    TextField("公司名称", text: $company)
                    TextField("岗位", text: $position)
                    DatePicker("日期", selection: $date, displayedComponents: .date)
                    TextField("轮次", text: $round)
                    Picker("结果", selection: $result) {
                        ForEach(InterviewResult.allCases) { result in
                            Text(result.rawValue).tag(result)
                        }
                    }
                }

                Section("复盘评分") {
                    Text("自评：\(Int(score)) 分")
                    Slider(value: $score, in: 0...100, step: 1)
                    TextField("复盘总结", text: $summary, axis: .vertical)
                        .lineLimit(4...8)
                }
            }
            .navigationTitle(interview == nil ? "新增面试" : "编辑面试")
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
                    .disabled(company.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }

    private func save() {
        // 同一个表单复用新增和编辑逻辑：有对象就修改，没有对象就创建。
        if let interview {
            interview.company = company
            interview.position = position
            interview.date = date
            interview.round = round
            interview.resultRawValue = result.rawValue
            interview.score = Int(score)
            interview.summary = summary
        } else {
            // insert 把新建的 InterviewRecord 加入 SwiftData 容器。
            modelContext.insert(
                InterviewRecord(
                    company: company,
                    position: position,
                    date: date,
                    round: round,
                    resultRawValue: result.rawValue,
                    score: Int(score),
                    summary: summary
                )
            )
        }

        dismiss()
    }
}
