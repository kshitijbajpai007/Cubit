//  CubeState.swift
//  Models

import SwiftUI

// Represents a single sticker on the cube
enum StickerColor: String, Codable {
    case white, yellow, red, orange, blue, green, none
    
    var color: Color {
        switch self {
        case .white: return .white
        case .yellow: return .yellow
        case .red: return .red
        case .orange: return .orange
        case .blue: return .blue
        case .green: return .green
        case .none: return .gray.opacity(0.3)
        }
    }
}

// Cube face enum
enum CubeFace: String, CaseIterable, Codable {
    case front, back, left, right, top, bottom
    
    var defaultColor: StickerColor {
        switch self {
        case .front: return .green
        case .back: return .blue
        case .left: return .orange
        case .right: return .red
        case .top: return .white
        case .bottom: return .yellow
        }
    }
}

// Move notation for Rubik's Cube
enum CubeMove: String, CaseIterable, Codable {
    case U, UPrime = "U'", U2
    case D, DPrime = "D'", D2
    case F, FPrime = "F'", F2
    case B, BPrime = "B'", B2
    case R, RPrime = "R'", R2
    case L, LPrime = "L'", L2
    
    var displayName: String { rawValue }
}

// Represents the entire cube state
struct CubeState: Codable {
    
    var faces: [CubeFace: [[StickerColor]]]
    
    init() {
        faces = [:]
        for face in CubeFace.allCases {
            faces[face] = Array(repeating: Array(repeating: face.defaultColor, count: 3), count: 3)
        }
    }
    
    // Manual Codable implementation
    enum CodingKeys: String, CodingKey {
        case faces
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode the dictionary - Swift can handle [CubeFace: [[StickerColor]]] since both are Codable
        faces = try container.decode([CubeFace: [[StickerColor]]].self, forKey: .faces)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(faces, forKey: .faces)
    }
    
    // Check if cube is solved
    var isSolved: Bool {
        for face in CubeFace.allCases {
            guard let faceStickers = faces[face] else { return false }
            let centerColor = faceStickers[1][1]
            for row in faceStickers {
                for sticker in row {
                    if sticker != centerColor {
                        return false
                    }
                }
            }
        }
        return true
    }
    
    // Apply a move to the cube
    mutating func applyMove(_ move: CubeMove) {
        switch move {
        case .U: rotateU(clockwise: true, times: 1)
        case .UPrime: rotateU(clockwise: false, times: 1)
        case .U2: rotateU(clockwise: true, times: 2)
        case .D: rotateD(clockwise: true, times: 1)
        case .DPrime: rotateD(clockwise: false, times: 1)
        case .D2: rotateD(clockwise: true, times: 2)
        case .F: rotateF(clockwise: true, times: 1)
        case .FPrime: rotateF(clockwise: false, times: 1)
        case .F2: rotateF(clockwise: true, times: 2)
        case .B: rotateB(clockwise: true, times: 1)
        case .BPrime: rotateB(clockwise: false, times: 1)
        case .B2: rotateB(clockwise: true, times: 2)
        case .R: rotateR(clockwise: true, times: 1)
        case .RPrime: rotateR(clockwise: false, times: 1)
        case .R2: rotateR(clockwise: true, times: 2)
        case .L: rotateL(clockwise: true, times: 1)
        case .LPrime: rotateL(clockwise: false, times: 1)
        case .L2: rotateL(clockwise: true, times: 2)
        }
    }
    
    // Helper function to rotate a face 90 degrees
    private mutating func rotateFace(_ face: CubeFace, clockwise: Bool) {
        guard var faceStickers = faces[face] else { return }
        
        let rotated: [[StickerColor]]
        if clockwise {
            rotated = [
                [faceStickers[2][0], faceStickers[1][0], faceStickers[0][0]],
                [faceStickers[2][1], faceStickers[1][1], faceStickers[0][1]],
                [faceStickers[2][2], faceStickers[1][2], faceStickers[0][2]]
            ]
        } else {
            rotated = [
                [faceStickers[0][2], faceStickers[1][2], faceStickers[2][2]],
                [faceStickers[0][1], faceStickers[1][1], faceStickers[2][1]],
                [faceStickers[0][0], faceStickers[1][0], faceStickers[2][0]]
            ]
        }
        
        faces[face] = rotated
    }
    
    // Individual move implementations
    private mutating func rotateU(clockwise: Bool, times: Int) {
        for _ in 0..<times {
            rotateFace(.top, clockwise: clockwise)
            
            let temp = faces[.front]![0]
            if clockwise {
                faces[.front]![0] = faces[.right]![0]
                faces[.right]![0] = faces[.back]![0]
                faces[.back]![0] = faces[.left]![0]
                faces[.left]![0] = temp
            } else {
                faces[.front]![0] = faces[.left]![0]
                faces[.left]![0] = faces[.back]![0]
                faces[.back]![0] = faces[.right]![0]
                faces[.right]![0] = temp
            }
        }
    }
    
    private mutating func rotateD(clockwise: Bool, times: Int) {
        for _ in 0..<times {
            rotateFace(.bottom, clockwise: clockwise)
            
            let temp = faces[.front]![2]
            if clockwise {
                faces[.front]![2] = faces[.left]![2]
                faces[.left]![2] = faces[.back]![2]
                faces[.back]![2] = faces[.right]![2]
                faces[.right]![2] = temp
            } else {
                faces[.front]![2] = faces[.right]![2]
                faces[.right]![2] = faces[.back]![2]
                faces[.back]![2] = faces[.left]![2]
                faces[.left]![2] = temp
            }
        }
    }
    
    private mutating func rotateF(clockwise: Bool, times: Int) {
        for _ in 0..<times {
            rotateFace(.front, clockwise: clockwise)
            
            let topRow = faces[.top]![2]
            let rightCol = [faces[.right]![0][0], faces[.right]![1][0], faces[.right]![2][0]]
            let bottomRow = faces[.bottom]![0]
            let leftCol = [faces[.left]![0][2], faces[.left]![1][2], faces[.left]![2][2]]
            
            if clockwise {
                faces[.top]![2] = [leftCol[2], leftCol[1], leftCol[0]]
                faces[.right]![0][0] = topRow[0]
                faces[.right]![1][0] = topRow[1]
                faces[.right]![2][0] = topRow[2]
                faces[.bottom]![0] = [rightCol[2], rightCol[1], rightCol[0]]
                faces[.left]![0][2] = bottomRow[0]
                faces[.left]![1][2] = bottomRow[1]
                faces[.left]![2][2] = bottomRow[2]
            } else {
                faces[.top]![2] = [rightCol[0], rightCol[1], rightCol[2]]
                faces[.left]![0][2] = topRow[0]
                faces[.left]![1][2] = topRow[1]
                faces[.left]![2][2] = topRow[2]
                faces[.bottom]![0] = [leftCol[0], leftCol[1], leftCol[2]]
                faces[.right]![0][0] = bottomRow[2]
                faces[.right]![1][0] = bottomRow[1]
                faces[.right]![2][0] = bottomRow[0]
            }
        }
    }
    
    private mutating func rotateB(clockwise: Bool, times: Int) {
        for _ in 0..<times {
            rotateFace(.back, clockwise: clockwise)
            
            let topRow = faces[.top]![0]
            let leftCol = [faces[.left]![0][0], faces[.left]![1][0], faces[.left]![2][0]]
            let bottomRow = faces[.bottom]![2]
            let rightCol = [faces[.right]![0][2], faces[.right]![1][2], faces[.right]![2][2]]
            
            if clockwise {
                faces[.top]![0] = [rightCol[0], rightCol[1], rightCol[2]]
                faces[.left]![0][0] = topRow[2]
                faces[.left]![1][0] = topRow[1]
                faces[.left]![2][0] = topRow[0]
                faces[.bottom]![2] = [leftCol[0], leftCol[1], leftCol[2]]
                faces[.right]![0][2] = bottomRow[2]
                faces[.right]![1][2] = bottomRow[1]
                faces[.right]![2][2] = bottomRow[0]
            } else {
                faces[.top]![0] = [leftCol[2], leftCol[1], leftCol[0]]
                faces[.right]![0][2] = topRow[0]
                faces[.right]![1][2] = topRow[1]
                faces[.right]![2][2] = topRow[2]
                faces[.bottom]![2] = [rightCol[2], rightCol[1], rightCol[0]]
                faces[.left]![0][0] = bottomRow[0]
                faces[.left]![1][0] = bottomRow[1]
                faces[.left]![2][0] = bottomRow[2]
            }
        }
    }
    
    private mutating func rotateR(clockwise: Bool, times: Int) {
        for _ in 0..<times {
            rotateFace(.right, clockwise: clockwise)
            
            let frontCol = [faces[.front]![0][2], faces[.front]![1][2], faces[.front]![2][2]]
            let topCol = [faces[.top]![0][2], faces[.top]![1][2], faces[.top]![2][2]]
            let backCol = [faces[.back]![0][0], faces[.back]![1][0], faces[.back]![2][0]]
            let bottomCol = [faces[.bottom]![0][2], faces[.bottom]![1][2], faces[.bottom]![2][2]]
            
            if clockwise {
                faces[.front]![0][2] = bottomCol[0]
                faces[.front]![1][2] = bottomCol[1]
                faces[.front]![2][2] = bottomCol[2]
                faces[.top]![0][2] = frontCol[0]
                faces[.top]![1][2] = frontCol[1]
                faces[.top]![2][2] = frontCol[2]
                faces[.back]![0][0] = topCol[2]
                faces[.back]![1][0] = topCol[1]
                faces[.back]![2][0] = topCol[0]
                faces[.bottom]![0][2] = backCol[2]
                faces[.bottom]![1][2] = backCol[1]
                faces[.bottom]![2][2] = backCol[0]
            } else {
                faces[.front]![0][2] = topCol[0]
                faces[.front]![1][2] = topCol[1]
                faces[.front]![2][2] = topCol[2]
                faces[.bottom]![0][2] = frontCol[0]
                faces[.bottom]![1][2] = frontCol[1]
                faces[.bottom]![2][2] = frontCol[2]
                faces[.back]![0][0] = bottomCol[2]
                faces[.back]![1][0] = bottomCol[1]
                faces[.back]![2][0] = bottomCol[0]
                faces[.top]![0][2] = backCol[2]
                faces[.top]![1][2] = backCol[1]
                faces[.top]![2][2] = backCol[0]
            }
        }
    }
    
    private mutating func rotateL(clockwise: Bool, times: Int) {
        for _ in 0..<times {
            rotateFace(.left, clockwise: clockwise)
            
            let frontCol = [faces[.front]![0][0], faces[.front]![1][0], faces[.front]![2][0]]
            let topCol = [faces[.top]![0][0], faces[.top]![1][0], faces[.top]![2][0]]
            let backCol = [faces[.back]![0][2], faces[.back]![1][2], faces[.back]![2][2]]
            let bottomCol = [faces[.bottom]![0][0], faces[.bottom]![1][0], faces[.bottom]![2][0]]
            
            if clockwise {
                faces[.front]![0][0] = topCol[0]
                faces[.front]![1][0] = topCol[1]
                faces[.front]![2][0] = topCol[2]
                faces[.bottom]![0][0] = frontCol[0]
                faces[.bottom]![1][0] = frontCol[1]
                faces[.bottom]![2][0] = frontCol[2]
                faces[.back]![0][2] = bottomCol[2]
                faces[.back]![1][2] = bottomCol[1]
                faces[.back]![2][2] = bottomCol[0]
                faces[.top]![0][0] = backCol[2]
                faces[.top]![1][0] = backCol[1]
                faces[.top]![2][0] = backCol[0]
            } else {
                faces[.front]![0][0] = bottomCol[0]
                faces[.front]![1][0] = bottomCol[1]
                faces[.front]![2][0] = bottomCol[2]
                faces[.top]![0][0] = frontCol[0]
                faces[.top]![1][0] = frontCol[1]
                faces[.top]![2][0] = frontCol[2]
                faces[.back]![0][2] = topCol[2]
                faces[.back]![1][2] = topCol[1]
                faces[.back]![2][2] = topCol[0]
                faces[.bottom]![0][0] = backCol[2]
                faces[.bottom]![1][0] = backCol[1]
                faces[.bottom]![2][0] = backCol[0]
            }
        }
    }
}
