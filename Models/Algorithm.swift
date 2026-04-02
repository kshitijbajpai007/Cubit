//  Algorithm.swift
//  Models


import Foundation

// Algorithm categories — one per method section
enum AlgorithmCategory: String, CaseIterable, Codable {
    case beginners = "Beginner's"
    case f2l       = "F2L"
    case oll       = "OLL"
    case pll       = "PLL"

    var uiColor: String {
        switch self {
        case .beginners: return "green"
        case .f2l:       return "blue"
        case .oll:       return "orange"
        case .pll:       return "red"
        }
    }

    var methodGroup: String {
        switch self {
        case .beginners:        return "Beginner's"
        case .f2l, .oll, .pll:  return "CFOP"
        }
    }
}

// Represents a single algorithm
struct Algorithm: Identifiable, Codable {
    let id: UUID
    let name: String
    let notation: String
    let category: AlgorithmCategory
    var personalBest: Double?
    var practiceCount: Int
    var notes: String

    init(id: UUID = UUID(), name: String, notation: String,
         category: AlgorithmCategory, personalBest: Double? = nil,
         practiceCount: Int = 0, notes: String = "") {
        self.id            = id
        self.name          = name
        self.notation      = notation
        self.category      = category
        self.personalBest  = personalBest
        self.practiceCount = practiceCount
        self.notes         = notes
    }

    var moves: [CubeMove] {
        notation.split(separator: " ").compactMap { token in
            let s = String(token)
                .replacingOccurrences(of: "w", with: "")
                .replacingOccurrences(of: "r", with: "R")
                .replacingOccurrences(of: "u", with: "U")
                .replacingOccurrences(of: "l", with: "L")
                .replacingOccurrences(of: "f", with: "F")
                .replacingOccurrences(of: "b", with: "B")
                .replacingOccurrences(of: "x", with: "")
                .replacingOccurrences(of: "y", with: "")
                .replacingOccurrences(of: "z", with: "")
                .replacingOccurrences(of: "M", with: "")
                .replacingOccurrences(of: "S", with: "")
                .replacingOccurrences(of: "E", with: "")
            return s.isEmpty ? nil : CubeMove(rawValue: s)
        }
    }

    var moveCount: Int { moves.count }
}

// MARK: - Algorithm Library

struct AlgorithmLibrary {

    // MARK: Beginner's
    static let beginnersAlgorithms: [Algorithm] = [
        Algorithm(name: "Right Corner Insert",  notation: "R' D' R D",             category: .beginners),
        Algorithm(name: "Left Edge Insert",     notation: "U' L' U L U F U' F'",   category: .beginners),
        Algorithm(name: "Right Edge Insert",    notation: "U R U' R' U' F' U F",   category: .beginners),
        Algorithm(name: "Yellow Cross",         notation: "F R U R' U' F'",         category: .beginners),
        Algorithm(name: "Edge Permutation",     notation: "R U R' U R U2 R'",       category: .beginners),
        Algorithm(name: "Corner Position",      notation: "U R U' L' U R' U' L",   category: .beginners),
        Algorithm(name: "Corner Orientation",   notation: "R' D' R D",              category: .beginners)
    ]

    // MARK: F2L
    static let f2lAlgorithms: [Algorithm] = [
        Algorithm(name: "Basic Insert",                   notation: "R U R'",                    category: .f2l),
        Algorithm(name: "Reverse Insert",                 notation: "L' U' L",                   category: .f2l),
        Algorithm(name: "Split Pair",                     notation: "R U' R' U",                 category: .f2l),
        Algorithm(name: "Sledgehammer",                   notation: "R' F R F'",                 category: .f2l),
        Algorithm(name: "Hedge Slammer",                  notation: "F' U' F",                   category: .f2l),
        Algorithm(name: "Hide Corner",                    notation: "U R U' R'",                 category: .f2l),
        Algorithm(name: "Corner in Slot, Edge in Top",    notation: "U' R U R' U2 R U' R'",     category: .f2l),
        Algorithm(name: "Edge in Slot, Corner in Top",    notation: "R U' R' U R U R'",          category: .f2l)
    ]

    // MARK: OLL
    static let ollAlgorithms: [Algorithm] = [
        Algorithm(name: "Sune",         notation: "R U R' U R U2 R'",             category: .oll),
        Algorithm(name: "Anti-Sune",    notation: "R U2 R' U' R U' R'",           category: .oll),
        Algorithm(name: "H-OLL",        notation: "F R U R' U' F' f R U R' U' f'", category: .oll),
        Algorithm(name: "Pi",           notation: "R U2 R2 U' R2 U' R2 U2 R",    category: .oll),
        Algorithm(name: "Headlights",   notation: "R2 D R' U2 R D' R' U2 R'",    category: .oll),
        Algorithm(name: "OLL T",        notation: "R U R' U' R' F R F'",          category: .oll),
        Algorithm(name: "OLL L",        notation: "F' L' U' L U F",               category: .oll),
        Algorithm(name: "OLL 45",       notation: "F R U R' U' F'",               category: .oll)
    ]

    // MARK: PLL
    static let pllAlgorithms: [Algorithm] = [
        Algorithm(name: "T-Perm",      notation: "R U R' U' R' F R2 U' R' U' R U R' F'",     category: .pll),
        Algorithm(name: "J-Perm (a)",  notation: "x R2 F R F' R U2 R' U' R U' R'",           category: .pll),
        Algorithm(name: "J-Perm (b)",  notation: "R U R' F' R U R' U' R' F R2 U' R'",        category: .pll),
        Algorithm(name: "U-Perm (a)",  notation: "R U' R U R U R U' R' U' R2",               category: .pll),
        Algorithm(name: "U-Perm (b)",  notation: "R2 U R U R' U' R' U' R' U R'",             category: .pll),
        Algorithm(name: "A-Perm (a)",  notation: "x R' U R' D2 R U' R' D2 R2",              category: .pll),
        Algorithm(name: "A-Perm (b)",  notation: "x R2 D2 R U R' D2 R U' R",                category: .pll),
        Algorithm(name: "H-Perm",      notation: "M2 U M2 U2 M2 U M2",                       category: .pll),
        Algorithm(name: "Z-Perm",      notation: "M' U M2 U M2 U M' U2 M2",                  category: .pll),
        Algorithm(name: "Y-Perm",      notation: "F R U' R' U' R U R' F' R U R' U' R' F R F'", category: .pll)
    ]


    // MARK: - Accessors

    static var allAlgorithms: [Algorithm] {
        beginnersAlgorithms + f2lAlgorithms + ollAlgorithms + pllAlgorithms
    }

    static func algorithms(for category: AlgorithmCategory) -> [Algorithm] {
        switch category {
        case .beginners: return beginnersAlgorithms
        case .f2l:       return f2lAlgorithms
        case .oll:       return ollAlgorithms
        case .pll:       return pllAlgorithms
        }
    }

    static var groupedByMethod: [(method: String, categories: [AlgorithmCategory])] {
        [
            ("Beginner's", [.beginners]),
            ("CFOP",       [.f2l, .oll, .pll])
        ]
    }
}
