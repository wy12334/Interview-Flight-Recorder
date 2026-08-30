//
//  SettingsView.swift
//  Interview Flight Recorder
//
//  Created by wyy on 2026/6/11.

import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    SectionHeader(title: "关于项目", subtitle: "面试记录、复盘任务与能力趋势的一体化工作流")

                    VStack(alignment: .leading, spacing: 12) {
                        InfoRow(icon: "swift", title: "SwiftUI", text: "多页面 UI、表单、导航和状态驱动界面。")
                        InfoRow(icon: "externaldrive", title: "SwiftData", text: "保存面试记录、问题和复习任务。")
                        InfoRow(icon: "chart.bar", title: "Swift Charts", text: "展示问题分布和面试评分趋势。")
                        InfoRow(icon: "square.stack.3d.up", title: "产品闭环", text: "记录面试、复盘问题、生成复习任务、统计薄弱点。")
                    }
                    .padding(16)
                    .background(.white, in: RoundedRectangle(cornerRadius: 18, style: .continuous))

                    VStack(alignment: .leading, spacing: 10) {
                        Text("工程设计")
                            .font(.headline)
                        Text("数据模型、业务规则、公共组件与功能页面相互独立；搜索、逾期判断、评分校验和分类聚合使用纯函数实现，并通过 XCTest 验证关键边界。")
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
