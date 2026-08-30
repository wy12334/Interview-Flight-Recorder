//
//  DataSeeder.swift
//  Interview Flight Recorder
//
//  Created by wyy on 2026/6/11.
//

import Foundation
import SwiftData

enum DataSeeder {
    // Empty-store detection is sufficient for demo data; production seeding would use a versioned flag.
    static func seedIfNeeded(modelContext: ModelContext, interviewCount: Int) {
        guard interviewCount == 0 else {
            return
        }

        let careerOS = InterviewRecord(
            company: "星河科技",
            position: "iOS 开发工程师",
            date: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(),
            round: "一面",
            resultRawValue: InterviewResult.pending.rawValue,
            score: 72,
            summary: "SwiftUI 项目讲得比较清楚，但并发和内存管理回答不够系统。"
        )

        let internship = InterviewRecord(
            company: "晨光互联",
            position: "移动端开发实习生",
            date: Calendar.current.date(byAdding: .day, value: -8, to: Date()) ?? Date(),
            round: "HR 面",
            resultRawValue: InterviewResult.passed.rawValue,
            score: 84,
            summary: "表达自然，项目动机讲得不错，需要继续强化技术深度。"
        )

        modelContext.insert(careerOS)
        modelContext.insert(internship)

        let questions = [
            QuestionRecord(
                interviewID: careerOS.id,
                content: "SwiftUI 中 @State 和 @Binding 的区别是什么？",
                categoryRawValue: QuestionCategory.swiftUI.rawValue,
                difficulty: 2,
                myAnswer: "@State 是页面内部状态，@Binding 是父子视图传值。",
                improvement: "补充：状态变化会触发 View 重新计算 body，Binding 本质是对外部状态的引用。"
            ),
            QuestionRecord(
                interviewID: careerOS.id,
                content: "什么是循环引用？如何解决？",
                categoryRawValue: QuestionCategory.memory.rawValue,
                difficulty: 3,
                myAnswer: "两个对象互相强引用会导致无法释放，可以用 weak。",
                improvement: "准备闭包捕获 self 的例子，并说明 weak 与 unowned 的区别。"
            ),
            QuestionRecord(
                interviewID: careerOS.id,
                content: "你的 CareerOS 项目为什么要拆成多个文件？",
                categoryRawValue: QuestionCategory.architecture.rawValue,
                difficulty: 2,
                myAnswer: "为了降低复杂度，让 View、Model、Service 分开。",
                improvement: "用 MVVM 或分层思想进一步说明可维护性和可测试性。"
            ),
            QuestionRecord(
                interviewID: internship.id,
                content: "为什么想做 iOS 开发？",
                categoryRawValue: QuestionCategory.hr.rawValue,
                difficulty: 1,
                myAnswer: "喜欢移动端产品，也希望做用户能直接使用的应用。",
                improvement: "结合 CareerOS 项目讲自己从需求到实现的完整体验。"
            )
        ]

        for question in questions {
            modelContext.insert(question)
        }

        modelContext.insert(
            ReviewTaskRecord(
                title: "复习 ARC、weak、unowned 和闭包循环引用",
                categoryRawValue: QuestionCategory.memory.rawValue,
                priority: 5,
                isDone: false,
                dueDate: Date(),
                note: "准备 1 个代码例子和 1 个面试口述版本。"
            )
        )

        modelContext.insert(
            ReviewTaskRecord(
                title: "整理 SwiftUI 状态管理：@State / @Binding / @Query",
                categoryRawValue: QuestionCategory.swiftUI.rawValue,
                priority: 4,
                isDone: false,
                dueDate: Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date(),
                note: "结合 CareerOS 项目解释。"
            )
        )
    }
}
