//
//  SettingsView.swift
//  Interview Flight Recorder
//
//  Created by wyy on 2026/6/11.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    SectionHeader(title: "项目说明", subtitle: "这个 App 用来证明完整 iOS 产品能力")

                    VStack(alignment: .leading, spacing: 12) {
                        InfoRow(icon: "swift", title: "SwiftUI", text: "负责多页面 UI、表单、导航和状态驱动界面。")
                        InfoRow(icon: "externaldrive", title: "SwiftData", text: "保存面试记录、问题和复习任务。")
                        InfoRow(icon: "chart.bar", title: "Swift Charts", text: "展示问题分布和面试评分趋势。")
                        InfoRow(icon: "square.stack.3d.up", title: "产品闭环", text: "记录面试、复盘问题、生成复习任务、统计薄弱点。")
                    }
                    .padding(16)
                    .background(.white, in: RoundedRectangle(cornerRadius: 18, style: .continuous))

                    VStack(alignment: .leading, spacing: 10) {
                        Text("面试时可以这样介绍")
                            .font(.headline)
                        Text("Interview Flight Recorder 是一个面试复盘与成长系统。我使用 SwiftUI 构建多页面交互，使用 SwiftData 持久化面试记录、问题和复习任务，并通过 Swift Charts 可视化薄弱点分布和评分趋势。项目体现了数据建模、增删改查、页面跳转、状态管理和产品闭环能力。")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineSpacing(4)
                    }
                    .padding(16)
                    .background(.white, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
                .padding(16)
            }
            .background(Color.appBackground)
            .navigationTitle("设置")
        }
    }
}

struct InfoRow: View {
    let icon: String
    let title: String
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(Color.flightBlue)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(text)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
