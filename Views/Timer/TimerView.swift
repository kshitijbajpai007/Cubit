//  TimerView.swift
//  Views/Timer


import SwiftUI

struct TimerView: View {
    @EnvironmentObject var timerViewModel: TimerViewModel
    @EnvironmentObject var tutorialViewModel: TutorialViewModel
    @StateObject private var coach = SolveCoach()
    @StateObject private var coachWidget = CoachWidgetViewModel()
    
    @State private var isHoldingDown = false
    @State private var holdTimer: Timer?
    @State private var showSolvesList = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Top Card: Cube visualization + scramble
                    VStack(spacing: 16) {
                        Cube3DView(cubeState: cubeFromScramble(), scale: 0.85)
                            .frame(height: 240) // Reduced height slightly to properly fit
                            .padding(.top, 24)
                        
                        ScrambleView(scramble: timerViewModel.currentScramble)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 16)
                    }
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .padding(.horizontal, 16)
                    
                    // Middle Card: Timer & Controls
                    VStack(spacing: 24) {
                        // Timer circle
                        timerCircle
                            .padding(.top, 32)
                            .padding(.bottom, 8)
                        
                        // DNA controls
                        dnaControls
                            .padding(.horizontal, 16)
                        
                        // Coach Widget - shows tips during solves
                        if timerViewModel.timerState == .running && timerViewModel.isDNAModeActive {
                            CoachWidget(viewModel: coachWidget)
                                .environmentObject(coach)
                                .padding(.horizontal, 16)
                                .onAppear {
                                    // Show tip after 30 seconds into solve if still on F2L
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
                                        if timerViewModel.timerState == .running &&
                                           timerViewModel.currentDNAStage == .firstTwoLayers {
                                            coachWidget.showQuickTip(for: .firstTwoLayers, method: timerViewModel.dnaMethod, using: coach)
                                        }
                                    }
                                }
                        }
                        
                        // Bottom controls
                        bottomControls
                            .padding(.horizontal, 16)
                            .padding(.bottom, 24)
                    }
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .padding(.horizontal, 16)
                    
                    // Quick stats
                    if !timerViewModel.currentSession.solves.isEmpty {
                        quickStatsCard
                            .padding(.horizontal, 16)
                    }
                }
                .padding(.vertical, 16)
            }
            .scrollIndicators(.hidden)
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Timer")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showSolvesList) {
                NavigationStack {
                    SolvesListView()
                }
            }
        }
        .onAppear {
            // Sync method from Learn tab
            timerViewModel.syncMethod(from: tutorialViewModel)
        }
    }
    
    // MARK: - DNA Controls
    
    private var dnaControls: some View {
        VStack(spacing: 12) {
            // DNA toggle
            HStack {
                Label {
                    Text("Solve DNA")
                        .font(.subheadline)
                        .fontWeight(.medium)
                } icon: {
                    Image(systemName: "waveform.path.ecg")
                        .foregroundStyle(timerViewModel.isDNAModeActive ? .indigo : .secondary)
                }
                
                Spacer()
                
                Toggle("", isOn: $timerViewModel.isDNAModeActive)
                    .labelsHidden()
                    .disabled(timerViewModel.timerState == .running)
            }
            .padding()
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            

            
            // Split button (during solve, first stage only)
            if timerViewModel.timerState == .running &&
               timerViewModel.isDNAModeActive &&
               timerViewModel.currentDNAStage == .firstTwoLayers {
                Button(action: {
                    timerViewModel.recordDNASplit()
                }) {
                    Label("Done with F2L", systemImage: "checkmark.circle.fill")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.indigo)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .buttonStyle(.plain)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }
    
    // MARK: - Timer Circle
    
    private var timerCircle: some View {
        ZStack {
            Circle()
                .stroke(ringColor, lineWidth: ringWidth)
                .frame(width: 280, height: 280)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: timerViewModel.timerState)
            
            Circle()
                .fill(ringColor.opacity(0.08))
                .frame(width: 280, height: 280)
            
            VStack(spacing: 8) {
                Text(timerViewModel.formatTime(timerViewModel.currentTime))
                    .font(.system(size: 80, weight: .light, design: .rounded))
                    .monospacedDigit()
                    .foregroundColor(ringColor)
                
                Text(hintText)
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
                handleTouchDown()
            }
            .onEnded { _ in handleTouchUp() }
    }
    
    // MARK: - Quick Stats
    
    private var quickStatsCard: some View {
        HStack(spacing: 0) {
            statCell("Best", value: bestTime, icon: "trophy.fill", color: .primary, isBest: true)
            Divider().frame(height: 40)
            statCell("Ao5", value: ao5Time, icon: "5.square.fill", color: .secondary)
            Divider().frame(height: 40)
            statCell("Ao12", value: ao12Time, icon: "number.square.fill", color: .secondary)
        }
        .padding(.vertical, 16)
        .background(Color(uiColor: .systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
    
    private func statCell(_ label: String, value: String, icon: String, color: Color, isBest: Bool = false) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(color)
            Text(value)
                .font(isBest ? .system(.headline).bold() : .headline)
                .monospacedDigit()
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Bottom Controls
    
    private var bottomControls: some View {
        HStack(spacing: 16) {
            controlButton(icon: "arrow.counterclockwise", color: .primary) {
                timerViewModel.reset()
            }
            
            controlButton(icon: "list.number", color: .primary) {
                showSolvesList = true
            }
            
            controlButton(icon: "shuffle", color: .indigo) {
                timerViewModel.generateNewScramble()
            }
        }
    }
    
    private func controlButton(icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
                .frame(width: 56, height: 56)
                .background(color.opacity(0.1))
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Timer Logic
    
    private func handleTouchDown() {
        switch timerViewModel.timerState {
        case .running:
            timerViewModel.stopTimer()
            isHoldingDown = false
        case .stopped:
            timerViewModel.reset()
            isHoldingDown = false
        case .idle:
            holdTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
                if isHoldingDown { timerViewModel.setReady() }
            }
        case .ready:
            break
        }
    }
    
    private func handleTouchUp() {
        holdTimer?.invalidate()
        holdTimer = nil
        if timerViewModel.timerState == .ready {
            timerViewModel.startTimer()
        } else if timerViewModel.timerState == .idle {
            timerViewModel.reset()
        }
        isHoldingDown = false
    }
    
    // MARK: - Helpers
    
    private var ringColor: Color {
        switch timerViewModel.timerState {
        case .idle: return .primary.opacity(0.2)
        case .ready: return .primary
        case .running: return .secondary.opacity(0.3)
        case .stopped: return .primary
        }
    }

    private var ringWidth: CGFloat {
        switch timerViewModel.timerState {
        case .idle: return 4
        case .ready: return 8
        case .running: return 2
        case .stopped: return 4
        }
    }
    
    private var hintText: String {
        switch timerViewModel.timerState {
        case .idle: return "Hold to start"
        case .ready: return "Release to go"
        case .running: return "Tap to stop"
        case .stopped: return "Tap to reset"
        }
    }
    
    private func cubeFromScramble() -> CubeState {
        var cube = CubeState()
        for token in timerViewModel.currentScramble.split(separator: " ") {
            if let move = CubeMove(rawValue: String(token)) {
                cube.applyMove(move)
            }
        }
        return cube
    }
    
    private var bestTime: String {
        SolveStatistics.formatTime(timerViewModel.currentSession.statistics.currentSingle)
    }
    
    private var ao5Time: String {
        SolveStatistics.formatTime(timerViewModel.currentSession.statistics.average(of: 5))
    }
    
    private var ao12Time: String {
        SolveStatistics.formatTime(timerViewModel.currentSession.statistics.average(of: 12))
    }
}

// MARK: - Solves List

struct SolvesListView: View {
    @EnvironmentObject var timerViewModel: TimerViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        List {
            ForEach(Array(timerViewModel.currentSession.solves.reversed().enumerated()), id: \.element.id) { index, solve in
                SolveRow(solve: solve, number: timerViewModel.currentSession.solves.count - index)
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            if let i = timerViewModel.currentSession.solves.firstIndex(where: { $0.id == solve.id }) {
                                timerViewModel.deleteSolve(at: i)
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    .swipeActions(edge: .leading, allowsFullSwipe: false) {
                        Button {
                            timerViewModel.togglePenalty(for: solve)
                        } label: {
                            Label("+2", systemImage: "plus.circle")
                        }
                        .tint(.secondary)
                        
                        Button {
                            timerViewModel.toggleDNF(for: solve)
                        } label: {
                            Label("DNF", systemImage: "xmark.circle")
                        }
                        .tint(.primary)
                    }
            }
        }
        .listStyle(.insetGrouped)
        .scrollIndicators(.hidden)
        .navigationTitle("Solves")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") { dismiss() }
            }
        }
    }
}


