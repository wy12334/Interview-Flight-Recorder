//
//  Models.swift
//  Interview Flight Recorder
//
//  Created by wyy on 2026/6/11.
//

import Foundation
import SwiftData

// @Model 让普通 Swift 类成为可由 SwiftData 持久化的数据模型。
// 职责：保存一场面试的基础信息、结果、自评分数和复盘总结。
@Model
final class InterviewRecord {
    // 本模型的存储属性都不是 Optional；暂无内容时使用默认值或空字符串。
    var id: UUID
    var company: String
    var position: String
    var date: Date
    var round: String
    // SwiftData 实际存 String，业务代码通过下面的 result 计算属性转换为枚举。
    var resultRawValue: String
    var score: Int
    var summary: String

    init(
        id: UUID = UUID(),
        company: String,
        position: String,
        date: Date,
        round: String,
        resultRawValue: String,
        score: Int,
        summary: String
    ) {
        self.id = id
        self.company = company
        self.position = position
        self.date = date
        self.round = round
        self.resultRawValue = resultRawValue
        self.score = score
        self.summary = summary
    }

    var result: InterviewResult {
        // 如果历史数据无法转换，回退到“待反馈”，保证页面始终得到有效结果。
        InterviewResult(rawValue: resultRawValue) ?? .pending
    }
}

// 职责：保存某场面试中的一道问题、回答、难度和改进建议。
@Model
final class QuestionRecord {
    // 当前项目通过 interviewID 手动记录问题属于哪场面试，这不是 SwiftData @Relationship。
    var interviewID: UUID
    var content: String
    // 分类也以 String 持久化，再通过 category 计算属性转换为枚举。
    var categoryRawValue: String
    var difficulty: Int
    var myAnswer: String
    var improvement: String
    // false 表示仍需复习，true 表示已经掌握；默认 false 兼容新建和已有数据。
    var isMastered: Bool = false
    var createdAt: Date

    init(
        interviewID: UUID,
        content: String,
        categoryRawValue: String,
        difficulty: Int,
        myAnswer: String,
        improvement: String,
        isMastered: Bool = false,
        createdAt: Date = Date()
    ) {
        self.interviewID = interviewID
        self.content = content
        self.categoryRawValue = categoryRawValue
        self.difficulty = difficulty
        self.myAnswer = myAnswer
        self.improvement = improvement
        self.isMastered = isMastered
        self.createdAt = createdAt
    }

    var category: QuestionCategory {
        // rawValue 无效时回退为“项目经验”。
        QuestionCategory(rawValue: categoryRawValue) ?? .project
    }
}

// 职责：保存一项复习行动，包括分类、优先级、完成状态和截止日期。
@Model
final class ReviewTaskRecord {
    var title: String
    var categoryRawValue: String
    var priority: Int
    // 复习页根据这个布尔值把任务分到“待完成”或“已完成”。
    var isDone: Bool
    var dueDate: Date
    var note: String

    init(title: String, categoryRawValue: String, priority: Int, isDone: Bool, dueDate: Date, note: String) {
        self.title = title
        self.categoryRawValue = categoryRawValue
        self.priority = priority
        self.isDone = isDone
        self.dueDate = dueDate
        self.note = note
    }

    var category: QuestionCategory {
        QuestionCategory(rawValue: categoryRawValue) ?? .project
    }
}
