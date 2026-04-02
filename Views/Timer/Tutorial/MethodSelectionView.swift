//  MethodSelectionView.swift
//  Views/Tutorial


import SwiftUI

struct MethodSelectionView: View {
    @EnvironmentObject var tutorialViewModel: TutorialViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach([SolvingMethod.beginners, SolvingMethod.cfop], id: \.self) { method in
                        NavigationLink {
                            TutorialStepView(method: method)
                        } label: {
                            MethodCard(
                                method: method,
                                isSelected: false  // FIXED: No method selected by default
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(16)
            }
            .scrollIndicators(.hidden)  // FIXED: Hide scroll bar
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Learn")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    MethodSelectionView()
        .environmentObject(TutorialViewModel())
}
