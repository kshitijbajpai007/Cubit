//  StatisticsView.swift
//  Views/Components

import SwiftUI
import Charts

struct StatisticsView: View {
    @EnvironmentObject var timerViewModel: TimerViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        if nonPracticeSolves.isEmpty {
                            emptyState
                                .padding(.top, 80)
                        } else {
                            // Solve Calendar Heatmap
                            SolveCalendarHeatmapView(solves: nonPracticeSolves, selectedDay: $selectedDay) { day in
                                selectedDayForSolves = day
                            }
                                .padding(.horizontal, 16)

                            // AI Coach Card (embedded directly)
                            if #available(iOS 26.0, *) {
                                StatsCoachCard()
                                    .padding(.horizontal, 16)
                            }

                            keyStatsGrid
                                .padding(.horizontal, 16)

                            if #available(iOS 16.0, *) {
                                timeDistributionChart
                                    .padding(.horizontal, 16)
                            }

                            sessionTimelineChart
                                .padding(.horizontal, 16)

                            recordsSection
                                .padding(.horizontal, 16)
                            
                            stagePracticeSection
                                .padding(.horizontal, 16)
                        }
                    }
                    .padding(.vertical, 16)
                }
                .scrollIndicators(.hidden)
            }
            .navigationTitle("Statistics")
            .navigationBarTitleDisplayMode(.large)
            .sheet(item: $selectedDayForSolves) { day in
                SolvesByDaySheet(date: day.date, solves: solvesForDate(day.date))
            }
        }
    }
    
    @State private var selectedDay: DaySolveData?
    @State private var selectedDayForSolves: DaySolveData?
    
    private func solvesForDate(_ date: Date) -> [TimerSolve] {
        nonPracticeSolves.filter { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }

    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 72))
                .foregroundStyle(.secondary)
                .symbolRenderingMode(.hierarchical)

            Text("No Solves Yet")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Start timing solves to see your statistics and track your progress")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
    }

    // MARK: - Key Stats Grid
    private var keyStatsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            statCard("Best Single", value: bestSingle, icon: "trophy.fill", color: .primary)
            statCard("Mean", value: mean, icon: "chart.line.uptrend.xyaxis", color: .secondary)
            statCard("Ao5", value: ao5, icon: "5.square.fill", color: .secondary)
            statCard("Ao12", value: ao12, icon: "number.square.fill", color: .secondary)
        }
    }

    private func statCard(_ title: String, value: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundStyle(color)
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .monospacedDigit()
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    // MARK: - Charts
    @available(iOS 16.0, *)
    private var timeDistributionChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Time Distribution")
                .font(.headline)

            Chart(chartData, id: \.0) { item in
                BarMark(
                    x: .value("Time", item.0),
                    y: .value("Count", item.1)
                )
                .foregroundStyle(.indigo.gradient)
            }
            .frame(height: 200)
            .chartXAxis {
                AxisMarks(values: .automatic) { _ in
                    AxisValueLabel()
                        .font(.caption2)
                }
            }
            .chartYAxis {
                AxisMarks { _ in
                    AxisValueLabel()
                        .font(.caption2)
                }
            }
        }
        .padding(16)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    @available(iOS 16.0, *)
    private var sessionTimelineChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Session Timeline")
                .font(.headline)

            Chart(Array(timerViewModel.currentSession.solves.enumerated()), id: \.element.id) { index, solve in
                if let time = solve.cleanTime {
                    LineMark(
                        x: .value("Solve", index + 1),
                        y: .value("Time", time)
                    )
                    .foregroundStyle(.indigo)
                    .lineStyle(StrokeStyle(lineWidth: 2))

                    PointMark(
                        x: .value("Solve", index + 1),
                        y: .value("Time", time)
                    )
                    .foregroundStyle(.indigo)
                }
            }
            .frame(height: 200)
            .chartXAxis {
                AxisMarks(values: .automatic) { _ in
                    AxisValueLabel()
                        .font(.caption2)
                }
            }
            .chartYAxis {
                AxisMarks { _ in
                    AxisValueLabel()
                        .font(.caption2)
                }
            }
        }
        .padding(16)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    // MARK: - Records
    private var recordsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Records")
                .font(.headline)

            VStack(spacing: 0) {
                recordRow("Best Ao5", value: bestAo5)
                Divider().padding(.leading, 16)
                recordRow("Best Ao12", value: bestAo12)
                Divider().padding(.leading, 16)
                recordRow("Best Ao100", value: bestAo100)

                if let stdDev = statistics.standardDeviation {
                    Divider().padding(.leading, 16)
                    recordRow("Std Deviation", value: String(format: "%.2fs", stdDev))
                }
            }
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }

    private func recordRow(_ title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.primary)

            Spacer()

            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .monospacedDigit()
                .foregroundStyle(.secondary)
        }
        .padding(16)
    }

    // MARK: - Stage Practice Section
    private var stagePracticeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Stage Practice")
                .font(.headline)
            
            VStack(spacing: 0) {
                ForEach(SolveStage.allCases) { stage in
                    let solves = practiceSolves.filter { $0.practiceStage == stage }
                    if !solves.isEmpty {
                        practiceRow(stage.displayName, stats: SolveStatistics(solves: solves))
                        if stage != SolveStage.allCases.last {
                            Divider().padding(.leading, 16)
                        }
                    }
                }
            }
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }

    private func practiceRow(_ title: String, stats: SolveStatistics) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text("\(stats.solves.count) solves")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(SolveStatistics.formatTime(stats.currentSingle))
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .monospacedDigit()
                Text("Best")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            
            Divider().frame(height: 24).padding(.horizontal, 8)
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(SolveStatistics.formatTime(stats.mean))
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
                Text("Mean")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
    }

    // MARK: - Data Computations
    private var nonPracticeSolves: [TimerSolve] {
        timerViewModel.currentSession.solves.filter { $0.practiceStage == nil }
    }
    
    private var practiceSolves: [TimerSolve] {
        timerViewModel.currentSession.solves.filter { $0.practiceStage != nil }
    }

    private var statistics: SolveStatistics { SolveStatistics(solves: nonPracticeSolves) }
    private var bestSingle: String { SolveStatistics.formatTime(statistics.currentSingle) }
    private var mean: String { SolveStatistics.formatTime(statistics.mean) }
    private var ao5: String { SolveStatistics.formatTime(statistics.average(of: 5)) }
    private var ao12: String { SolveStatistics.formatTime(statistics.average(of: 12)) }
    private var bestAo5: String { SolveStatistics.formatTime(statistics.bestAverage(of: 5)) }
    private var bestAo12: String { SolveStatistics.formatTime(statistics.bestAverage(of: 12)) }
    private var bestAo100: String { SolveStatistics.formatTime(statistics.bestAverage(of: 100)) }

    private var chartData: [(String, Int)] {
        let times = nonPracticeSolves.compactMap { $0.cleanTime }
        guard !times.isEmpty else { return [] }

        let min = times.min() ?? 0
        let max = times.max() ?? 0
        let range = max - min
        guard range > 0 else { return [] }

        let bucketSize = range / 10
        var buckets: [Double: Int] = [:]

        for time in times {
            let bucket = floor((time - min) / bucketSize) * bucketSize + min
            buckets[bucket, default: 0] += 1
        }

        return buckets.sorted(by: { $0.key < $1.key }).map {
            (String(format: "%.1fs", $0.key), $0.value)
        }
    }
}

// MARK: - Embedded AI Coach Card Component
@available(iOS 26.0, *)
struct StatsCoachCard: View {
    @EnvironmentObject var timerViewModel: TimerViewModel
    @StateObject private var coach = SolveCoach()
    @State private var selectedMode: CoachingMode = .dnaAnalysis
    @State private var showFullHistory = false
    
    private var dnaSolves: [TimerSolve] {
        timerViewModel.currentSession.dnaSolves
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label {
                    Text("AI Coach")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                } icon: {
                    Image(systemName: "brain.head.profile")
                        .foregroundStyle(.indigo)
                }
                
                Spacer()
                
                if dnaSolves.count >= 5 {
                    Menu {
                        Button("DNA Analysis") { triggerCoaching(mode: .dnaAnalysis) }
                        Button("Trend Analysis") { triggerCoaching(mode: .trendAnalysis) }
                        Button("Technique Focus") { triggerCoaching(mode: .techniqueFocus) }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            coachingStateView
            
            if case .done = coach.state {
                HStack(spacing: 12) {
                    Button(action: { triggerCoaching(mode: selectedMode) }) {
                        Label("Refresh", systemImage: "arrow.clockwise")
                            .font(.caption)
                    }
                    .buttonStyle(.bordered)
                    .tint(.indigo)
                    
                    if !coach.coachingHistory.isEmpty {
                        Button(action: { showFullHistory = true }) {
                            Label("History", systemImage: "clock")
                                .font(.caption)
                        }
                        .buttonStyle(.bordered)
                        .tint(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.indigo.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.indigo.opacity(0.15), lineWidth: 1)
                )
        )
        .sheet(isPresented: $showFullHistory) {
            CoachingHistoryView(history: coach.coachingHistory)
        }
        .onAppear {
            if dnaSolves.count >= 2 {
                triggerCoaching(mode: selectedMode)
            }
        }
        .onChange(of: dnaSolves.count) { _ in
            if dnaSolves.count >= 2 {
                triggerCoaching(mode: selectedMode)
            }
        }
    }
    
    @ViewBuilder
    private var coachingStateView: some View {
        switch coach.state {
        case .loading:
            HStack(spacing: 12) {
                ProgressView().scaleEffect(0.8)
                Text("Analyzing your solves...")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 8)
        case .done(let feedback):
            Text(feedback)
                .font(.subheadline)
                .lineSpacing(4)
                .transition(.opacity.combined(with: .move(edge: .bottom)))
        case .failed(let error):
            Label(error, systemImage: "exclamationmark.triangle")
                .font(.caption)
                .foregroundStyle(.secondary)
        case .unavailable(let reason):
            Label(reason, systemImage: "brain.head.profile.fill")
                .font(.caption)
                .foregroundStyle(.secondary)
        case .idle:
            Text("Complete at least 2 DNA solves to get AI feedback.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
    
    private func triggerCoaching(mode: CoachingMode) {
        selectedMode = mode
        
        var f2lTotal: Double = 0
        var f2lCount: Int = 0
        var llTotal: Double = 0
        var llCount: Int = 0
        
        // Manually extract times by index to bypass SolveStage issues
        for solve in dnaSolves {
            let splits = solve.splits
            if splits.count > 0 {
                f2lTotal += splits[0].duration
                f2lCount += 1
            }
            if splits.count > 1 {
                llTotal += splits[1].duration
                llCount += 1
            }
        }
        
        // Build the [SolveStage: Double] dictionary
        var averages: [SolveStage: Double] = [:]
        if f2lCount > 0 { averages[.f2l] = f2lTotal / Double(f2lCount) }
        if llCount > 0 { averages[.oll] = llTotal / Double(llCount) }
        
        let totalAverage = averages.values.reduce(0, +)
        
        // Determine weakest stage
        let f2lAvg = averages[.f2l] ?? 0
        let llAvg = averages[.oll] ?? 0
        let weakestStage: SolveStage = f2lAvg > llAvg ? .f2l : .oll
        
        let weakestAvg = averages[weakestStage] ?? 0
        let weakestPct = totalAverage > 0 ? Int((weakestAvg / totalAverage) * 100) : 0
        
        let recentSolves = Array(timerViewModel.currentSession.solves.suffix(10))
        let bestSingle = dnaSolves.compactMap { $0.cleanTime }.min()
        
        let isMilestone = [10, 25, 50, 100, 250, 500, 1000].contains(dnaSolves.count)
        
        let input = DNACoachInput(
            solveCount: dnaSolves.count,
            averages: averages,
            weakestStage: weakestStage,
            weakestPct: weakestPct,
            bestSingle: bestSingle,
            methodName: timerViewModel.dnaMethod.rawValue,
            recentSolves: recentSolves,
            previousAdvice: coach.lastAdvice
        )
        
        coach.generateAdvice(for: input, mode: isMilestone ? .milestone : selectedMode)
    }
}

// MARK: - Coaching History View
struct CoachingHistoryView: View {
    let history: [SolveCoach.CoachingEntry]
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(history.reversed()) { entry in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Label(entry.mode == .milestone ? "Milestone" : "Analysis",
                                  systemImage: entry.mode == .milestone ? "trophy" : "brain")
                                .font(.caption)
                                .foregroundStyle(.indigo)
                            
                            Spacer()
                            
                            Text(entry.date, style: .relative)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        
                        Text(entry.advice)
                            .font(.subheadline)
                        
                        Text("After \(entry.solveCount) solves")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Coaching History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Solve Calendar Heatmap (from your original file)
struct SolveCalendarHeatmapView: View {
    let solves: [TimerSolve]
    @Binding var selectedDay: DaySolveData?
    var onViewTimes: (DaySolveData) -> Void
    
    private let weeksToShow = 20
    private let cellSize: CGFloat = 13
    private let cellSpacing: CGFloat = 3
    
    private let emptyColor = Color.primary.opacity(0.05)
    private let level1 = Color.indigo.opacity(0.2)
    private let level2 = Color.indigo.opacity(0.4)
    private let level3 = Color.indigo.opacity(0.7)
    private let level4 = Color.indigo
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label {
                    Text("Solve Calendar")
                        .font(.headline)
                } icon: {
                    Image(systemName: "calendar")
                        .foregroundStyle(.primary)
                }
                
                Spacer()
                
                Text("\(totalSolvesInRange) solves")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            

            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 6) {
                        monthLabelsRow
                        heatmapGrid
                    }
                    .padding(.vertical, 4)
                    .id("HeatmapContent")
                }
                .onAppear {
                    proxy.scrollTo("HeatmapContent", anchor: .trailing)
                }
            }
            
            if let day = selectedDay {
                HStack(spacing: 8) {
                    Circle()
                        .fill(colorForCount(day.count))
                        .frame(width: 10, height: 10)
                    Text("\(day.count) solve\(day.count == 1 ? "" : "s") on \(day.date, format: .dateTime.month(.wide).day().year())")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    if day.count > 0 {
                        Button {
                            onViewTimes(day)
                        } label: {
                            HStack(spacing: 4) {
                                Text("View Times")
                                Image(systemName: "chevron.right")
                            }
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundStyle(.indigo)
                        }
                        .padding(.leading, 8)
                    }
                }
                .transition(.opacity)
            }
            
            legendRow
        }
        .padding(16)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .animation(.easeInOut(duration: 0.2), value: selectedDay?.date)
    }
    
    private var monthLabelsRow: some View {
        let calendar = Calendar.current
        let today = Date()
        let totalDays = weeksToShow * 7
        let startDate = calendar.date(byAdding: .day, value: -(totalDays - 1), to: today)!
        
        let columnWidth = cellSize + cellSpacing
        
        var labels: [(String, CGFloat)] = []
        var lastMonth = -1
        
        for week in 0..<weeksToShow {
            let weekStartDate = calendar.date(byAdding: .day, value: week * 7, to: startDate)!
            let month = calendar.component(.month, from: weekStartDate)
            
            if month != lastMonth {
                let monthName = calendar.shortMonthSymbols[month - 1]
                labels.append((monthName, CGFloat(week) * columnWidth))
                lastMonth = month
            }
        }
        
        return ZStack(alignment: .leading) {
            ForEach(labels, id: \.1) { label, offset in
                Text(label)
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
                    .offset(x: offset)
            }
        }
        .frame(height: 14, alignment: .leading)
        // Removed maxWidth: .infinity to allow ScrollView to size correctly
        .frame(width: CGFloat(weeksToShow) * columnWidth, alignment: .leading)
    }
    
    // Kept for backward compatibility if used elsewhere, but marked as private so it shouldn't be
    private var monthLabels: some View { EmptyView() }
    
    private var heatmapGrid: some View {
        let data = buildGridData()
        
        return HStack(alignment: .top, spacing: cellSpacing) {
            ForEach(0..<data.count, id: \.self) { weekIndex in
                VStack(spacing: cellSpacing) {
                    ForEach(0..<data[weekIndex].count, id: \.self) { dayIndex in
                        let dayData = data[weekIndex][dayIndex]
                        
                        RoundedRectangle(cornerRadius: 2, style: .continuous)
                            .fill(colorForCount(dayData.count))
                            .frame(width: cellSize, height: cellSize)
                            .onTapGesture {
                                withAnimation {
                                    if selectedDay?.date == dayData.date {
                                        selectedDay = nil
                                    } else {
                                        selectedDay = dayData
                                    }
                                }
                            }
                    }
                }
            }
        }
    }
    
    private var legendRow: some View {
        HStack(spacing: 4) {
            Spacer()
            
            Text("Less")
                .font(.system(size: 10))
                .foregroundStyle(.secondary)
            
            ForEach([emptyColor, level1, level2, level3, level4], id: \.self) { color in
                RoundedRectangle(cornerRadius: 2, style: .continuous)
                    .fill(color)
                    .frame(width: cellSize, height: cellSize)
            }
            
            Text("More")
                .font(.system(size: 10))
                .foregroundStyle(.secondary)
        }
    }
    
    private var totalSolvesInRange: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let totalDays = weeksToShow * 7
        let startDate = calendar.date(byAdding: .day, value: -(totalDays - 1), to: today)!
        
        return solves.filter { solve in
            let solveDay = calendar.startOfDay(for: solve.date)
            return solveDay >= startDate && solveDay <= today
        }.count
    }
    
    private func buildGridData() -> [[DaySolveData]] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let totalDays = weeksToShow * 7
        let startDate = calendar.date(byAdding: .day, value: -(totalDays - 1), to: today)!
        
        var countsByDay: [Date: Int] = [:]
        for solve in solves {
            let day = calendar.startOfDay(for: solve.date)
            countsByDay[day, default: 0] += 1
        }
        
        var weeks: [[DaySolveData]] = []
        var currentDate = startDate
        
        let weekday = calendar.component(.weekday, from: currentDate)
        let alignedStart = calendar.date(byAdding: .day, value: -(weekday - 1), to: currentDate)!
        currentDate = alignedStart
        
        while currentDate <= today {
            var week: [DaySolveData] = []
            for _ in 0..<7 {
                let count = countsByDay[currentDate] ?? 0
                let isFuture = currentDate > today
                week.append(DaySolveData(
                    date: currentDate,
                    count: isFuture ? -1 : count
                ))
                currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
            }
            weeks.append(week)
        }
        
        return weeks
    }
    
    private func colorForCount(_ count: Int) -> Color {
        if count < 0 { return Color.clear }
        switch count {
        case 0: return emptyColor
        case 1...2: return level1
        case 3...5: return level2
        case 6...9: return level3
        default: return level4
        }
    }
}

struct DaySolveData: Identifiable {
    let date: Date
    let count: Int
    var id: Date { date }
}

struct SolvesByDaySheet: View {
    let date: Date
    let solves: [TimerSolve]
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(Array(solves.enumerated()), id: \.element.id) { index, solve in
                        SolveRow(solve: solve, number: index + 1)
                    }
                } header: {
                    Text("\(solves.count) Solves")
                }
            }
            .navigationTitle(date.formatted(date: .abbreviated, time: .omitted))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
