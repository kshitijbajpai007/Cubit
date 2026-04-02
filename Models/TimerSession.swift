//  TimerSession.swift
//  Models


import Foundation

// Represents a single timed solve
struct TimerSolve: Identifiable, Codable {
    let id: UUID
    let time: Double // Time in seconds
    let scramble: String
    let date: Date
    let method: SolvingMethod?
    var penalty: PenaltyType
    var dnf: Bool
    var comment: String
    var splits: [SolveSplit]   // DNA splits — empty when not in DNA mode
    var practiceStage: SolveStage? // Which stage this practice solve belongs to
    
    init(id: UUID = UUID(), time: Double, scramble: String, date: Date = Date(), method: SolvingMethod? = nil, penalty: PenaltyType = .none, dnf: Bool = false, comment: String = "", splits: [SolveSplit] = [], practiceStage: SolveStage? = nil) {
        self.id = id
        self.time = time
        self.scramble = scramble
        self.date = date
        self.method = method
        self.penalty = penalty
        self.dnf = dnf
        self.comment = comment
        self.splits = splits
        self.practiceStage = practiceStage
    }
    
    // Display time with penalties
    var displayTime: String {
        if dnf {
            return "DNF"
        }
        
        let finalTime = time + penalty.timeAddition
        return formatTime(finalTime) + penalty.suffix
    }
    
    // Get clean time for averaging
    var cleanTime: Double? {
        dnf ? nil : time + penalty.timeAddition
    }
    
    private func formatTime(_ seconds: Double) -> String {
        let minutes = Int(seconds) / 60
        let secs = Int(seconds) % 60
        let ms = Int((seconds.truncatingRemainder(dividingBy: 1)) * 100)
        
        if minutes > 0 {
            return String(format: "%d:%02d.%02d", minutes, secs, ms)
        } else {
            return String(format: "%d.%02d", secs, ms)
        }
    }
    
    // Whether this solve recorded DNA split data.
    var hasDNAData: Bool {
        !splits.isEmpty
    }
}

// Penalty types
enum PenaltyType: String, Codable {
    case none = "None"
    case plus2 = "+2"
    
    var timeAddition: Double {
        switch self {
        case .none: return 0
        case .plus2: return 2
        }
    }
    
    var suffix: String {
        switch self {
        case .none: return ""
        case .plus2: return "+"
        }
    }
}

// Statistics calculations
struct SolveStatistics {
    let solves: [TimerSolve]
    
    // Current single (best time)
    var currentSingle: Double? {
        solves.compactMap { $0.cleanTime }.min()
    }
    
    // Mean of all solves
    var mean: Double? {
        let times = solves.compactMap { $0.cleanTime }
        guard !times.isEmpty else { return nil }
        return times.reduce(0, +) / Double(times.count)
    }
    
    // Average of 5 (remove best and worst)
    func average(of count: Int) -> Double? {
        guard solves.count >= count else { return nil }
        
        let recentSolves = Array(solves.suffix(count))
        let times = recentSolves.compactMap { $0.cleanTime }
        
        guard times.count >= count - 1 else { return nil } // Allow 1 DNF
        
        if times.count == count {
            let sorted = times.sorted()
            let trimmed = sorted.dropFirst().dropLast()
            return trimmed.reduce(0, +) / Double(trimmed.count)
        }
        
        return nil
    }
    
    // Best average of N
    func bestAverage(of count: Int) -> Double? {
        guard solves.count >= count else { return nil }
        
        var bestAvg: Double?
        
        for i in 0...(solves.count - count) {
            let subset = Array(solves[i..<(i + count)])
            let times = subset.compactMap { $0.cleanTime }
            
            guard times.count >= count - 1 else { continue }
            
            if times.count == count {
                let sorted = times.sorted()
                let trimmed = sorted.dropFirst().dropLast()
                let avg = trimmed.reduce(0, +) / Double(trimmed.count)
                
                if bestAvg == nil || avg < bestAvg! {
                    bestAvg = avg
                }
            }
        }
        
        return bestAvg
    }
    
    // Standard deviation
    var standardDeviation: Double? {
        guard let mean = mean else { return nil }
        let times = solves.compactMap { $0.cleanTime }
        guard times.count > 1 else { return nil }
        
        let squaredDiffs = times.map { pow($0 - mean, 2) }
        let variance = squaredDiffs.reduce(0, +) / Double(times.count - 1)
        return sqrt(variance)
    }
    
    // Format time for display
    static func formatTime(_ seconds: Double?) -> String {
        guard let seconds = seconds else { return "—" }
        
        let minutes = Int(seconds) / 60
        let secs = Int(seconds) % 60
        let ms = Int((seconds.truncatingRemainder(dividingBy: 1)) * 100)
        
        if minutes > 0 {
            return String(format: "%d:%02d.%02d", minutes, secs, ms)
        } else {
            return String(format: "%d.%02d", secs, ms)
        }
    }
}

// Session for organizing solves
struct SolveSession: Identifiable, Codable {
    let id: UUID
    var name: String
    var solves: [TimerSolve]
    var method: SolvingMethod?
    let createdDate: Date
    
    init(id: UUID = UUID(), name: String, solves: [TimerSolve] = [], method: SolvingMethod? = nil, createdDate: Date = Date()) {
        self.id = id
        self.name = name
        self.solves = solves
        self.method = method
        self.createdDate = createdDate
    }
    
    var statistics: SolveStatistics {
        SolveStatistics(solves: solves)
    }
    
    // Solves that include DNA split data.
    var dnaSolves: [TimerSolve] {
        solves.filter { $0.hasDNAData }
    }
}
