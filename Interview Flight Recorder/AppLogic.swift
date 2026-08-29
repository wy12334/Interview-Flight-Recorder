//
//  AppLogic.swift
//  Interview Flight Recorder
//
//  可独立测试的业务判断：不创建 View，也不读写 SwiftData。
//

import Foundation

// 搜索前统一去掉首尾空格，空关键词表示不过滤任何公司。
func companyMatchesSearch(company: String, searchText: String) -> Bool {
    let keyword = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !keyword.isEmpty else { return true }
    return company.localizedStandardContains(keyword)
}

// 只比较“日期”而不是当前具体时间；今天到期不算逾期，已完成也不算逾期。
func isReviewTaskOverdue(
    dueDate: Date,
    isDone: Bool,
    now: Date = Date(),
    calendar: Calendar = .current
) -> Bool {
    guard !isDone else { return false }
    return dueDate < calendar.startOfDay(for: now)
}

// 表单与测试共用同一条评分规则，避免两处逻辑以后不一致。
func isInterviewScoreValid(_ score: Double) -> Bool {
    (0...100).contains(score)
}
