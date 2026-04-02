//  CoachWidget.swift
//  Views/Components
//
//  Quick coaching tips during timer use


import SwiftUI

@MainActor
class CoachWidgetViewModel: ObservableObject {
    @Published var showTip = false
    @Published var currentAdvice: String?
    
    func showQuickTip(for stage: DNAStage, method: SolvingMethod, using coach: SolveCoach) {
        coach.generateQuickTip(for: stage, method: method)
        
        // Wait for response
        Task {
            // Poll for result
            for _ in 0..<50 { // Max 5 seconds
                try? await Task.sleep(nanoseconds: 100_000_000) // 0.1s
                if case .done(let advice) = coach.state {
                    await MainActor.run {
                        self.currentAdvice = advice
                        self.showTip = true
                    }
                    break
                }
            }
            
            // Auto-hide after 8 seconds
            try? await Task.sleep(nanoseconds: 8_000_000_000)
            await MainActor.run {
                withAnimation {
                    self.showTip = false
                }
            }
        }
    }
}

struct CoachWidget: View {
    @EnvironmentObject var coach: SolveCoach
    @ObservedObject var viewModel: CoachWidgetViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            if viewModel.showTip, let advice = viewModel.currentAdvice {
                HStack(spacing: 12) {
                    Image(systemName: "brain.head.profile")
                        .foregroundStyle(.indigo)
                        .font(.title3)
                    
                    Text(advice)
                        .font(.caption)
                        .lineLimit(2)
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation {
                            viewModel.showTip = false
                        }
                    }) {
                        Image(systemName: "xmark")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()
                .background(Color.indigo.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.indigo.opacity(0.15), lineWidth: 1)
                )
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.spring(), value: viewModel.showTip)
    }
}
