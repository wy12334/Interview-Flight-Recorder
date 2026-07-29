//
//  InterviewsView.swift
//  Interview Flight Recorder
//
//  Created by wyy on 2026/6/11.
//

import SwiftData
import SwiftUI

struct InterviewsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \InterviewRecord.date, order: .reverse) private var interviews: [InterviewRecord]
    @Query private var questions: [QuestionRecord]
    @State private var isAddingInterview = false
    @State private var editingInterview: InterviewRecord?

    var body: some View {
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
                    } else {
                        LazyVStack(spacing: 12) {
                            ForEach(interviews) { interview in
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
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isAddingInterview = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $isAddingInterview) {
                InterviewEditorView(interview: nil)
            }
            .sheet(item: $editingInterview) { interview in
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
        if let interview {
            interview.company = company
            interview.position = position
            interview.date = date
            interview.round = round
            interview.resultRawValue = result.rawValue
            interview.score = Int(score)
            interview.summary = summary
        } else {
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
