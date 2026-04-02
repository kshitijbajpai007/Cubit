//  StagePracticeTimerView.swift
//  Views/Tutorial
//
//  HIG Compliant: NavigationStack, system typography, proper spacing


import SwiftUI

// MARK: - Stage Practice Session

class StagePracticeSession: ObservableObject {
    let stage: SolveStage
    @Published var times: [Double] = []
    
    init(stage: SolveStage) { self.stage = stage }
    
    var best: Double? { times.min() }
    var mean: Double? {
        guard !times.isEmpty else { return nil }
        return times.reduce(0, +) / Double(times.count)
    }
    func ao(_ n: Int) -> Double? {
        guard times.count >= n else { return nil }
        let last = Array(times.suffix(n)).sorted()
        let trimmed = last.dropFirst().dropLast()
        return trimmed.reduce(0, +) / Double(trimmed.count)
    }
}

// MARK: - Main View

struct StagePracticeTimerView: View {
    let stage: SolveStage
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var timerViewModel: TimerViewModel
    @StateObject private var session: StagePracticeSession
    @State private var currentTime: Double = 0
    @State private var timerState: TimerState = .idle
    @State private var isHoldingDown = false
    @State private var holdTimer: Timer?
    @State private var countdownTimer: Timer?
    @State private var startDate: Date?
    @State private var cubeState: CubeState
    @State private var showHistory = false
    
    init(stage: SolveStage) {
        self.stage = stage
        _session = StateObject(wrappedValue: StagePracticeSession(stage: stage))
        _cubeState = State(initialValue: StageScrambleGenerator.generate(for: stage))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Cube
                VStack(spacing: 16) {
                    Cube3DView(cubeState: cubeState)
                        .padding(.top, 8)
                    
                    // Stage label
                    stageBadge
                }
                
                // Timer circle
                timerCircle
                    .padding(.vertical, 16)
                
                // Stats
                if !session.times.isEmpty {
                    statsCard
                        .padding(.horizontal, 16)
                }
                
                // Controls
                bottomControls
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
            }
        }
        .scrollIndicators(.hidden)
        .background(Color(uiColor: .systemBackground))
        .navigationTitle("\(stage.displayName) Practice")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                // Empty - relying on system back button
                EmptyView()
            }
        }
        .sheet(isPresented: $showHistory) {
            NavigationStack {
                historySheet
            }
        }
    }
    
    // MARK: - Components
    
    private var stageBadge: some View {
        HStack(spacing: 6) {
            Image(systemName: stageIcon)
                .font(.caption)
                .fontWeight(.semibold)
            Text(stage.displayName)
                .font(.caption)
                .fontWeight(.semibold)
        }
        .foregroundStyle(.primary)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color(uiColor: .tertiarySystemFill))
        .clipShape(Capsule())
    }
    
    private var timerCircle: some View {
        ZStack {
            Circle()
                .stroke(ringColor, lineWidth: ringWidth)
                .frame(width: 280, height: 280)
                .animation(.easeInOut(duration: 0.25), value: timerState)
            
            Circle()
                .fill(ringColor.opacity(0.08))
                .frame(width: 280, height: 280)
            
            VStack(spacing: 8) {
                Text(formatTime(currentTime))
                    .font(.system(size: 80, weight: .light, design: .rounded))
                    .foregroundColor(ringColor)
                    .monospacedDigit()
                
                Text(hint)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .contentShape(Circle())
        .gesture(timerGesture)
    }
    
    private var timerGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { _ in
                guard !isHoldingDown else { return }
                isHoldingDown = true
                handleDown()
            }
            .onEnded { _ in handleUp() }
    }
    
    private var statsCard: some View {
        HStack(spacing: 0) {
            statCell("Best", value: SolveStatistics.formatTime(session.best))
            Divider().frame(height: 40)
            statCell("Ao5", value: SolveStatistics.formatTime(session.ao(5)))
            Divider().frame(height: 40)
            statCell("Mean", value: SolveStatistics.formatTime(session.mean))
            Divider().frame(height: 40)
            statCell("Count", value: "\(session.times.count)")
        }
        .padding(.vertical, 16)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
    
    private func statCell(_ label: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.headline)
                .monospacedDigit()
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
    
    private var bottomControls: some View {
        HStack(spacing: 16) {
            controlButton(icon: "list.number", color: .primary) {
                showHistory = true
            }
        }
    }
    
    private func controlButton(icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.title3)
                .fontWeight(.medium)
                .foregroundStyle(color)
                .frame(width: 56, height: 56)
                .background(color.opacity(0.12))
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }
    
    private var historySheet: some View {
        List {
            ForEach(Array(session.times.reversed().enumerated()), id: \.offset) { i, time in
                HStack {
                    Text("#\(session.times.count - i)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(width: 36, alignment: .leading)
                    
                    Text(formatTime(time))
                        .font(.body)
                        .fontWeight(.semibold)
                        .monospacedDigit()
                    
                    Spacer()
                    
                    if time == session.best {
                        Text("PB")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.primary)
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("\(stage.displayName) Times")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") { showHistory = false }
            }
        }
    }
    
    // MARK: - Timer Logic
    
    private func handleDown() {
        switch timerState {
        case .running:
            stopTimer()
            isHoldingDown = false
        case .stopped:
            resetTimer()
            isHoldingDown = false
        case .idle:
            holdTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
                if isHoldingDown { setReady() }
            }
        case .ready:
            break
        }
    }
    
    private func handleUp() {
        holdTimer?.invalidate()
        holdTimer = nil
        if timerState == .ready { startTimer() }
        else if timerState == .idle { resetTimer() }
        isHoldingDown = false
    }
    
    private func setReady() {
        timerState = .ready
        HapticManager.timerReady()
    }
    
    private func startTimer() {
        timerState = .running
        startDate = Date()
        currentTime = 0
        HapticManager.timerStart()
        
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
            if let start = startDate {
                currentTime = Date().timeIntervalSince(start)
            }
        }
    }
    
    private func stopTimer() {
        countdownTimer?.invalidate()
        countdownTimer = nil
        timerState = .stopped
        HapticManager.timerStop()
        
        session.times.append(currentTime)
        timerViewModel.addPracticeSolve(time: currentTime, stage: stage)
        newScramble()
    }
    
    private func resetTimer() {
        countdownTimer?.invalidate()
        countdownTimer = nil
        timerState = .idle
        currentTime = 0
    }
    
    private func newScramble() {
        cubeState = StageScrambleGenerator.generate(for: stage)
    }
    
    // MARK: - Helpers
    
    private var ringColor: Color {
        switch timerState {
        case .idle: return .primary.opacity(0.1)
        case .ready: return .primary
        case .running: return .secondary.opacity(0.3)
        case .stopped: return .primary
        }
    }
    
    private var ringWidth: CGFloat {
        switch timerState {
        case .idle: return 4
        case .ready: return 8
        case .running: return 2
        case .stopped: return 4
        }
    }
    
    private var hint: String {
        switch timerState {
        case .idle: return "Hold to start"
        case .ready: return "Release to go"
        case .running: return "Tap to stop"
        case .stopped: return "Tap to reset"
        }
    }
    
    private var stageIcon: String {
        switch stage {
        case .cross: return "plus"
        case .f2l: return "square.stack.3d.down.right"
        case .oll: return "circle.grid.cross"
        case .pll: return "arrow.triangle.2.circlepath"
        }
    }
    
    private func formatTime(_ s: Double) -> String {
        let min = Int(s) / 60
        let sec = Int(s) % 60
        let ms = Int((s.truncatingRemainder(dividingBy: 1)) * 100)
        return min > 0
            ? String(format: "%d:%02d.%02d", min, sec, ms)
            : String(format: "%d.%02d", sec, ms)
    }
}

#Preview {
    NavigationStack {
        StagePracticeTimerView(stage: .f2l)
    }
}
