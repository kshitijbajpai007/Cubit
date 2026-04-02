//  ScrambleGenerator.swift
//  Utilities

///  WCA-compliant scramble generation


import Foundation

struct ScrambleGenerator {
    // Generate a WCA-compliant random scramble
    static func generate(moveCount: Int = 20) -> [CubeMove] {
        var scramble: [CubeMove] = []
        var lastFace: String?
        var secondLastFace: String?
        
        for _ in 0..<moveCount {
            var validMoves = CubeMove.allCases.filter { move in
                let currentFace = move.baseFace
                
                // WCA Rule: Don't use same face consecutively
                if currentFace == lastFace {
                    return false
                }
                
                // WCA Rule: Don't use opposite faces if previous two moves were on those faces
                // (e.g., if we did R then L, don't do R again)
                if let second = secondLastFace,
                   let last = lastFace,
                   currentFace == second && oppositeFace(currentFace) == last {
                    return false
                }
                
                return true
            }
            
            guard let randomMove = validMoves.randomElement() else {
                // Fallback - just avoid last face
                validMoves = CubeMove.allCases.filter { $0.baseFace != lastFace }
                guard let randomMove = validMoves.randomElement() else { continue }
                scramble.append(randomMove)
                secondLastFace = lastFace
                lastFace = randomMove.baseFace
                continue
            }
            
            scramble.append(randomMove)
            secondLastFace = lastFace
            lastFace = randomMove.baseFace
        }
        
        return scramble
    }
    
    // Generate scramble as string notation
    static func generateNotation(moveCount: Int = 20) -> String {
        let scramble = generate(moveCount: moveCount)
        return scramble.map { $0.displayName }.joined(separator: " ")
    }
    
    // Get opposite face
    private static func oppositeFace(_ face: String) -> String {
        switch face {
        case "R": return "L"
        case "L": return "R"
        case "U": return "D"
        case "D": return "U"
        case "F": return "B"
        case "B": return "F"
        default: return ""
        }
    }
}

// MARK: - CubeMove Extension

extension CubeMove {
    var baseFace: String {
        switch self {
        case .U, .UPrime, .U2: return "U"
        case .D, .DPrime, .D2: return "D"
        case .F, .FPrime, .F2: return "F"
        case .B, .BPrime, .B2: return "B"
        case .R, .RPrime, .R2: return "R"
        case .L, .LPrime, .L2: return "L"
        }
    }
}
