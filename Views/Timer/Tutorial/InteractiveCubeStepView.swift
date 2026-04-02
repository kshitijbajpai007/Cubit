//  InteractiveCubeStepView.swift
//  Views/Tutorial
//
//  Shows a live cube net that steps through an algorithm one move at a time.
//  The user taps forward/back arrows and watches the cube react.


import SwiftUI

struct InteractiveCubeStepView: View {
    let algorithm: Algorithm
    let category: AlgorithmCategory

    // The sequence of cube states — index 0 is the pre-algorithm state,
    // index n is the state after the nth move.
    private let states: [CubeState]
    private let moves: [CubeMove]

    @State private var currentIndex: Int = 0
    @State private var isPlaying: Bool = false
    @State private var playTask: Task<Void, Never>? = nil

    init(algorithm: Algorithm, category: AlgorithmCategory) {
        self.algorithm = algorithm
        self.category = category
        self.moves = algorithm.moves

        // Pre-compute every intermediate state so stepping is instant.
        // Start from the pre-algorithm (scrambled) state so the animation
        // shows scramble → solve, not the reverse.
        var allStates: [CubeState] = []
        var cube = CubeState()
        for move in algorithm.moves.reversed() { cube.applyMove(move.inverse) }
        allStates.append(cube)           // index 0 = scrambled start
        for move in algorithm.moves {
            cube.applyMove(move)
            allStates.append(cube)       // last index = solved
        }
        self.states = allStates
    }

    var body: some View {
        VStack(spacing: 16) {

            // ── Live cube net ──────────────────────────────────
            // scale: 0.7 renders all 6 faces at 70% — fully visible, correct layout size
            if category == .f2l || category == .beginners {
                OrthogonalCubeView(cubeState: states[currentIndex])
                    .frame(height: 180)
            } else {
                Cube3DView(cubeState: states[currentIndex], scale: 0.7)
                    .animation(.easeInOut(duration: 0.2), value: currentIndex)
            }

            // ── Move strip ────────────────────────────────────
            // Shows all moves; the current one is highlighted
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(Array(moves.enumerated()), id: \.offset) { index, move in
                            Text(move.displayName)
                                .font(.system(.subheadline, design: .monospaced).weight(.semibold))
                                .foregroundColor(moveColor(at: index))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(moveBg(at: index))
                                .cornerRadius(8)
                                .id(index)
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .onChange(of: currentIndex) { newIndex in
                    let scrollTarget = max(0, newIndex - 1)
                    withAnimation {
                        proxy.scrollTo(scrollTarget, anchor: .leading)
                    }
                }
            }
            .frame(height: 40)

            // ── Progress label ─────────────────────────────────
            Text(progressLabel)
                .font(.caption)
                .foregroundColor(.secondary)

            // ── Controls ──────────────────────────────────────
            HStack(spacing: 20) {

                // Reset to start
                controlButton(icon: "backward.end.fill", color: .secondary) {
                    stopPlayback()
                    currentIndex = 0
                }

                // Step back
                controlButton(icon: "chevron.left", color: .primary) {
                    stopPlayback()
                    if currentIndex > 0 {
                        currentIndex -= 1
                        HapticManager.stepChanged()
                    }
                }
                .disabled(currentIndex == 0)

                // Play / pause
                controlButton(
                    icon: isPlaying ? "pause.fill" : "play.fill",
                    color: .indigo,
                    size: 52
                ) {
                    isPlaying ? stopPlayback() : startPlayback()
                }

                // Step forward
                controlButton(icon: "chevron.right", color: .primary) {
                    stopPlayback()
                    if currentIndex < moves.count {
                        currentIndex += 1
                        HapticManager.stepChanged()
                    }
                }
                .disabled(currentIndex == moves.count)

                // Skip to end
                controlButton(icon: "forward.end.fill", color: .secondary) {
                    stopPlayback()
                    currentIndex = moves.count
                }
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .onDisappear { stopPlayback() }
    }

    // MARK: - Playback

    private func startPlayback() {
        if currentIndex >= moves.count {
            // Already at end — restart
            currentIndex = 0
        }
        isPlaying = true
        playTask = Task {
            while currentIndex < moves.count {
                try? await Task.sleep(nanoseconds: 600_000_000)  // 0.6 s per move
                guard !Task.isCancelled else { break }
                currentIndex += 1
                HapticManager.stepChanged()
            }
            isPlaying = false
        }
    }

    private func stopPlayback() {
        playTask?.cancel()
        playTask  = nil
        isPlaying = false
    }

    // MARK: - Helpers

    private var progressLabel: String {
        if currentIndex == 0             { return "Start position" }
        if currentIndex == moves.count   { return "Complete — \(moves.count) moves" }
        return "Move \(currentIndex) of \(moves.count)  ·  \(moves[currentIndex - 1].displayName)"
    }

    private func moveColor(at index: Int) -> Color {
        if index == currentIndex - 1 { return .white }   // just executed
        if index < currentIndex      { return .secondary }
        return .primary
    }

    private func moveBg(at index: Int) -> Color {
        if index == currentIndex - 1 { return .indigo }
        if index < currentIndex      { return Color.secondary.opacity(0.15) }
        return Color.secondary.opacity(0.08)
    }

    private func controlButton(
        icon: String,
        color: Color,
        size: CGFloat = 44,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: size * 0.38, weight: .semibold))
                .foregroundColor(color == .primary ? Color(uiColor: .label) : color)
                .frame(width: size, height: size)
                .background(color.opacity(0.12))
                .clipShape(Circle())
        }
    }
}

#Preview {
    InteractiveCubeStepView(
        algorithm: Algorithm(
            name: "T-Perm",
            notation: "R U R' U' R' F R2 U' R' U' R U R' F'",
            category: .pll
        ),
        category: .pll
    )
    .padding()
}
