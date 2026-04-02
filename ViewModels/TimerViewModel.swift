//  TimerViewModel.swift
//  ViewModels
//
//  Timer with 2-stage DNA mode (default ON)


import SwiftUI
import Combine

enum TimerState {
    case idle
    case ready
    case running
    case stopped
}

@MainActor
class TimerViewModel: ObservableObject {
    
    // MARK: - Timer Core
    
    @Published var currentTime: Double = 0
    @Published var timerState: TimerState = .idle
    @Published var currentScramble: String = ""
    
    // MARK: - Session
    
    @Published var sessions: [SolveSession] = []
    @Published var currentSessionIndex: Int = 0
    
    // MARK: - DNA Mode (2-stage, default ON)
    
    @Published var isDNAModeActive: Bool = true  // Default ON
    @Published var currentDNAStage: DNAStage = .firstTwoLayers
    @Published var currentSplits: [SolveSplit] = []
    @Published var stageStartTime: Double = 0
    
    // Auto-detected from Learn tab
    @Published var dnaMethod: SolvingMethod = .beginners
    
    // UI Hints
    @Published var hasSeenTimerHint: Bool = false
    
    // Computed helper for DNA split UI
    var currentStage: SolveStage {
        currentDNAStage.solveStage
    }
    
    // MARK: - Private
    
    private var timer: Timer?
    private var startTime: Date?
    
    // MARK: - Initialization
    
    init() {
        // Load persisted sessions
        loadSessions()
        
        // If no sessions exist, create default
        if sessions.isEmpty {
            sessions = [SolveSession(name: "Session 1")]
        }
        
        // Always generate random scramble
        generateNewScramble()
        loadHintState()
    }
    
    // MARK: - Session Helpers
    
    var currentSession: SolveSession {
        get { sessions[currentSessionIndex] }
        set { sessions[currentSessionIndex] = newValue }
    }
    
    // MARK: - Scramble Generation
    
    func generateNewScramble(moveCount: Int = 20) {
        currentScramble = ScrambleGenerator.generate(moveCount: moveCount)
            .map { $0.displayName }
            .joined(separator: " ")
    }
    
    // MARK: - Timer State Machine
    
    func setReady() {
        guard timerState == .idle else { return }
        timerState = .ready
        HapticManager.timerReady()
    }
    
    func startTimer() {
        guard timerState != .running else { return }
        
        timerState = .running
        startTime = Date()
        currentTime = 0
        currentSplits = []
        currentDNAStage = .firstTwoLayers
        stageStartTime = 0
        
        HapticManager.timerStart()
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            guard let self, let start = self.startTime else { return }
            Task { @MainActor in
                self.currentTime = Date().timeIntervalSince(start)
            }
        }
    }
    
    func stopTimer() {
        guard timerState == .running else { return }
        
        timer?.invalidate()
        timer = nil
        timerState = .stopped
        
        HapticManager.timerStop()
        
        // If DNA mode, record final stage automatically
        if isDNAModeActive {
            let finalDuration = currentTime - stageStartTime
            currentSplits.append(SolveSplit(stage: currentDNAStage.solveStage, duration: finalDuration))
        }
        
        // Create solve
        let solve = TimerSolve(
            time: currentTime,
            scramble: currentScramble,
            method: isDNAModeActive ? dnaMethod : nil,
            splits: isDNAModeActive ? currentSplits : []
        )
        
        currentSession.solves.append(solve)
        
        // Persist to disk
        saveSessions()
        
        // Check for AI coaching unlock
        if currentSession.dnaSolves.count == 2 {
            // Show notification that AI coaching is now available
            NotificationCenter.default.post(name: .aiCoachingUnlocked, object: nil)
        }
        
        // Generate new scramble for the next solve
        generateNewScramble()
    }
    
    func addPracticeSolve(time: Double, stage: SolveStage) {
        let solve = TimerSolve(
            time: time,
            scramble: "Practice",
            practiceStage: stage
        )
        currentSession.solves.append(solve)
        saveSessions()
    }
    
    func reset() {
        timer?.invalidate()
        timer = nil
        currentTime = 0
        timerState = .idle
        currentSplits = []
        currentDNAStage = .firstTwoLayers
        stageStartTime = 0
        
        HapticManager.selection()
    }
    
    // MARK: - DNA Split Recording (2-stage)
    
    func recordDNASplit() {
        guard timerState == .running && isDNAModeActive else { return }
        
        if currentDNAStage == .lastLayer {
            // Already on last stage, Split acts as a stop
            stopTimer()
            return
        }
        
        let duration = currentTime - stageStartTime
        currentSplits.append(SolveSplit(stage: currentDNAStage.solveStage, duration: duration))
        stageStartTime = currentTime
        
        // Advance to next stage
        currentDNAStage = .lastLayer
        
        HapticManager.splitRecorded()
    }
    
    // MARK: - Solve Management
    
    func deleteSolve(at index: Int) {
        guard index >= 0 && index < currentSession.solves.count else { return }
        currentSession.solves.remove(at: index)
        saveSessions()
    }
    
    func togglePenalty(for solve: TimerSolve) {
        guard let index = currentSession.solves.firstIndex(where: { $0.id == solve.id }) else { return }
        
        if currentSession.solves[index].penalty == .none {
            currentSession.solves[index].penalty = .plus2
        } else {
            currentSession.solves[index].penalty = .none
        }
        
        saveSessions()
    }
    
    func toggleDNF(for solve: TimerSolve) {
        guard let index = currentSession.solves.firstIndex(where: { $0.id == solve.id }) else { return }
        currentSession.solves[index].dnf.toggle()
        saveSessions()
    }
    
    // MARK: - Method Sync (from Learn tab)
    
    func syncMethod(from tutorialVM: TutorialViewModel) {
        dnaMethod = tutorialVM.selectedMethod
    }
    
    // MARK: - UI Hints
    
    func dismissTimerHint() {
        hasSeenTimerHint = true
        UserDefaults.standard.set(true, forKey: "hasSeenTimerHint")
    }
    
    private func loadHintState() {
        hasSeenTimerHint = UserDefaults.standard.bool(forKey: "hasSeenTimerHint")
    }
    
    // MARK: - Time Formatting
    
    func formatTime(_ time: Double) -> String {
        let minutes = Int(time) / 60
        let seconds = time.truncatingRemainder(dividingBy: 60)
        
        if minutes > 0 {
            return String(format: "%d:%05.2f", minutes, seconds)
        } else {
            return String(format: "%.2f", seconds)
        }
    }
    
    // MARK: - Persistence
    
    private func saveSessions() {
        if let encoded = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(encoded, forKey: "savedSessions")
        }
    }
    
    private func loadSessions() {
        if let data = UserDefaults.standard.data(forKey: "savedSessions"),
           let decoded = try? JSONDecoder().decode([SolveSession].self, from: data) {
            sessions = decoded
        }
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let aiCoachingUnlocked = Notification.Name("aiCoachingUnlocked")
}
