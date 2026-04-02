//  SolveDNAView.swift
//  Views/Timer


import SwiftUI

// MARK: - DNA Split Button (method-aware)

struct DNASplitControl: View {
    @EnvironmentObject var vm: TimerViewModel

    var body: some View {
        Button(action: { vm.recordDNASplit() }) {
            Label("Split — done with \(vm.currentDNAStage.solveStage.displayName)", systemImage: "scissors")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.indigo)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Full DNA Analysis

struct SolveDNAView: View {
    @EnvironmentObject var vm: TimerViewModel
    @EnvironmentObject var tutorialVM: TutorialViewModel

    private var methodFilterPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach([SolvingMethod.beginners, .cfop], id: \.self) { method in  // Removed .roux, .zz, .petrus
                    Button(action: { selectedMethod = method }) {
                        Text(method.rawValue)
                            .font(.subheadline)
                            .fontWeight(selectedMethod == method ? .semibold : .regular)
                            .foregroundStyle(selectedMethod == method ? .white : .primary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(selectedMethod == method ? Color.indigo : Color(uiColor: .tertiarySystemFill))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        if dnaEligibleSolves.isEmpty {
                            emptyState
                                .padding(.top, 80)
                        } else {
                            // Method filter
                            methodFilterPicker
                                .padding(.horizontal, 16)
                            
                            breakdownCard
                                .padding(.horizontal, 16)

                            if let weak = weakestStage {
                                weaknessCard(weak)
                                    .padding(.horizontal, 16)
                            }

                            if dnaEligibleSolves.count >= 3, let weak = weakestStage {
                                SolveCoachView(input: coachInput(weak))
                                    .padding(.horizontal, 16)
                            } else if !dnaEligibleSolves.isEmpty {
                                coachUnlockHint
                                    .padding(.horizontal, 16)
                            }

                            historyList
                                .padding(.horizontal, 16)
                        }
                    }
                    .padding(.vertical, 16)
                }
                .scrollIndicators(.hidden)  // FIXED: Hide scroll bar
            }
            .navigationTitle("Solve DNA")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    // MARK: - Method Filter

    @State private var selectedMethod: SolvingMethod = .cfop



    // MARK: - Data (FIXED: Method-specific)

    private var dnaEligibleSolves: [TimerSolve] {
        vm.currentSession.solves.filter { solve in
            // FIXED: Only show solves that match selected method
            guard let solveMethod = solve.method else { return false }
            return solveMethod == selectedMethod && solve.splits.count == methodStageCount(solveMethod)
        }
    }

    private func methodStageCount(_ method: SolvingMethod) -> Int {
        switch method {
        case .beginners, .cfop: return 4  // Cross, F2L, OLL, PLL
        }
    }

    private var methodStages: [SolveStage] {
        switch selectedMethod {
        case .beginners, .cfop:
            return [.cross, .f2l, .oll, .pll]
        }
    }

    private var averages: [SolveStage: Double] {
        var totals: [SolveStage: Double] = [:]
        var counts: [SolveStage: Int] = [:]

        for solve in dnaEligibleSolves {
            for split in solve.splits {
                totals[split.stage, default: 0] += split.duration
                counts[split.stage, default: 0] += 1
            }
        }

        return totals.mapValues { total in
            let stage = totals.first(where: { $0.value == total })!.key
            return total / Double(counts[stage, default: 1])
        }
    }

    private var weakestStage: SolveStage? {
        averages.max(by: { $0.value < $1.value })?.key
    }

    private var avgTotal: Double {
        averages.values.reduce(0, +)
    }

    // MARK: - Views

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "waveform.path.ecg")
                .font(.system(size: 72))
                .foregroundStyle(.secondary)
                .symbolRenderingMode(.hierarchical)

            Text("No DNA Data Yet")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Enable Solve DNA in the timer, select your method, then tap Split after each stage")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
    }

    private var breakdownCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Stage Breakdown")
                    .font(.headline)
                Spacer()
                Text("\(dnaEligibleSolves.count) solves")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            ForEach(methodStages) { stage in
                let avg = averages[stage] ?? 0
                let pct = avgTotal > 0 ? avg / avgTotal : 0

                HStack(spacing: 12) {
                    Text(stage.displayName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .frame(width: 60, alignment: .leading)

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .fill(Color(uiColor: .tertiarySystemFill))

                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .fill(Color.primary.opacity(0.2))
                                .frame(width: geo.size.width * pct)
                        }
                    }
                    .frame(height: 28)

                    Text(formatSplit(avg))
                        .font(.caption)
                        .fontWeight(.semibold)
                        .monospacedDigit()
                        .frame(width: 56, alignment: .trailing)
                }
            }
        }
        .padding(16)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func weaknessCard(_ stage: SolveStage) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label {
                Text("Your Weak Spot")
                    .font(.headline)
            } icon: {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.primary)
            }

            Text("\(stage.displayName) is taking \(Int((averages[stage] ?? 0) / avgTotal * 100))% of your solve time. Focus here for the biggest improvement.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Button(action: { linkToTutorial(stage) }) {
                Label("Work on \(stage.displayName)", systemImage: "book.fill")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.indigo)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
        }
        .padding(16)
        .background(Color.indigo.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(Color.indigo.opacity(0.3), lineWidth: 1)
        )
    }

    private var coachUnlockHint: some View {
        HStack(spacing: 12) {
            Image(systemName: "brain.head.profile")
                .foregroundStyle(.indigo)
                .font(.title3)
            
            VStack(alignment: .leading, spacing: 3) {
                Text("AI Coach unlocks at 3 DNA solves")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text("\(3 - dnaEligibleSolves.count) more to go")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(14)
        .background(Color.indigo.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(Color.indigo.opacity(0.2), lineWidth: 1)
        )
    }

    private var historyList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Solve History")
                .font(.headline)

            VStack(spacing: 8) {
                ForEach(dnaEligibleSolves.reversed()) { solve in
                    DNASolveRow(solve: solve)
                }
            }
        }
    }

    // MARK: - Actions

    private func linkToTutorial(_ stage: SolveStage) {
        switch stage.method {
        case "CFOP":
            tutorialVM.changeMethod(.cfop)
            tutorialVM.currentStepIndex = stage.tutorialMethodStep

        default:
            tutorialVM.changeMethod(.beginners)
        }
    }

    private func coachInput(_ weak: SolveStage) -> DNACoachInput {
        DNACoachInput(
            solveCount: dnaEligibleSolves.count,
            averages: averages,
            weakestStage: weak,
            weakestPct: avgTotal > 0 ? Int((averages[weak] ?? 0) / avgTotal * 100) : 0,
            bestSingle: dnaEligibleSolves.compactMap { $0.cleanTime }.min(),
            methodName: selectedMethod.rawValue,
            recentSolves: Array(dnaEligibleSolves.suffix(10)),
            previousAdvice: nil
        )
    }

    private func formatSplit(_ s: Double) -> String {
        String(format: "%.2fs", s)
    }
}

// MARK: - DNA Solve Row

struct DNASolveRow: View {
    let solve: TimerSolve

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(solve.displayTime)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .monospacedDigit()
                Spacer()
                Text(solve.date, style: .time)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 4) {
                let total = solve.splits.map(\.duration).reduce(0, +)
                ForEach(solve.splits) { split in
                    let pct = total > 0 ? split.duration / total : 0
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .fill(Color.primary.opacity(0.15))
                        .frame(height: 16)
                        .overlay(
                            Text(String(format: "%.1f", split.duration))
                                .font(.system(size: 9))
                                .fontWeight(.medium)
                                .foregroundStyle(.white)
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                        )
                        .scaleEffect(x: pct * CGFloat(solve.splits.count), anchor: .leading)
                }
            }
        }
        .padding(12)
        .background(Color(uiColor: .tertiarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

#Preview {
    SolveDNAView()
        .environmentObject(TimerViewModel())
        .environmentObject(TutorialViewModel())
}
