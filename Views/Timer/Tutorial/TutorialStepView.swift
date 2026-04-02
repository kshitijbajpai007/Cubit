//  TutorialStepView.swift
//  Views/Tutorial


import SwiftUI

struct TutorialStepView: View {
    let method: SolvingMethod
    
    @EnvironmentObject var tutorialViewModel: TutorialViewModel
    @EnvironmentObject var cubeViewModel: CubeViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var currentStep = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Progress bar
            progressBar
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(uiColor: .secondarySystemGroupedBackground))
            
            // Content - hidden scroll indicators
            ScrollView {
                if currentStep < method.steps.count {
                    let step = method.steps[currentStep]
                    
                    VStack(alignment: .leading, spacing: 24) {
                        // Title + description
                        VStack(alignment: .leading, spacing: 8) {
                            Text(step.title)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text(step.description)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        
                        Divider()
                        
                        // Instructions
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Instructions")
                                .font(.headline)
                            
                            Text(step.detailedInstructions)
                                .font(.body)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        
                        // Key algorithms
                        if !step.keyAlgorithms.isEmpty {
                            Divider()
                            
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Key Algorithms")
                                    .font(.headline)
                                
                                ForEach(step.keyAlgorithms) { algorithm in
                                    algorithmCard(algorithm)
                                }
                            }
                        }
                        
                        // Practice patterns
                        if !step.practicePatterns.isEmpty {
                            Divider()
                            
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Practice Patterns")
                                    .font(.headline)
                                
                                ForEach(step.practicePatterns, id: \.self) { pattern in
                                    Text("• \(pattern)")
                                        .font(.subheadline)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                        }
                        
                        // Tips
                        if !step.tips.isEmpty {
                            Divider()
                            
                            VStack(alignment: .leading, spacing: 12) {
                                Label("Tips", systemImage: "lightbulb.fill")
                                    .font(.headline)
                                    .foregroundStyle(.indigo)
                                
                                ForEach(step.tips, id: \.self) { tip in
                                    HStack(alignment: .top, spacing: 8) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.caption)
                                            .foregroundStyle(.indigo)
                                        Text(tip)
                                            .font(.subheadline)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                }
                            }
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.indigo.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                }
            }
            .scrollIndicators(.hidden)  // FIXED: Hide scroll bar
            .background(Color(uiColor: .systemGroupedBackground))
            
            // Navigation controls
            navigationControls
                .padding(16)
                .background(Color(uiColor: .secondarySystemGroupedBackground))
        }
        .navigationTitle(method.rawValue)
        .navigationBarTitleDisplayMode(.inline)
        // FIXED: Removed redundant Close button - back chevron is automatic
    }
    
    // MARK: - Components
    
    private var progressBar: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Step \(currentStep + 1) of \(method.steps.count)")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(Int(Double(currentStep + 1) / Double(method.steps.count) * 100))%")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.indigo)
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .fill(Color(uiColor: .tertiarySystemFill))
                    
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .fill(Color.indigo)
                        .frame(width: geo.size.width * CGFloat(currentStep + 1) / CGFloat(method.steps.count))
                }
            }
            .frame(height: 8)
        }
    }
    
    private func algorithmCard(_ algorithm: Algorithm) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(algorithm.name)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Text(algorithm.notation)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
                
                Button(action: {
                    if tutorialViewModel.savedAlgorithms.contains(where: { $0.id == algorithm.id }) {
                        tutorialViewModel.removeSavedAlgorithm(algorithm)
                    } else {
                        tutorialViewModel.saveAlgorithm(algorithm)
                    }
                    HapticManager.stepChanged()
                }) {
                    Image(systemName: tutorialViewModel.savedAlgorithms.contains(where: { $0.id == algorithm.id }) ? "bookmark.fill" : "bookmark")
                        .font(.title3)
                        .foregroundStyle(tutorialViewModel.savedAlgorithms.contains(where: { $0.id == algorithm.id }) ? .indigo : .primary)
                }
                .buttonStyle(.plain)
            }
            
            InteractiveCubeStepView(algorithm: algorithm, category: algorithm.category)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color(uiColor: .tertiarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
    
    private var navigationControls: some View {
        HStack(spacing: 16) {
            // Previous
            Button(action: {
                if currentStep > 0 {
                    withAnimation { currentStep -= 1 }
                    HapticManager.stepChanged()
                }
            }) {
                Label("Previous", systemImage: "chevron.left")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(currentStep > 0 ? .indigo : .secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color(uiColor: .tertiarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
            .disabled(currentStep == 0)
            .buttonStyle(.plain)
            
            // Next / Done
            Button(action: {
                if currentStep < method.steps.count - 1 {
                    withAnimation { currentStep += 1 }
                    HapticManager.stepChanged()
                } else {
                    dismiss()
                }
            }) {
                Label(currentStep < method.steps.count - 1 ? "Next" : "Done",
                      systemImage: currentStep < method.steps.count - 1 ? "chevron.right" : "checkmark")
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
}

#Preview {
    NavigationStack {
        TutorialStepView(method: .cfop)
            .environmentObject(TutorialViewModel())
            .environmentObject(CubeViewModel())
    }
}
