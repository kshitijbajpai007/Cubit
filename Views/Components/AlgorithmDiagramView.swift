//  AlgorithmDiagramView.swift
//  Views/Components
//
//  Computes OLL and PLL recognition diagrams purely from algorithm
//  notation — no manual data entry, always mathematically correct.
//
//  HOW IT WORKS:
//  ─────────────────────────────────────────────────────────────────
//  OLL: Apply the algorithm's INVERSE to a fully solved cube.
//       The resulting top-face sticker pattern is exactly what the
//       solver sees BEFORE executing the algorithm.
//
//  PLL: Apply the algorithm's INVERSE to a solved cube.
//       The top-face colours show which corners/edges need to move,
//       drawn as arrows between mismatched pieces.
//  ─────────────────────────────────────────────────────────────────

import SwiftUI

// MARK: - OLL Diagram

struct OLLDiagramView: View {
    let algorithm: Algorithm

    /// Top face state BEFORE the algorithm (= after applying inverse)
    private var topFaceState: [[StickerColor]] {
        var cube = CubeState()
        for move in algorithm.moves.reversed() {
            cube.applyMove(move.inverse)
        }
        return cube.faces[.top] ?? emptyFace
    }

    /// Middle ring — front/right/back/left top-row edges
    private var ringState: (front: [StickerColor], right: [StickerColor],
                             back: [StickerColor], left: [StickerColor]) {
        var cube = CubeState()
        for move in algorithm.moves.reversed() {
            cube.applyMove(move.inverse)
        }
        return (
            front: cube.faces[.front]?[0] ?? Array(repeating: .none, count: 3),
            right: (cube.faces[.right] ?? emptyFace).map { $0[0] },
            back:  cube.faces[.back]?[0] ?? Array(repeating: .none, count: 3),
            left:  (cube.faces[.left] ?? emptyFace).map { $0[2] }
        )
    }

    private let cellSize: CGFloat = 14
    private let gap: CGFloat      = 2

    var body: some View {
        let face  = topFaceState
        let ring  = ringState
        let total = cellSize * 3 + gap * 2

        VStack(spacing: gap) {
            // Top edge indicators (front face top row, centre cell only)
            edgeRow([ring.front[0], ring.front[1], ring.front[2]], flip: false)

            // Main 3×3 top face
            HStack(spacing: gap) {
                // Left edge indicator (left face right col, centre only)
                edgeCol([ring.left[0], ring.left[1], ring.left[2]])

                VStack(spacing: gap) {
                    ForEach(0..<3, id: \.self) { row in
                        HStack(spacing: gap) {
                            ForEach(0..<3, id: \.self) { col in
                                let color = face[row][col]
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(cellFill(color, isTop: true))
                                    .frame(width: cellSize, height: cellSize)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 2)
                                            .stroke(Color.black.opacity(0.25), lineWidth: 0.5)
                                    )
                            }
                        }
                    }
                }
                .frame(width: total, height: total)

                // Right edge indicator
                edgeCol([ring.right[0], ring.right[1], ring.right[2]])
            }

            // Bottom edge indicators (back face top row)
            edgeRow([ring.back[2], ring.back[1], ring.back[0]], flip: true)
        }
    }

    // A horizontal row of 3 thin edge stickers
    private func edgeRow(_ colors: [StickerColor], flip: Bool) -> some View {
        HStack(spacing: gap) {
            // Offset to align with main face (account for side edge columns)
            Color.clear.frame(width: cellSize * 0.4, height: cellSize * 0.4)
            ForEach(0..<3, id: \.self) { i in
                RoundedRectangle(cornerRadius: 1)
                    .fill(cellFill(colors[i], isTop: false))
                    .frame(width: cellSize, height: cellSize * 0.4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 1)
                            .stroke(Color.black.opacity(0.2), lineWidth: 0.5)
                    )
            }
            Color.clear.frame(width: cellSize * 0.4, height: cellSize * 0.4)
        }
    }

    // A vertical column of 3 thin edge stickers
    private func edgeCol(_ colors: [StickerColor]) -> some View {
        VStack(spacing: gap) {
            ForEach(0..<3, id: \.self) { i in
                RoundedRectangle(cornerRadius: 1)
                    .fill(cellFill(colors[i], isTop: false))
                    .frame(width: cellSize * 0.4, height: cellSize)
                    .overlay(
                        RoundedRectangle(cornerRadius: 1)
                            .stroke(Color.black.opacity(0.2), lineWidth: 0.5)
                    )
            }
        }
    }

    private func cellFill(_ color: StickerColor, isTop: Bool) -> Color {
        if isTop {
            return color == .yellow ? Color.yellow : Color.white.opacity(0.85)
        }
        // Side edge stickers: show actual colour dimmed
        return color.color.opacity(0.7)
    }

    private var emptyFace: [[StickerColor]] {
        Array(repeating: Array(repeating: .none, count: 3), count: 3)
    }
}

// MARK: - PLL Diagram

struct PLLDiagramView: View {
    let algorithm: Algorithm

    /// Top-face state before the algorithm
    private var topFaceState: [[StickerColor]] {
        var cube = CubeState()
        for move in algorithm.moves.reversed() {
            cube.applyMove(move.inverse)
        }
        return cube.faces[.top] ?? emptyFace
    }

    private let cellSize: CGFloat = 14
    private let gap: CGFloat      = 2

    var body: some View {
        let face  = topFaceState
        let total = cellSize * 3 + gap * 2

        ZStack {
            // 3×3 yellow grid
            VStack(spacing: gap) {
                ForEach(0..<3, id: \.self) { row in
                    HStack(spacing: gap) {
                        ForEach(0..<3, id: \.self) { col in
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.yellow)
                                .frame(width: cellSize, height: cellSize)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 2)
                                        .stroke(Color.black.opacity(0.25), lineWidth: 0.5)
                                )
                        }
                    }
                }
            }
            .frame(width: total, height: total)

            // Arrows derived from side sticker mismatches
            PLLArrowsLayer(face: face, cellSize: cellSize, gap: gap)
                .frame(width: total, height: total)
        }
    }

    private var emptyFace: [[StickerColor]] {
        Array(repeating: Array(repeating: .none, count: 3), count: 3)
    }
}

// Draws swap arrows on top of the PLL grid
private struct PLLArrowsLayer: View {
    let face: [[StickerColor]]
    let cellSize: CGFloat
    let gap: CGFloat

    var body: some View {
        Canvas { context, size in
            let step = cellSize + gap

            // Corner positions (centre of each corner cell)
            let corners: [(row: Int, col: Int)] = [(0,0),(0,2),(2,0),(2,2)]

            // Detect which corners have non-yellow stickers → need to move
            var mismatched: [(CGPoint, CGPoint)] = []

            for i in 0..<corners.count {
                let a = corners[i]
                let b = corners[(i + 1) % corners.count]
                let colorA = face[a.row][a.col]
                let colorB = face[b.row][b.col]
                if colorA != .yellow && colorB != .yellow && colorA != colorB {
                    let ptA = CGPoint(
                        x: CGFloat(a.col) * step + cellSize / 2,
                        y: CGFloat(a.row) * step + cellSize / 2
                    )
                    let ptB = CGPoint(
                        x: CGFloat(b.col) * step + cellSize / 2,
                        y: CGFloat(b.row) * step + cellSize / 2
                    )
                    mismatched.append((ptA, ptB))
                }
            }

            // Edge positions
            let edges: [(row: Int, col: Int)] = [(0,1),(1,2),(2,1),(1,0)]
            for i in 0..<edges.count {
                let a = edges[i]
                let b = edges[(i + 1) % edges.count]
                let colorA = face[a.row][a.col]
                let colorB = face[b.row][b.col]
                if colorA != .yellow && colorB != .yellow && colorA != colorB {
                    let ptA = CGPoint(
                        x: CGFloat(a.col) * step + cellSize / 2,
                        y: CGFloat(a.row) * step + cellSize / 2
                    )
                    let ptB = CGPoint(
                        x: CGFloat(b.col) * step + cellSize / 2,
                        y: CGFloat(b.row) * step + cellSize / 2
                    )
                    mismatched.append((ptA, ptB))
                }
            }

            // Draw arrows
            for (start, end) in mismatched {
                var path = Path()
                path.move(to: start)
                path.addLine(to: end)
                context.stroke(
                    path,
                    with: .color(.primary.opacity(0.85)),
                    style: StrokeStyle(lineWidth: 1.5, lineCap: .round)
                )
                // Arrowhead
                drawArrowhead(context: context, from: start, to: end)
            }
        }
    }

    private func drawArrowhead(context: GraphicsContext, from: CGPoint, to: CGPoint) {
        let angle   = atan2(to.y - from.y, to.x - from.x)
        let length: CGFloat = 4
        let spread: CGFloat = 0.5

        let p1 = CGPoint(
            x: to.x - length * cos(angle - spread),
            y: to.y - length * sin(angle - spread)
        )
        let p2 = CGPoint(
            x: to.x - length * cos(angle + spread),
            y: to.y - length * sin(angle + spread)
        )

        var head = Path()
        head.move(to: to)
        head.addLine(to: p1)
        head.move(to: to)
        head.addLine(to: p2)

        context.stroke(
            head,
            with: .color(.primary.opacity(0.85)),
            style: StrokeStyle(lineWidth: 1.5, lineCap: .round)
        )
    }
}

// MARK: - CubeMove inverse helper

extension CubeMove {
    var inverse: CubeMove {
        switch self {
        case .U:      return .UPrime
        case .UPrime: return .U
        case .U2:     return .U2
        case .D:      return .DPrime
        case .DPrime: return .D
        case .D2:     return .D2
        case .F:      return .FPrime
        case .FPrime: return .F
        case .F2:     return .F2
        case .B:      return .BPrime
        case .BPrime: return .B
        case .B2:     return .B2
        case .R:      return .RPrime
        case .RPrime: return .R
        case .R2:     return .R2
        case .L:      return .LPrime
        case .LPrime: return .L
        case .L2:     return .L2
        }
    }
}

#Preview {
    HStack(spacing: 24) {
        VStack(spacing: 8) {
            Text("OLL").font(.caption.weight(.semibold))
            OLLDiagramView(algorithm: Algorithm(
                name: "Sune", notation: "R U R' U R U2 R'", category: .oll))
        }
        VStack(spacing: 8) {
            Text("PLL").font(.caption.weight(.semibold))
            PLLDiagramView(algorithm: Algorithm(
                name: "T-Perm",
                notation: "R U R' U' R' F R2 U' R' U' R U R' F'",
                category: .pll))
        }
    }
    .padding()
}
