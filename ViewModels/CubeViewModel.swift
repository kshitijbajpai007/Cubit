//  CubeViewModel.swift
//  ViewModels

import SwiftUI
import Combine

@MainActor
class CubeViewModel: ObservableObject {
    @Published var cubeState: CubeState
    @Published var moveHistory: [CubeMove] = []
    @Published var isAnimating = false
    
    init() {
        self.cubeState = CubeState()
    }
    
    // Apply a move and track it
    func applyMove(_ move: CubeMove) {
        cubeState.applyMove(move)
        moveHistory.append(move)
    }
    
    // Apply a sequence of moves from notation
    func applyAlgorithm(_ notation: String) {
        let algorithm = Algorithm(name: "Temp", notation: notation, category: .beginners)
        applyAlgorithm(algorithm)
    }
    
    func applyAlgorithm(_ algorithm: Algorithm) {
        isAnimating = true
        
        for (index, move) in algorithm.moves.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.3) {
                self.applyMove(move)
                
                if index == algorithm.moves.count - 1 {
                    self.isAnimating = false
                }
            }
        }
    }
    
    // Reset cube to solved state
    func reset() {
        cubeState = CubeState()
        moveHistory = []
    }
    
    // Scramble the cube
    func scramble(moves: Int = 20) {
        reset()
        let scrambleMoves = ScrambleGenerator.generate(moveCount: moves)
        
        for move in scrambleMoves {
            cubeState.applyMove(move)
        }
        
        moveHistory = scrambleMoves
    }
    
    // Check if solved
    var isSolved: Bool {
        cubeState.isSolved
    }
    
    // Get scramble notation
    var scrambleNotation: String {
        moveHistory.map { $0.displayName }.joined(separator: " ")
    }
}
