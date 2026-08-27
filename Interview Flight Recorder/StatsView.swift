//
//  StatsView.swift
//  Interview Flight Recorder
//
//  Created by wyy on 2026/6/11.
//统计页

import Charts
import SwiftData
import SwiftUI

// 图表使用的中间数据：把 QuestionRecord 转成更简单的“分类 + 数量”。
struct CategoryStat: Identifiable, Equatable {
    // 分类名称本身唯一而且稳定，适合作为图表数据的 id。
    var id: String { category }
    let category: String
    let count: Int
}

// 纯数据处理函数：不创建 View，也不依赖 Swift Charts，只负责合并和排序分类数量。
func categoryCounts(questions: [QuestionRecord]) -> [CategoryStat] {
    guard !questions.isEmpty else { return [] }

    // 相同 QuestionCategory 会累加到同一个字典键中。
    let counts = questions.reduce(into: [QuestionCategory: Int]()) { result, question in
        result[question.category, default: 0] += 1
    }

    // allCases 给每个分类一个固定位置；数量相同时按这个位置排序，结果不会随机变化。
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
    // 统计页只需要查询数据，不需要 modelContext 写入数据。
    @Query private var interviews: [InterviewRecord]
    @Query private var questions: [QuestionRecord]

    private var averageScore: Int {
        // 防止没有面试时除以 0。
        guard !interviews.isEmpty else { return 0 }
        // 提取所有分数、求和，再除以面试数量。
        return interviews.map(\.score).reduce(0, +) / interviews.count
    }

    private var categoryStats: [CategoryStat] {
        // View 只把原始问题交给数据处理函数，不再负责分组和排序细节。
        categoryCounts(questions: questions)
    }

    private var scoreTrend: [InterviewRecord] {
        // 先按日期从早到晚准备趋势数据，Chart 只负责读取日期和评分。
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
                            // BarMark 展示各类问题出现次数。
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
                            // LineMark 绘制趋势线，PointMark 标出每次面试的数据点。
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
