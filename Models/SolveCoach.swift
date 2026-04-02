//  SolveCoach.swift
//  Models


import Foundation
import FoundationModels

// MARK: - Coach State

enum CoachState: Equatable {
    case idle
    case unavailable(String)
    case loading
    case done(String)
    case failed(String)
}

// MARK: - Coaching Types

enum CoachingMode: String, Codable {
    case dnaAnalysis       // Based on F2L/LL splits
    case trendAnalysis     // Based on solve progression
    case techniqueFocus    // Based on method-specific tips
    case milestone         // Celebratory/encouragement
}

// MARK: - Coaching Input

struct DNACoachInput {
    let solveCount: Int
    let averages: [SolveStage: Double]
    let weakestStage: SolveStage
    let weakestPct: Int
    let bestSingle: Double?
    let methodName: String
    var recentSolves: [TimerSolve] = []   // Last 5-10 solves for trend analysis
    var previousAdvice: String? = nil     // To avoid repetition
}

struct TrendAnalysis {
    let isImproving: Bool
    let improvementRate: Double     // seconds improvement per solve
    let consistency: Double         // coefficient of variation
    let trendDirection: String      // "improving", "stable", "declining"
}

// MARK: - SolveCoach

@MainActor
final class SolveCoach: ObservableObject {
    
    @Published private(set) var state: CoachState = .idle
    @Published private(set) var lastAdvice: String?
    @Published private(set) var coachingHistory: [CoachingEntry] = []
    
    private let maxHistoryCount = 10
    
    struct CoachingEntry: Identifiable, Codable {
        let id = UUID()
        let date: Date
        let advice: String
        let mode: CoachingMode
        let solveCount: Int
    }
    
    // MARK: - Availability
    
    static var isAvailable: Bool {
        if #available(iOS 26.0, *) {
            return SystemLanguageModel.default.isAvailable
        }
        return false
    }
    
    
    func generateAdvice(for input: DNACoachInput, mode: CoachingMode = .dnaAnalysis) {
        guard SolveCoach.isAvailable else {
            state = .unavailable(unavailableReason)
            return
        }
        
        // Check if we should generate new advice or use cached
        if let last = lastAdvice,
           coachingHistory.last?.solveCount == input.solveCount,
           mode != .milestone {
            state = .done(last)
            return
        }
        
        state = .loading
        
        if #available(iOS 26.0, *) {
            Task { await generate(prompt: buildPrompt(for: input, mode: mode), mode: mode, input: input) }
        }
    }
    
    func generateQuickTip(for stage: DNAStage, method: SolvingMethod) {
        guard SolveCoach.isAvailable else { return }
        
        state = .loading
        
        let prompt = """
        Quick 1-sentence tip for improving \(stage.rawValue) in \(method.rawValue).
        Be specific and actionable. Max 15 words.
        """
        
        if #available(iOS 26.0, *) {
            Task {
                await generate(prompt: prompt, mode: .techniqueFocus, input: nil)
            }
        }
    }
    
    func reset() {
        state = .idle
    }
    
    func clearHistory() {
        coachingHistory.removeAll()
        lastAdvice = nil
    }
    
    // MARK: - Trend Analysis
    
    func analyzeTrends(from solves: [TimerSolve]) -> TrendAnalysis? {
        guard solves.count >= 3 else { return nil }
        
        let times = solves.compactMap { $0.cleanTime }
        guard times.count >= 3 else { return nil }
        
        // Simple linear regression for trend
        let n = Double(times.count)
        let indices = Array(0..<times.count).map(Double.init)
        
        let sumX = indices.reduce(0, +)
        let sumY = times.reduce(0, +)
        let sumXY = zip(indices, times).map(*).reduce(0, +)
        let sumX2 = indices.map { $0 * $0 }.reduce(0, +)
        
        let slope = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX)
        let mean = sumY / n
        
        // Calculate consistency (coefficient of variation)
        let variance = times.map { pow($0 - mean, 2) }.reduce(0, +) / (n - 1)
        let stdDev = sqrt(variance)
        let cv = stdDev / mean
        
        let trend: String
        if slope < -0.1 { trend = "improving" }
        else if slope > 0.1 { trend = "declining" }
        else { trend = "stable" }
        
        return TrendAnalysis(
            isImproving: slope < 0,
            improvementRate: abs(slope),
            consistency: cv,
            trendDirection: trend
        )
    }
    
    // MARK: - Generation (iOS 26.0+)
    
    @available(iOS 26.0, *)
    private func generate(prompt: String, mode: CoachingMode, input: DNACoachInput?) async {
        do {
            let session = LanguageModelSession()
            let response = try await session.respond(to: prompt)
            
            let advice = response.content.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Store in history
            if let input = input {
                let entry = CoachingEntry(
                    date: Date(),
                    advice: advice,
                    mode: mode,
                    solveCount: input.solveCount
                )
                coachingHistory.append(entry)
                if coachingHistory.count > maxHistoryCount {
                    coachingHistory.removeFirst()
                }
            }
            
            lastAdvice = advice
            state = .done(advice)
            
        } catch {
            state = .failed("Unable to generate coaching advice. Please try again.")
        }
    }
    
    // MARK: - Prompt Builders
    
    private func buildPrompt(for input: DNACoachInput, mode: CoachingMode) -> String {
        switch mode {
        case .dnaAnalysis:
            return buildDNAPrompt(input)
        case .trendAnalysis:
            return buildTrendPrompt(input)
        case .techniqueFocus:
            return buildTechniquePrompt(input)
        case .milestone:
            return buildMilestonePrompt(input)
        }
    }
    
    private func buildDNAPrompt(_ input: DNACoachInput) -> String {
        let stageLines = SolveStage.allCases.compactMap { stage -> String? in
            guard let avg = input.averages[stage] else { return nil }
            let total = input.averages.values.reduce(0, +)
            let pct = total > 0 ? Int(avg / total * 100) : 0
            return "  - \(stage.rawValue): \(String(format: "%.2f", avg))s (\(pct)%)"
        }.joined(separator: "\n")
        
        let pbLine = input.bestSingle.map {
            "Personal best: \(String(format: "%.2f", $0))s."
        } ?? "No personal best recorded yet."
        
        let previousContext = input.previousAdvice.map {
            "\n\nPrevious advice given: \"\($0)\"\nProvide different advice this time."
        } ?? ""
        
        return """
        You are an expert Rubik's Cube speedsolving coach in the Cubit app.
        
        User method: \(input.methodName)
        Total timed solves: \(input.solveCount)
        
        Stage breakdown (average time per stage):
        \(stageLines)
        
        \(pbLine)
        
        Weakest stage: \(input.weakestStage.rawValue) (\(input.weakestPct)% of total time)
        
        Give ONE specific, actionable piece of advice to improve \(input.weakestStage.rawValue). 
        Reference their actual numbers. Suggest one concrete drill or technique.
        Keep under 100 words. No bullet points. Direct, encouraging coach voice.
        \(previousContext)
        """
    }
    
    private func buildTrendPrompt(_ input: DNACoachInput) -> String {
        guard let trend = analyzeTrends(from: input.recentSolves) else {
            return buildDNAPrompt(input)
        }
        
        let recentTimes = input.recentSolves.compactMap { $0.cleanTime }.suffix(5)
        let timesString = recentTimes.map { String(format: "%.2f", $0) }.joined(separator: "s, ")
        
        return """
        You are a Rubik's Cube coach analyzing solve trends.
        
        Recent solve times: \(timesString)s
        Trend: \(trend.trendDirection) (\(String(format: "%.3f", trend.improvementRate))s per solve)
        Consistency: \(String(format: "%.1f", trend.consistency * 100))% variation
        
        Give brief feedback on their progression and ONE tip to either:
        - Maintain improvement if improving
        - Stabilize if declining
        - Increase consistency if stable
        
        Max 80 words. Encouraging tone.
        """
    }
    
    private func buildTechniquePrompt(_ input: DNACoachInput) -> String {
        return """
        Quick technique tip for \(input.methodName) - \(input.weakestStage.rawValue).
        
        Common mistakes in this stage:
        - Slow recognition
        - Inefficient finger tricks
        - Poor lookahead
        
        Pick ONE mistake and give a 2-sentence fix. Be specific.
        """
    }
    
    private func buildMilestonePrompt(_ input: DNACoachInput) -> String {
        let milestones = [10, 25, 50, 100, 250, 500, 1000]
        let milestone = milestones.first { $0 >= input.solveCount } ?? input.solveCount
        
        return """
        Celebrate the user reaching \(milestone) solves!
        
        Keep it brief (2 sentences), enthusiastic, and encouraging them to continue.
        Mention that consistency is key in speedcubing.
        """
    }
    
    // MARK: - Unavailability Message
    
    private var unavailableReason: String {
        if #available(iOS 26.0, *) {
            return "Apple Intelligence is not enabled. Go to Settings → Apple Intelligence & Siri to unlock the AI Coach."
        }
        return "AI Coach requires iOS 26+ on an Apple Intelligence device (iPhone 15 Pro or later, or iPad with M1+)."
    }
}
