// DNAModels.swift
//Models

import Foundation
import SwiftUI

// High-level "DNA" stages for timer's simplified 2-stage split (F2L vs LL).
public enum DNAStage: String, CaseIterable, Codable, Hashable {
    case firstTwoLayers = "F2L"
    case lastLayer      = "LL"
    
    /// Maps the simplified DNA stage to a standard solve stage for split recording.
    public var solveStage: SolveStage {
        switch self {
        case .firstTwoLayers: return .f2l
        case .lastLayer:      return .oll
        }
    }
}


public enum SolveStage: String, Codable, CaseIterable, Hashable, Identifiable {
    // CFOP / Beginner's
    case cross
    case f2l
    case oll
    case pll
    
    public var id: String { rawValue }
    
    public var color: Color {
        switch self {
        case .cross: return .primary.opacity(0.8)
        case .f2l:   return .primary.opacity(0.7)
        case .oll:   return .indigo
        case .pll:   return .indigo.opacity(0.8)
        }
    }

    public var displayName: String {
        switch self {
        case .cross: return "Cross"
        case .f2l:   return "F2L"
        case .oll:   return "OLL"
        case .pll:   return "PLL"
        }
    }
    
    public var method: String {
        switch self {
        case .cross, .f2l, .oll, .pll: return "CFOP"
        }
    }
    
    public var subtitle: String {
        switch self {
        case .cross: return "First cross on bottom"
        case .f2l: return "First two layers"
        case .oll: return "Orient last layer"
        case .pll: return "Permute last layer"
        }
    }
    
    public var tutorialMethodStep: Int {
        switch self {
        case .cross: return 0
        case .f2l: return 1
        case .oll: return 2
        case .pll: return 3
        default: return 0
        }
    }
}

// A split for one stage of the solve.
public struct SolveSplit: Codable, Hashable, Identifiable {
    public let id: UUID
    public let stage: SolveStage
    public let duration: TimeInterval

    public init(id: UUID = UUID(), stage: SolveStage, duration: TimeInterval) {
        self.id = id
        self.stage = stage
        self.duration = duration
    }
}
