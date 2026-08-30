# Interview Flight Recorder

Interview Flight Recorder 是一款使用 SwiftUI 构建的 iOS 面试复盘应用。它将面试记录、问题沉淀、复习任务和能力趋势整合为一个本地优先的工作流。

## 核心功能

- 面试记录列表与公司名称搜索
- 新增、编辑、删除面试
- 面试详情页
- 面试问题新增、编辑、删除
- 问题分类：Swift、SwiftUI、UIKit、网络、并发、内存管理、架构、项目经验、算法、HR
- 复习计划：新增、编辑、删除、标记完成
- 统计页：问题分类分布图、面试评分趋势图
- SwiftData 本地持久化
- Swift Charts 数据可视化

## 技术实现

| 模块 | 实现 |
| --- | --- |
| UI | SwiftUI、NavigationStack、TabView、可复用组件 |
| 数据 | SwiftData、`@Model`、`@Query`、本地种子数据 |
| 可视化 | Swift Charts 分类分布图与评分趋势图 |
| 业务逻辑 | 搜索匹配、逾期判断、评分校验、分类聚合 |
| 测试 | XCTest，覆盖搜索、逾期、评分边界与分类聚合 |
| 工程环境 | Swift 5、iOS 17.2+、Xcode 15.2+ |

## 页面展示

| 面试列表 | 复习计划 | 数据统计 | 设置页面 |
|---|---|---|---|
| <img src="./页面展示截图/01-面试列表.png" width="220" alt="面试列表"> | <img src="./页面展示截图/08-复习计划.png" width="220" alt="复习计划"> | <img src="./页面展示截图/12-数据统计.png" width="220" alt="数据统计"> | <img src="./页面展示截图/13-设置页面.png" width="220" alt="设置页面"> |

更多新增、编辑、详情和任务状态截图见 [`页面展示截图`](./页面展示截图)。

## 项目结构

- `Interview_Flight_RecorderApp.swift`：App 入口和 SwiftData 容器
- `ContentView.swift`：底部 Tab 导航
- `Theme.swift`：颜色、面试结果、问题分类枚举
- `Models.swift`：SwiftData 数据模型
- `DataSeeder.swift`：首次启动默认数据
- `Components.swift`：公共 UI 组件
- `InterviewsView.swift`：面试列表和面试编辑
- `InterviewDetailView.swift`：面试详情和问题编辑
- `ReviewPlanView.swift`：复习计划
- `StatsView.swift`：统计图表
- `AppLogic.swift`：可独立测试的业务规则
- `SettingsView.swift`：应用信息

## 如何运行

1. 克隆仓库并进入项目目录。
2. 使用 Xcode 15.2 或更高版本打开 `Interview Flight Recorder.xcodeproj`。
3. 选择 iOS 17.2 或更高版本的模拟器并运行。

项目不依赖第三方库。若本地存储结构与当前模型不兼容，可删除模拟器中的旧应用数据后重新运行。

## 设计说明

- 问题通过 `interviewID` 与面试记录关联，保持模型结构轻量。
- 业务判断被拆分为纯函数，避免将搜索、逾期和校验规则耦合到视图中。
- 分类统计采用固定枚举顺序处理同数量数据，保证图表顺序稳定。
