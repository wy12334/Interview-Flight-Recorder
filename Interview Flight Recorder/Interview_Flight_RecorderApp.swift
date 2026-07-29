//
//  Interview_Flight_RecorderApp.swift
//  Interview Flight Recorder
//
//  Created by wyy on 2026/6/11.
//

import SwiftUI
import SwiftData

@main
struct Interview_Flight_RecorderApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [
            InterviewRecord.self,
            QuestionRecord.self,
            ReviewTaskRecord.self
        ])
    }
}
