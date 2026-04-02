//  SolveCoachView.swift
//  Views/Timer
//
//  Embedded inside SolveDNAView.
//  Drives the SolveCoach service and renders every state cleanly.


import SwiftUI

struct SolveCoachView: View {

    let input: DNACoachInput

    @StateObject private var coach = SolveCoach()

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            // ── Header ─────────────────────────────────────────
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(Color.indigo)
                        .frame(width: 36, height: 36)

                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("AI Solve Coach")
                        .font(.headline)
                    Text("Powered by Apple Intelligence")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }

                Spacer()

                // Availability badge
                if SolveCoach.isAvailable {
                    Label("On‑device", systemImage: "checkmark.shield.fill")
                        .font(.caption2.weight(.medium))
                        .foregroundColor(.primary)
                } else {
                    Label("Unavailable", systemImage: "xmark.shield.fill")
                        .font(.caption2.weight(.medium))
                        .foregroundColor(.secondary)
                }
            }

            Divider()

            // ── State-driven body ──────────────────────────────
            switch coach.state {

            case .idle:
                idleContent

            case .unavailable(let reason):
                unavailableContent(reason)

            case .loading:
                loadingContent

            case .done(let text):
                doneContent(text)

            case .failed(let reason):
                failedContent(reason)
            }
        }
        .padding(16)
        .background(Color(uiColor: .tertiarySystemGroupedBackground))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.primary.opacity(0.1), lineWidth: 1)
        )
    }

    // MARK: - Idle

    private var idleContent: some View {
        VStack(spacing: 12) {
            Text("Ready to analyse your **\(input.solveCount)** DNA solves and give you one targeted improvement.")
                .font(.subheadline)
                .foregroundColor(.secondary)

            if SolveCoach.isAvailable {
                Button(action: {
                    HapticManager.timerReady()
                    coach.generateAdvice(for: input)
                }) {
                    Label("Get My Coaching Tip", systemImage: "sparkles")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                        .background(Color.indigo)
                        .cornerRadius(12)
                }
            } else {
                unavailableContent("Apple Intelligence is not available on this device.")
            }
        }
    }

    // MARK: - Unavailable

    private func unavailableContent(_ reason: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.primary)
                .font(.subheadline)
                .padding(.top, 2)

            Text(reason)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }

    // MARK: - Loading

    private var loadingContent: some View {
        HStack(spacing: 12) {
            ProgressView()
                .tint(.indigo)

            Text("Coach is analysing your data…")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 8)
    }

    // MARK: - Done

    private func doneContent(_ text: String) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(text)
                .font(.body)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 10) {
                // Regenerate
                Button(action: {
                    HapticManager.timerReady()
                    coach.reset()
                    coach.generateAdvice(for: input)
                }) {
                    Label("New tip", systemImage: "arrow.clockwise")
                        .font(.caption.weight(.medium))
                        .foregroundColor(.indigo)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(Color.indigo.opacity(0.1))
                        .cornerRadius(8)
                }

                Spacer()

                // Dismiss
                Button(action: {
                    coach.reset()
                }) {
                    Label("Dismiss", systemImage: "xmark")
                        .font(.caption.weight(.medium))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(8)
                }
            }
        }
    }

    // MARK: - Failed

    private func failedContent(_ reason: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "exclamationmark.circle.fill")
                    .foregroundColor(.primary)
                Text(reason)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Button(action: {
                coach.generateAdvice(for: input)
            }) {
                Label("Try again", systemImage: "arrow.clockwise")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 11)
                    .background(Color.primary)
                    .cornerRadius(10)
            }
        }
    }
}

#Preview {
    ScrollView {
        SolveCoachView(
            input: DNACoachInput(
                solveCount: 12,
                averages: [
                    SolveStage.cross: 3.2,
                    SolveStage.f2l:   18.4,
                    SolveStage.oll:   5.1,
                    SolveStage.pll:   4.8
                ],
                weakestStage: SolveStage.f2l,
                weakestPct: 58,
                bestSingle: 31.5,
                methodName: "CFOP",
                recentSolves: [],
                previousAdvice: nil
            )
        )
        .padding()
    }
}
