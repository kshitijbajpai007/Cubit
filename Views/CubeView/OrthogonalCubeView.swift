//  OrthogonalCubeView.swift
//  Views/CubeView
//
//  Displays an isometric (orthogonal) 2D projection of a Rubik's Cube.
//  Shows the Top (U), Front (F), and Right (R) faces, which is the standard
//  viewing angle for algorithmic diagrams (especially F2L).


import SwiftUI

struct OrthogonalCubeView: View {
    let cubeState: CubeState
    
    // Constants for drawing the isometric projection
    private let a = CGFloat(0.86602540378) // cos(30 degrees)
    private let b = CGFloat(0.5)           // sin(30 degrees)
    
    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            // Center the cube in the available space.
            // A 3x3 cube has a "radius" of 3 units in isometric space.
            // The total width is roughly 6 * a units, and total height is roughly 6 units.
            let unit = size / 6.5 
            
            ZStack {
                // We draw the layers back to front to avoid clipping issues,
                // but since these are distinct faces, we can just draw U, F, R.
                
                // BACK/HIDDEN faces are not drawn.
                
                // TOP FACE (U)
                drawFace(face: .top, unit: unit, origin: CGPoint(x: size / 2, y: size / 2 - 1.5 * unit), type: .top)
                
                // FRONT FACE (F)
                drawFace(face: .front, unit: unit, origin: CGPoint(x: size / 2 - 1.5 * a * unit, y: size / 2 + 1.5 * b * unit), type: .leftIso)
                
                // RIGHT FACE (R)
                drawFace(face: .right, unit: unit, origin: CGPoint(x: size / 2 + 1.5 * a * unit, y: size / 2 + 1.5 * b * unit), type: .rightIso)
            }
            .frame(width: size, height: size)
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
        .aspectRatio(1.0, contentMode: .fit)
    }
    
    enum IsoFaceType {
        case top        // A diamond lying flat
        case leftIso    // A diamond slanted down-left
        case rightIso   // A diamond slanted down-right
    }
    
    private func drawFace(face: CubeFace, unit: CGFloat, origin: CGPoint, type: IsoFaceType) -> some View {
        guard let stickers = cubeState.faces[face] else { return AnyView(EmptyView()) }
        
        return AnyView(
            ZStack {
                // Loop through 3x3 grid
                ForEach(0..<3, id: \.self) { row in
                    ForEach(0..<3, id: \.self) { col in
                        let color = stickers[row][col].color
                        
                        // Calculate standard 2D grid offset from the center of the 3x3 face
                        // We map (row, col) from 0...2 to -1...1
                        // For .top face logic: top-left is back-left, bottom-right is front-right in diagram.
                        // Standard WCA top face: (0,0) is top-left (back-left in 3D).
                        
                        let isoPath = pathForSticker(row: row, col: col, unit: unit, type: type)
                        
                        ZStack {
                            isoPath
                                .fill(color)
                            
                            isoPath
                                .stroke(Color.black.opacity(0.8), lineWidth: 1.5)
                        }
                        // Offset the entire face to its correct isometric origin
                        .offset(x: origin.x, y: origin.y)
                    }
                }
            }
        )
    }
    
    private func pathForSticker(row: Int, col: Int, unit: CGFloat, type: IsoFaceType) -> Path {
        // We calculate the 4 corners of the sticker polygon
        // A single sticker is a 1x1 square in local coordinates
        // For the 3x3 grid, local x and y range from -1.5 to 1.5
        let x = CGFloat(col) - 1.5
        let y = CGFloat(row) - 1.5
        
        var path = Path()
        
        let p1 = project(x: x, y: y, type: type)
        let p2 = project(x: x + 1, y: y, type: type)
        let p3 = project(x: x + 1, y: y + 1, type: type)
        let p4 = project(x: x, y: y + 1, type: type)
        
        // Scale by unit
        path.move(to: CGPoint(x: p1.x * unit, y: p1.y * unit))
        path.addLine(to: CGPoint(x: p2.x * unit, y: p2.y * unit))
        path.addLine(to: CGPoint(x: p3.x * unit, y: p3.y * unit))
        path.addLine(to: CGPoint(x: p4.x * unit, y: p4.y * unit))
        path.closeSubpath()
        
        return path
    }
    
    // Convert a local 2D face coordinate into an isometric 2D offset from the face's center.
    private func project(x: CGFloat, y: CGFloat, type: IsoFaceType) -> CGPoint {
        switch type {
        case .top:
            // Top face: (0,0) is back-left corner.
            // X goes right/down, Y goes left/down
            // Note: Standard Rubik's cube Top Face array mapping:
            // [0][0] is back-left. [0][2] is back-right.
            // [2][0] is front-left. [2][2] is front-right.
            let isoX = (x - y) * a
            let isoY = (x + y) * b
            return CGPoint(x: isoX, y: isoY)
            
        case .leftIso: // Front Face
            // Front face: (0,0) is top-left.
            // X goes right/down (matches Top Face X), Y goes straight down.
            let isoX = x * a
            let isoY = x * b + y
            return CGPoint(x: isoX, y: isoY)
            
        case .rightIso: // Right Face
            // Right face: (0,0) is top-left (which touches Front top-right).
            // X goes right/up (matches Top Face -Y axis?), Y goes straight down.
            let isoX = x * a
            let isoY = -x * b + y
            return CGPoint(x: isoX, y: isoY)
        }
    }
}

#Preview {
    VStack {
        // Solved
        OrthogonalCubeView(cubeState: CubeState())
            .frame(width: 200, height: 200)
            .padding()
            .background(Color(uiColor: .systemGroupedBackground))
        
        // Scrambled
        OrthogonalCubeView(cubeState: {
            var state = CubeState()
            state.applyMove(.R)
            state.applyMove(.U)
            state.applyMove(.RPrime)
            state.applyMove(.UPrime)
            return state
        }())
        .frame(width: 100, height: 100)
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
    }
}
