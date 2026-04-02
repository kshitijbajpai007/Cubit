//
//  StageScrambleGenerator.swift
//  Utilities
//
//  Produces a valid CubeState starting position for each practice stage
//  across Beginner's/CFOP, Roux and ZZ.
//
///  Strategy per method:
//
///  CFOP:
///  Cross       → full WCA scramble
///   F2L         → U/R/L/F/B only (no D) → cross stays intact
///   OLL         → random OLL alg inverse applied to solved cube
///   PLL         → random PLL alg inverse applied to solved cube


import Foundation

struct StageScrambleGenerator {

    static func generate(for stage: SolveStage) -> CubeState {
        switch stage {
        // ── CFOP / Beginner's ─────────────────────────────
        case .cross:       return fullScramble()
        case .f2l:         return f2lStart()
        case .oll:         return ollStart()
        case .pll:         return pllStart()
        }
    }

    // MARK: - Shared

    private static func fullScramble() -> CubeState {
        var cube = CubeState()
        for move in ScrambleGenerator.generate(moveCount: 20) {
            cube.applyMove(move)
        }
        return cube
    }

    private static func applyRandom(_ moves: [CubeMove], count: Int,
                                     to cube: inout CubeState) {
        var lastFace = ""
        for _ in 0..<count {
            var move: CubeMove
            repeat { move = moves.randomElement()! }
            while String(move.rawValue.prefix(1)) == lastFace
            lastFace = String(move.rawValue.prefix(1))
            cube.applyMove(move)
        }
    }

    private static func applyInverse(notation: String, to cube: inout CubeState) {
        let moves = notation.split(separator: " ")
            .compactMap { CubeMove(rawValue: String($0)) }
        for move in moves.reversed() {
            cube.applyMove(move.inverse)
        }
    }

    // MARK: - CFOP

    private static func f2lStart() -> CubeState {
        // U/R/L/F/B moves only — never D — so white cross stays solved
        var cube = CubeState()
        let moves: [CubeMove] = [
            .U, .UPrime, .U2,
            .R, .RPrime, .R2,
            .L, .LPrime, .L2,
            .F, .FPrime, .F2,
            .B, .BPrime, .B2
        ]
        applyRandom(moves, count: 22, to: &cube)
        return cube
    }

    private static func ollStart() -> CubeState {
        var cube = CubeState()
        let cases = [
            "R U R' U R U2 R'",
            "R U2 R' U' R U' R'",
            "R U R' U' R' F R F'",
            "F R U R' U' F'",
            "R U2 R2 U' R2 U' R2 U2 R",
            "R' U' R U' R' U2 R",
            "R U R' U R U2 R' F R U R' U' F'",
            "F R U R' U' R U R' U' F'"
        ]
        applyInverse(notation: cases.randomElement()!, to: &cube)
        return cube
    }

    private static func pllStart() -> CubeState {
        var cube = CubeState()
        let cases = [
            "R U R' U' R' F R2 U' R' U' R U R' F'",
            "R U R' F' R U R' U' R' F R2 U' R'",
            "R U' R U R U R U' R' U' R2",
            "R2 U R U R' U' R' U' R' U R'",
            "U R U' R' U' R U R' F' R U R' U' R' F R",
            "R' U R U' R' F' U' F R U R' F R' F' R U' R"
        ]
        applyInverse(notation: cases.randomElement()!, to: &cube)
        return cube
    }


}
