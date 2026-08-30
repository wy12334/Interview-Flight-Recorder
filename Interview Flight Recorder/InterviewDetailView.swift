//
//  InterviewDetailView.swift
//  Interview Flight Recorder
//
//  Created by wyy on 2026/6/11.
//

import SwiftData
import SwiftUI

struct InterviewDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \QuestionRecord.createdAt) private var allQuestions: [QuestionRecord]
    let interview: InterviewRecord
    @State private var isAddingQuestion = false
    @State private var editingQuestion: QuestionRecord?
    @State private var showsOnlyUnmastered = false

    private var questions: [QuestionRecord] {
        allQuestions.filter { $0.interviewID == interview.id }
    }

    private var displayedQuestions: [QuestionRecord] {
        guard showsOnlyUnmastered else { return questions }
        return questions.filter { !$0.isMastered }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(interview.company)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            Text("\(interview.position) · \(interview.round)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        CategoryPill(text: interview.result.rawValue, color: interview.result.color)
                    }

                    Text(interview.summary)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .lineSpacing(4)
                }
                .padding(18)
                .background(.white, in: RoundedRectangle(cornerRadius: 20, style: .continuous))

                SectionHeader(title: "面试问题", subtitle: "长按问题可以编辑、切换掌握状态或删除")

                if questions.isEmpty {
                    EmptyStateView(icon: "questionmark.bubble", title: "暂无问题", subtitle: "把面试中被问到的问题逐条记录下来。")
                } else {
                    VStack(alignment: .leading, spacing: 10) {
                        Toggle("只显示未掌握问题", isOn: $showsOnlyUnmastered)
                        Text("当前显示 \(displayedQuestions.count) / 全部 \(questions.count) 题")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(16)
                    .background(.white, in: RoundedRectangle(cornerRadius: 18, style: .continuous))

                    if displayedQuestions.isEmpty {
                        EmptyStateView(icon: "checkmark.seal", title: "没有未掌握问题", subtitle: "当前面试的问题已经全部掌握。")
                    }

                    VStack(spacing: 12) {
                        ForEach(displayedQuestions) { question in
                            QuestionCard(question: question)
                                .contextMenu {
                                    Button("编辑") {
                                        editingQuestion = question
                                    }
                                    Button(question.isMastered ? "标记为未掌握" : "标记为已掌握") {
                                        question.isMastered.toggle()
                                    }
                                    Button(role: .destructive) {
                                        modelContext.delete(question)
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
        .navigationTitle("复盘详情")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isAddingQuestion = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $isAddingQuestion) {
            QuestionEditorView(interview: interview, question: nil)
        }
        .sheet(item: $editingQuestion) { question in
            QuestionEditorView(interview: interview, question: question)
        }
    }
}

struct QuestionCard: View {
    let question: QuestionRecord

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                CategoryPill(text: question.category.rawValue, color: Color.flightBlue)
                CategoryPill(
                    text: question.isMastered ? "已掌握" : "未掌握",
                    color: question.isMastered ? Color.flightGreen : Color.flightOrange
                )
                Spacer()
                Label("难度 \(question.difficulty)", systemImage: "flame")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text(question.content)
                .font(.headline)

            if !question.myAnswer.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("我的回答")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                    Text(question.myAnswer)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            if !question.improvement.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("改进建议")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.flightOrange)
                    Text(question.improvement)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(16)
        .background(.white, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

struct QuestionEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let interview: InterviewRecord
    let question: QuestionRecord?

    @State private var content: String
    @State private var category: QuestionCategory
    @State private var difficulty: Double
    @State private var myAnswer: String
    @State private var improvement: String
    @State private var isMastered: Bool

    init(interview: InterviewRecord, question: QuestionRecord?) {
        self.interview = interview
        self.question = question
        _content = State(initialValue: question?.content ?? "")
        _category = State(initialValue: question?.category ?? .swift)
        _difficulty = State(initialValue: Double(question?.difficulty ?? 3))
        _myAnswer = State(initialValue: question?.myAnswer ?? "")
        _improvement = State(initialValue: question?.improvement ?? "")
        _isMastered = State(initialValue: question?.isMastered ?? false)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("问题") {
                    TextField("被问到的问题", text: $content, axis: .vertical)
                    Picker("分类", selection: $category) {
                        ForEach(QuestionCategory.allCases) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                    Text("难度：\(Int(difficulty))")
                    Slider(value: $difficulty, in: 1...5, step: 1)
                }

                Section("复盘") {
                    TextField("我的回答", text: $myAnswer, axis: .vertical)
                        .lineLimit(3...8)
                    TextField("改进建议", text: $improvement, axis: .vertical)
                        .lineLimit(3...8)
                    Toggle("已掌握", isOn: $isMastered)
                }
            }
            .navigationTitle(question == nil ? "新增问题" : "编辑问题")
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
                    .disabled(content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }

    private func save() {
        if let question {
            question.content = content
            question.categoryRawValue = category.rawValue
            question.difficulty = Int(difficulty)
            question.myAnswer = myAnswer
            question.improvement = improvement
            question.isMastered = isMastered
        } else {
            let newQuestion = QuestionRecord(
                interviewID: interview.id,
                content: content,
                categoryRawValue: category.rawValue,
                difficulty: Int(difficulty),
                myAnswer: myAnswer,
                improvement: improvement,
                isMastered: isMastered
            )
            modelContext.insert(newQuestion)
        }

        dismiss()
    }
}
