//
//  StatsView.swift
//  Interview Flight Recorder
//
//  Created by wyy on 2026/6/11.

import Charts
import SwiftData
import SwiftUI

struct CategoryStat: Identifiable, Equatable {
    var id: String { category }
    let category: String
    let count: Int
}

func categoryCounts(questions: [QuestionRecord]) -> [CategoryStat] {
    guard !questions.isEmpty else { return [] }

    let counts = questions.reduce(into: [QuestionCategory: Int]()) { result, question in
        result[question.category, default: 0] += 1
    }

    // Enum order keeps chart output deterministic when counts are equal.
    let categoryOrder = Dictionary(
        uniqueKeysWithValues: QuestionCategory.allCases.enumerated().map { ($0.element, $0.offset) }
    )

    return counts
        .map { CategoryStat(category: $0.key.rawValue, count: $0.value) }
        .sorted { lhs, rhs in
            if lhs.count != rhs.count {
                return lhs.count > rhs.count
            }

            let lhsCategory = QuestionCategory(rawValue: lhs.category) ?? .project
            let rhsCategory = QuestionCategory(rawValue: rhs.category) ?? .project
            return categoryOrder[lhsCategory, default: 0] < categoryOrder[rhsCategory, default: 0]
        }
}

struct StatsView: View {
    @Query private var interviews: [InterviewRecord]
    @Query private var questions: [QuestionRecord]

    private var averageScore: Int {
        guard !interviews.isEmpty else { return 0 }
        return interviews.map(\.score).reduce(0, +) / interviews.count
    }

    private var categoryStats: [CategoryStat] {
        categoryCounts(questions: questions)
    }

    private var scoreTrend: [InterviewRecord] {
        interviews.sorted { $0.date < $1.date }
    }

    private var weakestCategory: String {
        categoryStats.first?.category ?? "暂无"
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    SectionHeader(title: "能力统计", subtitle: "用数据找出高频薄弱点")

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        StatCard(title: "平均自评", value: "\(averageScore)", icon: "gauge.with.dots.needle.67percent", color: Color.flightBlue)
                        StatCard(title: "最常被问", value: weakestCategory, icon: "exclamationmark.triangle", color: Color.flightOrange)
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("问题分类分布")
                            .font(.headline)

                        if categoryStats.isEmpty {
                            EmptyStateView(icon: "chart.bar", title: "暂无统计", subtitle: "添加面试问题后，这里会自动生成分类图表。")
                        } else {
                            Chart(categoryStats) { stat in
                                BarMark(
                                    x: .value("数量", stat.count),
                                    y: .value("分类", stat.category)
                                )
                                .foregroundStyle(Color.flightBlue)
                            }
                            .frame(height: 260)
                        }
                    }
                    .padding(16)
                    .background(.white, in: RoundedRectangle(cornerRadius: 18, style: .continuous))

                    VStack(alignment: .leading, spacing: 12) {
                        Text("面试评分趋势")
                            .font(.headline)

                        Chart(scoreTrend) { interview in
                            LineMark(
                                x: .value("日期", interview.date),
                                y: .value("评分", interview.score)
                            )
                            .foregroundStyle(Color.flightGreen)

                            PointMark(
                                x: .value("日期", interview.date),
                                y: .value("评分", interview.score)
                            )
                            .foregroundStyle(Color.flightGreen)
                        }
                        .frame(height: 220)
                    }
                    .padding(16)
                    .background(.white, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
                .padding(16)
            }
            .background(Color.appBackground)
            .navigationTitle("统计")
        }
    }
}
