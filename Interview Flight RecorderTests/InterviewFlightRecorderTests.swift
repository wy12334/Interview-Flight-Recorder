//
//  InterviewFlightRecorderTests.swift
//  Interview Flight RecorderTests
//

import XCTest
@testable import Interview_Flight_Recorder

final class InterviewFlightRecorderTests: XCTestCase {
    func testCategoryCountsWithEmptyQuestionsReturnsEmptyArray() {
        let result = categoryCounts(questions: [])

        XCTAssertTrue(result.isEmpty)
    }

    func testCategoryCountsMergesQuestionsWithSameCategory() {
        let interviewID = UUID()
        let questions = [
            makeQuestion(interviewID: interviewID, category: .swiftUI),
            makeQuestion(interviewID: interviewID, category: .swiftUI),
            makeQuestion(interviewID: interviewID, category: .memory)
        ]

        let result = categoryCounts(questions: questions)

        XCTAssertEqual(
            result,
            [
                CategoryStat(category: QuestionCategory.swiftUI.rawValue, count: 2),
                CategoryStat(category: QuestionCategory.memory.rawValue, count: 1)
            ]
        )
    }

    func testCompanySearchIgnoresCaseAndOuterWhitespace() {
        XCTAssertTrue(companyMatchesSearch(company: "Apple", searchText: "  apple  "))
    }

    func testBlankCompanySearchMatchesEveryCompany() {
        XCTAssertTrue(companyMatchesSearch(company: "任意公司", searchText: "   \n"))
    }

    func testOverdueRuleUsesCalendarDayAndCompletionState() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = try XCTUnwrap(TimeZone(secondsFromGMT: 0))
        let now = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 8, day: 30, hour: 15)))
        let yesterday = try XCTUnwrap(calendar.date(byAdding: .day, value: -1, to: now))
        let today = calendar.startOfDay(for: now)

        XCTAssertTrue(isReviewTaskOverdue(dueDate: yesterday, isDone: false, now: now, calendar: calendar))
        XCTAssertFalse(isReviewTaskOverdue(dueDate: today, isDone: false, now: now, calendar: calendar))
        XCTAssertFalse(isReviewTaskOverdue(dueDate: yesterday, isDone: true, now: now, calendar: calendar))
    }

    func testScoreRangeIncludesBoundariesAndRejectsOutsideValues() {
        XCTAssertTrue(isInterviewScoreValid(0))
        XCTAssertTrue(isInterviewScoreValid(100))
        XCTAssertFalse(isInterviewScoreValid(-1))
        XCTAssertFalse(isInterviewScoreValid(101))
    }

    private func makeQuestion(
        interviewID: UUID,
        category: QuestionCategory
    ) -> QuestionRecord {
        QuestionRecord(
            interviewID: interviewID,
            content: "测试问题",
            categoryRawValue: category.rawValue,
            difficulty: 1,
            myAnswer: "",
            improvement: ""
        )
    }
}
