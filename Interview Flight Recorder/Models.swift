//
//  Models.swift
//  Interview Flight Recorder
//
//  Created by wyy on 2026/6/11.
//

import Foundation
import SwiftData

@Model
final class InterviewRecord {
    var id: UUID
    var company: String
    var position: String
    var date: Date
    var round: String
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
        // Keep malformed legacy values from propagating into the UI.
        InterviewResult(rawValue: resultRawValue) ?? .pending
    }
}

@Model
final class QuestionRecord {
    // A lightweight UUID association avoids coupling the models through SwiftData relationships.
    var interviewID: UUID
    var content: String
    var categoryRawValue: String
    var difficulty: Int
    var myAnswer: String
    var improvement: String
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
        QuestionCategory(rawValue: categoryRawValue) ?? .project
    }
}

@Model
final class ReviewTaskRecord {
    var title: String
    var categoryRawValue: String
    var priority: Int
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
