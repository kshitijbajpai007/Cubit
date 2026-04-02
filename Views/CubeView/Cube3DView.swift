//  Cube3DView.swift
//  Views/CubeView
//
//  Renders the cube as a 2D unfolded net (cross layout):
//
//           [ Top  ]
//  [Left] [Front] [Right] [Back]
//          [Bottom]

import SwiftUI

struct Cube3DView: View {
    let cubeState: CubeState
    /// Uniform scale factor. Default 1.0 (full size). Use smaller values (e.g. 0.7)
    /// when embedding alongside other content so the net stays fully visible.
    var scale: CGFloat = 1.0

    private var stickerSize: CGFloat { 26 * scale }
    private var gap: CGFloat        {  2 * scale }
    private var faceGap: CGFloat    {  3 * scale }
    private var facePadding: CGFloat{  3 * scale }

    private var faceSize: CGFloat {
        stickerSize * 3 + gap * 2
    }

    var body: some View {
        VStack(spacing: faceGap) {

            // Row 1 — Top face, centered above Front
            HStack(spacing: faceGap) {
                blankFace
                faceGrid(cubeState.faces[.top] ?? emptyFace)
                blankFace
                blankFace
            }

            // Row 2 — Left / Front / Right / Back
            HStack(spacing: faceGap) {
                faceGrid(cubeState.faces[.left] ?? emptyFace)
                faceGrid(cubeState.faces[.front] ?? emptyFace)
                faceGrid(cubeState.faces[.right] ?? emptyFace)
                faceGrid(cubeState.faces[.back] ?? emptyFace)
            }

            // Row 3 — Bottom face, centered below Front
            HStack(spacing: faceGap) {
                blankFace
                faceGrid(cubeState.faces[.bottom] ?? emptyFace)
                blankFace
                blankFace
            }
        }
    }

    // MARK: - Sub-views

    /// Renders one 3×3 face grid
    private func faceGrid(_ face: [[StickerColor]]) -> some View {
        VStack(spacing: gap) {
            ForEach(0..<3, id: \.self) { row in
                HStack(spacing: gap) {
                    ForEach(0..<3, id: \.self) { col in
                        RoundedRectangle(cornerRadius: 3)
                            .fill(face[row][col].color)
                            .frame(width: stickerSize, height: stickerSize)
                            .overlay(
                                RoundedRectangle(cornerRadius: 3)
                                    .stroke(Color.black.opacity(0.35), lineWidth: 1)
                            )
                    }
                }
            }
        }
        .padding(facePadding)
        .background(Color.black.opacity(0.6))
        .cornerRadius(5 * scale)
    }

    /// Invisible placeholder so the cross shape lines up correctly.
    /// Must match the full rendered size of faceGrid (faceSize + facePadding*2).
    private var blankFace: some View {
        Color.clear
            .frame(width: faceSize + facePadding * 2, height: faceSize + facePadding * 2)
    }

    private var emptyFace: [[StickerColor]] {
        Array(repeating: Array(repeating: .none, count: 3), count: 3)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        Cube3DView(cubeState: CubeState())
    }
}
