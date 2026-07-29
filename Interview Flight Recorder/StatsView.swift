//
//  StatsView.swift
//  Interview Flight Recorder
//
//  Created by wyy on 2026/6/11.
//

import Charts
import SwiftData
import SwiftUI

struct StatsView: View {
    @Query private var interviews: [InterviewRecord]
    @Query private var questions: [QuestionRecord]

    private var averageScore: Int {
        guard !interviews.isEmpty else { return 0 }
        return interviews.map(\.score).reduce(0, +) / interviews.count
    }

    private var categoryStats: [CategoryStat] {
        let groups = Dictionary(grouping: questions, by: { $0.category.rawValue })
        return groups.map { CategoryStat(category: $0.key, count: $0.value.count) }
            .sorted { $0.count > $1.count }
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

                        Chart(interviews.sorted(by: { $0.date < $1.date })) { interview in
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

struct CategoryStat: Identifiable {
    let id = UUID()
    let category: String
    let count: Int
}
