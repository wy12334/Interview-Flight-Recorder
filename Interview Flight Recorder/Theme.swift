//
//  Theme.swift
//  Interview Flight Recorder
//
//  Created by wyy on 2026/6/11.
//

import SwiftUI

extension Color {
    static let appBackground = Color(red: 0.95, green: 0.97, blue: 0.98)
    static let flightBlue = Color(red: 0.08, green: 0.35, blue: 0.86)
    static let flightGreen = Color(red: 0.02, green: 0.55, blue: 0.38)
    static let flightOrange = Color(red: 0.93, green: 0.45, blue: 0.12)
    static let flightRed = Color(red: 0.84, green: 0.16, blue: 0.18)
    static let flightPurple = Color(red: 0.42, green: 0.24, blue: 0.82)
}

enum InterviewResult: String, CaseIterable, Identifiable {
    case pending = "待反馈"
    case passed = "通过"
    case failed = "未通过"
    case offer = "Offer"

    var id: String { rawValue }

    var color: Color {
        switch self {
        case .pending:
            return Color.flightOrange
        case .passed:
            return Color.flightGreen
        case .failed:
            return Color.flightRed
        case .offer:
            return Color.flightPurple
        }
    }
}

enum QuestionCategory: String, CaseIterable, Identifiable {
    case swift = "Swift"
    case swiftUI = "SwiftUI"
    case uiKit = "UIKit"
    case network = "网络"
    case concurrency = "并发"
    case memory = "内存管理"
    case architecture = "架构"
    case project = "项目经验"
    case algorithm = "算法"
    case hr = "HR"

    var id: String { rawValue }
}
