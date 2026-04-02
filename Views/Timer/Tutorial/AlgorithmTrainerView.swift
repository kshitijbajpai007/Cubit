//  AlgorithmTrainerView.swift
//  Views/Tutorial


import SwiftUI

struct AlgorithmTrainerView: View {
    @EnvironmentObject var cubeViewModel: CubeViewModel
    @Environment(\.scenePhase) private var scenePhase
    @State private var navigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            List {
                // Algorithm Library
                Section {
                    AlgorithmLibrarySection()
                } header: {
                    Label("Algorithm Library", systemImage: "books.vertical.fill")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                }

                // Stage Practice
                StagePracticeSection()
            }
            .listStyle(.insetGrouped)
            .scrollIndicators(.hidden)  // FIXED: Hide scroll bar
            .navigationTitle("Train")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    NavigationLink(value: "Saved") {
                        Label("Saved", systemImage: "bookmark.fill")
                            .foregroundStyle(.primary)
                    }
                }
            }
            .navigationDestination(for: String.self) { value in
                if value == "Saved" {
                    SavedAlgorithmsView()
                }
            }
            .navigationDestination(for: SolveStage.self) { stage in
                StagePracticeTimerView(stage: stage)
            }
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                // Reset navigation to root when app is reopened
                navigationPath = NavigationPath()
            }
        }
    }
}

// MARK: - Algorithm Library

private struct AlgorithmLibrarySection: View {
    // Two-level state: method first, then category within that method
    @State private var selectedMethodName: String = AlgorithmLibrary.groupedByMethod[0].method
    @State private var selectedCategory: AlgorithmCategory = AlgorithmLibrary.groupedByMethod[0].categories[0]
    @EnvironmentObject var tutorialViewModel: TutorialViewModel

    private var currentGroup: (method: String, categories: [AlgorithmCategory]) {
        AlgorithmLibrary.groupedByMethod.first { $0.method == selectedMethodName }
            ?? AlgorithmLibrary.groupedByMethod[0]
    }

    var body: some View {
        VStack(spacing: 0) {

            // ── Row 1: Method pills ────────────────────────────
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(AlgorithmLibrary.groupedByMethod, id: \.method) { group in
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.18)) {
                                selectedMethodName = group.method
                                selectedCategory   = group.categories[0]
                            }
                        }) {
                            Text(group.method)
                                .font(.subheadline)
                                .fontWeight(selectedMethodName == group.method ? .semibold : .regular)
                                .foregroundStyle(selectedMethodName == group.method ? .white : .primary)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    selectedMethodName == group.method
                                        ? Color.indigo
                                        : Color(uiColor: .tertiarySystemFill)
                                )
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 4)
                .padding(.vertical, 10)
            }

            // ── Row 2: Category pills for selected method ──────
            if currentGroup.categories.count > 1 {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(currentGroup.categories, id: \.self) { cat in
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.15)) {
                                    selectedCategory = cat
                                }
                            }) {
                                Text(cat.rawValue)
                                    .font(.subheadline)
                                    .fontWeight(selectedCategory == cat ? .semibold : .regular)
                                    .foregroundStyle(selectedCategory == cat ? Color(uiColor: .systemBackground) : .primary)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 7)
                                    .background(
                                        selectedCategory == cat
                                            ? Color.primary
                                            : Color(uiColor: .tertiarySystemFill)
                                    )
                                    .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 4)
                    .padding(.bottom, 10)
                }
            }

            // ── Algorithm list ─────────────────────────────────
            let algorithms = AlgorithmLibrary.algorithms(for: selectedCategory)

            if algorithms.isEmpty {
                emptyLibraryView
            } else {
                VStack(spacing: 0) {
                    ForEach(algorithms) { algorithm in
                        AlgorithmCard(algorithm: algorithm, category: selectedCategory)
                            .padding(.top, 12)
                    }
                }
            }
        }
    }

    private var emptyLibraryView: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text("No algorithms in this category")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
    }
}

// MARK: - Algorithm Card

struct AlgorithmCard: View {
    let algorithm: Algorithm
    let category: AlgorithmCategory

    @EnvironmentObject var tutorialViewModel: TutorialViewModel
    @State private var showDemo = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 14) {
                // Diagram
                Group {
                    if category == .oll {
                        OLLDiagramView(algorithm: algorithm)
                    } else if category == .pll {
                        PLLDiagramView(algorithm: algorithm)
                    } else if category == .f2l || category == .beginners {
                        OrthogonalCubeView(cubeState: previewState)
                    } else {
                        Cube3DView(cubeState: previewState)
                            .scaleEffect(0.45)
                            .clipped()
                    }
                }
                .frame(width: 52, height: 52)

                // Name + notation
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(algorithm.name)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Spacer()
                        Button(action: toggleBookmark) {
                            Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                                .font(.subheadline)
                                .foregroundStyle(isBookmarked ? .indigo : .primary)
                        }
                        .buttonStyle(.plain)
                    }

                    Text(algorithm.notation)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)

                    if let pb = algorithm.personalBest {
                        Label(SolveStatistics.formatTime(pb), systemImage: "trophy.fill")
                            .font(.caption2)
                            .foregroundStyle(.primary)
                    }
                }
            }

            Button(action: { showDemo = true }) {
                Label("Demo — step through on live cube", systemImage: "play.circle.fill")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 11)
                    .background(Color.indigo)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .buttonStyle(.plain)
        }
        .padding(14)
        .background(Color(uiColor: .tertiarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .sheet(isPresented: $showDemo) {
            NavigationStack {
                ScrollView {
                    VStack(spacing: 16) {
                        if category == .oll || category == .pll {
                            Group {
                                if category == .oll {
                                    OLLDiagramView(algorithm: algorithm)
                                } else {
                                    PLLDiagramView(algorithm: algorithm)
                                }
                            }
                            .scaleEffect(2.0)
                            .frame(height: 120)
                            .padding(.top)
                        } else if category == .f2l || category == .beginners {
                            OrthogonalCubeView(cubeState: previewState)
                                .frame(height: 140)
                                .padding(.top)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text(algorithm.name)
                                .font(.title2)
                                .fontWeight(.bold)
                            Text(algorithm.notation)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)

                        InteractiveCubeStepView(algorithm: algorithm, category: algorithm.category)
                            .padding(.horizontal)
                    }
                }
                .scrollIndicators(.hidden)  // FIXED: Hide scroll bar in sheet
                .navigationTitle("Demo")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") { showDemo = false }
                    }
                }
            }
        }
    }

    private var isBookmarked: Bool {
        tutorialViewModel.savedAlgorithms.contains(where: { $0.id == algorithm.id })
    }

    private func toggleBookmark() {
        if isBookmarked {
            tutorialViewModel.removeSavedAlgorithm(algorithm)
        } else {
            tutorialViewModel.saveAlgorithm(algorithm)
        }
        HapticManager.stepChanged()
    }

    private var previewState: CubeState {
        var cube = CubeState()
        for move in algorithm.moves.reversed() {
            cube.applyMove(move.inverse)
        }
        return cube
    }
}

// MARK: - Stage Practice

@MainActor
private let stagePracticeGroups: [(method: String, icon: String, color: Color, stages: [SolveStage])] = [
    ("Stage Practice", "flame.fill", .indigo, [.cross, .f2l, .oll, .pll])
]

private struct StagePracticeSection: View {
    var body: some View {
        ForEach(stagePracticeGroups, id: \.method) { group in
            Section {
                ForEach(group.stages) { stage in
                    NavigationLink(value: stage) {
                        StagePracticeRow(stage: stage)
                    }
                    .buttonStyle(.plain)
                }
            } header: {
                Label(group.method, systemImage: group.icon)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
            }
        }
    }
}

private struct StagePracticeRow: View {
    let stage: SolveStage

    var body: some View {
        HStack(spacing: 14) {
            Circle()
                .fill(.primary.opacity(0.15))
                .frame(width: 8, height: 8)

            VStack(alignment: .leading, spacing: 2) {
                Text(stage.displayName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(stage.subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 4)
    }
}

// MARK: - Saved

struct SavedAlgorithmsView: View {
    @EnvironmentObject var tutorialViewModel: TutorialViewModel

    var body: some View {
        List {
            if tutorialViewModel.savedAlgorithms.isEmpty {
                emptyView
            } else {
                ForEach(tutorialViewModel.savedAlgorithms) { alg in
                    AlgorithmCard(algorithm: alg, category: alg.category)
                        .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                        .listRowBackground(Color.clear)
                }
            }
        }
        .listStyle(.plain)
        .scrollIndicators(.hidden)  // FIXED: Hide scroll bar
        .navigationTitle("Saved")
        .navigationBarTitleDisplayMode(.large)
    }

    private var emptyView: some View {
        VStack(spacing: 12) {
            Image(systemName: "bookmark")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("No saved algorithms")
                .font(.headline)
            Text("Bookmark algorithms from the library")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .listRowBackground(Color.clear)
    }
}

#Preview {
    AlgorithmTrainerView()
        .environmentObject(TutorialViewModel())
        .environmentObject(CubeViewModel())
}
