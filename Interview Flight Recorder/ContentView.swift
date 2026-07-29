//
//  ContentView.swift
//  Interview Flight Recorder
//
//  Created by wyy on 2026/6/11.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var interviews: [InterviewRecord]

    var body: some View {
        TabView {
            InterviewsView()
                .tabItem {
                    Label("面试", systemImage: "person.2.wave.2")
                }

            ReviewPlanView()
                .tabItem {
                    Label("复习", systemImage: "book.closed")
                }

            StatsView()
                .tabItem {
                    Label("统计", systemImage: "chart.bar.xaxis")
                }

            SettingsView()
                .tabItem {
                    Label("设置", systemImage: "gearshape")
                }
        }
        .tint(Color.flightBlue)
        .onAppear {
            DataSeeder.seedIfNeeded(modelContext: modelContext, interviewCount: interviews.count)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
