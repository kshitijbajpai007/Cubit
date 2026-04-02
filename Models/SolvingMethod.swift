//  SolvingMethod.swift
//  Models


import Foundation

// Different solving methods for Rubik's Cube
enum SolvingMethod: String, CaseIterable, Identifiable, Codable {
    case beginners = "Beginner's Method"
    case cfop = "CFOP (Fridrich)"
    
    var id: String { rawValue }
    
    var description: String {
        switch self {
        case .beginners:
            return "Layer-by-layer approach, perfect for learning the basics. Solve white cross, white corners, middle layer, yellow cross, yellow edges, yellow corners position, then orient."
        case .cfop:
            return "Cross, F2L (First 2 Layers), OLL (Orient Last Layer), PLL (Permute Last Layer). The most popular speedcubing method."
        }
    }
    
    var difficulty: String {
        switch self {
        case .beginners: return "Easy"
        case .cfop: return "Intermediate to Advanced"
        }
    }
    
    var estimatedAlgorithms: String {
        switch self {
        case .beginners: return "~6-8 algorithms"
        case .cfop: return "78+ algorithms"
        }
    }
    
    var averageMoves: String {
        switch self {
        case .beginners: return "100-120 moves"
        case .cfop: return "55-60 moves"
        }
    }
    
    var icon: String {
        switch self {
        case .beginners: return "graduationcap.fill"
        case .cfop: return "flame.fill"
        }
    }
    
    // Steps for each method
    var steps: [TutorialStep] {
        switch self {
        case .beginners:
            return BeginnersSteps.allSteps
        case .cfop:
            return CFOPSteps.allSteps
        }
    }

    /// The ordered solve stages used while recording Solve DNA splits.
    var dnaStages: [SolveStage] {
        switch self {
        case .beginners, .cfop:
            return [.cross, .f2l, .oll, .pll]
        }
    }
}

// Represents a single step in a tutorial
struct TutorialStep: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let detailedInstructions: String
    let keyAlgorithms: [Algorithm]
    let practicePatterns: [String]
    let tips: [String]
    let videoTimestamp: String?
}

// Beginner's Method Steps
struct BeginnersSteps {
    static let allSteps: [TutorialStep] = [
        TutorialStep(
            title: "White Cross",
            description: "Create a white cross on top with matching edge colors",
            detailedInstructions: """
            1. Find a white edge piece
            2. Position it on the bottom layer below its target position
            3. Rotate the bottom to align the edge color with center
            4. Flip it up with F2, R2, L2, or B2
            5. Repeat for all 4 white edges
            """,
            keyAlgorithms: [],
            practicePatterns: ["White edge placement", "Cross completion"],
            tips: ["Hold white on top", "Work one edge at a time", "Don't break completed edges"],
            videoTimestamp: nil
        ),
        TutorialStep(
            title: "White Corners",
            description: "Complete the first layer by placing white corners",
            detailedInstructions: """
            1. Find a white corner piece
            2. Position it in the bottom layer below its slot
            3. Use the R' D' R D algorithm to insert
            4. Repeat 2-5 times until corner is correct
            5. Move to next corner
            """,
            keyAlgorithms: [
                Algorithm(name: "Right Corner Insert", notation: "R' D' R D", category: .beginners)
            ],
            practicePatterns: ["Corner positioning", "Algorithm repetition"],
            tips: ["White sticker can face different directions", "Algorithm works from any white orientation", "Completed corners stay in place"],
            videoTimestamp: nil
        ),
        TutorialStep(
            title: "Middle Layer Edges",
            description: "Insert the four middle layer edges",
            detailedInstructions: """
            1. Flip cube upside down (yellow on top)
            2. Find an edge without yellow
            3. Rotate top to match edge with center
            4. Determine if it goes left or right
            5. Execute left or right algorithm
            """,
            keyAlgorithms: [
                Algorithm(name: "Right Edge Insert", notation: "U R U' R' U' F' U F", category: .beginners),
                Algorithm(name: "Left Edge Insert", notation: "U' L' U L U F U' F'", category: .beginners)
            ],
            practicePatterns: ["Edge identification", "Left vs right decision"],
            tips: ["Only use edges without yellow", "Match edge color to center first", "Practice both algorithms separately"],
            videoTimestamp: nil
        ),
        TutorialStep(
            title: "Yellow Cross",
            description: "Orient yellow edges to form a cross",
            detailedInstructions: """
            1. Look at yellow stickers on top
            2. One of 4 patterns: dot, L, line, or cross
            3. For dot: do algorithm twice
            4. For L: position L to 9 o'clock, do algorithm once
            5. For line: position horizontally, do algorithm once
            """,
            keyAlgorithms: [
                Algorithm(name: "Yellow Cross", notation: "F R U R' U' F'", category: .oll)
            ],
            practicePatterns: ["Pattern recognition", "Orientation setup"],
            tips: ["Cross edges don't need to match centers yet", "Only yellow orientation matters", "Maximum 3 algorithm executions"],
            videoTimestamp: nil
        ),
        TutorialStep(
            title: "Yellow Edge Permutation",
            description: "Position yellow edges correctly",
            detailedInstructions: """
            1. Find one correctly placed edge (matches center)
            2. Hold it at the back
            3. Execute the algorithm
            4. If no edges match, do algorithm once and check again
            """,
            keyAlgorithms: [
                Algorithm(name: "Edge Swap", notation: "R U R' U R U2 R' U", category: .pll)
            ],
            practicePatterns: ["Edge matching check"],
            tips: ["Rotate top layer to check each edge", "One correct edge means one algorithm solves it", "Yellow cross must be complete first"],
            videoTimestamp: nil
        ),
        TutorialStep(
            title: "Yellow Corner Position",
            description: "Move yellow corners to correct positions",
            detailedInstructions: """
            1. Find one corner in correct position (colors match, orientation doesn't matter)
            2. Hold it at front-right
            3. Execute algorithm
            4. If no corners correct, do algorithm and check again
            """,
            keyAlgorithms: [
                Algorithm(name: "Corner Cycle", notation: "U R U' L' U R' U' L", category: .pll)
            ],
            practicePatterns: ["Corner position check"],
            tips: ["Look at side colors only", "Orientation doesn't matter yet", "Maximum 3 executions needed"],
            videoTimestamp: nil
        ),
        TutorialStep(
            title: "Yellow Corner Orientation",
            description: "Orient the last layer corners to solve the cube",
            detailedInstructions: """
            1. Hold cube with any unsolved corner at front-right
            2. Repeat R' D' R D until corner is oriented (yellow on top)
            3. Turn U to bring next unsolved corner to front-right
            4. Repeat step 2 - DON'T rotate the cube
            5. After all corners are oriented, turn U to solve
            """,
            keyAlgorithms: [
                Algorithm(name: "Corner Twist", notation: "R' D' R D", category: .beginners)
            ],
            practicePatterns: ["Corner orientation", "Top layer rotation only"],
            tips: ["Cube will look scrambled temporarily - this is normal!", "Never rotate cube, only use U moves between corners", "4-6 repetitions per corner typically needed"],
            videoTimestamp: nil
        )
    ]
}

// CFOP Method Steps
struct CFOPSteps {
    static let allSteps: [TutorialStep] = [
        TutorialStep(
            title: "Cross",
            description: "Solve the bottom cross efficiently",
            detailedInstructions: """
            Advanced cross techniques:
            1. Plan entire cross during inspection
            2. Practice X-Cross (cross + 1 F2L pair)
            3. Optimize for 8 moves or less
            4. Practice color neutrality
            """,
            keyAlgorithms: [],
            practicePatterns: ["8-move cross", "X-Cross setups", "Color neutral crosses"],
            tips: ["Plan during 15s inspection", "Look ahead to F2L pairs", "Practice all colors as bottom"],
            videoTimestamp: nil
        ),
        TutorialStep(
            title: "F2L (First Two Layers)",
            description: "Pair and insert corner-edge pairs",
            detailedInstructions: """
            1. Identify a corner and its matching edge
            2. Bring both to top layer
            3. Pair them using intuitive moves
            4. Insert pair into slot
            5. Repeat for all 4 pairs
            
            Common cases:
            - Both in slot (separate and pair)
            - Both in top (basic pairing)
            - One in slot, one in top (advanced)
            """,
            keyAlgorithms: [
                Algorithm(name: "Basic Insert", notation: "R U R'", category: .f2l),
                Algorithm(name: "Split Pair", notation: "R U' R' U", category: .f2l),
                Algorithm(name: "Advanced Insert", notation: "U R U' R' U' F' U F", category: .f2l)
            ],
            practicePatterns: ["All 41 F2L cases", "Look-ahead practice"],
            tips: ["Learn intuitive F2L first", "Practice look-ahead between pairs", "Minimize cube rotations"],
            videoTimestamp: nil
        ),
        TutorialStep(
            title: "OLL (Orient Last Layer)",
            description: "Orient all yellow pieces",
            detailedInstructions: """
            Two-Look OLL for learning:
            1. Orient edges first (create yellow cross)
            2. Orient corners (make top all yellow)
            
            One-Look OLL for speed:
            - Recognize 1 of 57 patterns
            - Execute corresponding algorithm
            """,
            keyAlgorithms: [
                Algorithm(name: "OLL 27 (Cross)", notation: "R U R' U R U2 R'", category: .oll),
                Algorithm(name: "OLL 21 (Headlights)", notation: "R U2 R' U' R U R' U' R U' R'", category: .oll),
                Algorithm(name: "OLL 26 (Double Sune)", notation: "R U2 R' U' R U' R'", category: .oll)
            ],
            practicePatterns: ["57 OLL cases", "Edge orientation", "Corner orientation"],
            tips: ["Learn 2-look first", "Recognize patterns quickly", "Practice common cases more"],
            videoTimestamp: nil
        ),
        TutorialStep(
            title: "PLL (Permute Last Layer)",
            description: "Permute last layer pieces",
            detailedInstructions: """
            Two-Look PLL:
            1. Permute corners first
            2. Permute edges second
            
            One-Look PLL for speed:
            - Recognize 1 of 21 patterns
            - Execute algorithm
            - AUF (Adjust U Face) to solve
            """,
            keyAlgorithms: [
                Algorithm(name: "T-Perm", notation: "R U R' U' R' F R2 U' R' U' R U R' F'", category: .pll),
                Algorithm(name: "J-Perm", notation: "R U R' F' R U R' U' R' F R2 U' R'", category: .pll),
                Algorithm(name: "U-Perm", notation: "R U' R U R U R U' R' U' R2", category: .pll),
                Algorithm(name: "A-Perm", notation: "x R' U R' D2 R U' R' D2 R2", category: .pll)
            ],
            practicePatterns: ["21 PLL cases", "Corner permutation", "Edge permutation"],
            tips: ["Learn 2-look first", "Common cases: T, J, U, A perms", "Practice recognition at all angles"],
            videoTimestamp: nil
        )
    ]
}
