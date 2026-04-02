//  TutorialViewModel.swift
//  ViewModels

import SwiftUI
import Combine

@MainActor
class TutorialViewModel: ObservableObject {
    @Published var selectedMethod: SolvingMethod = .beginners
    @Published var currentStepIndex: Int = 0
    @Published var completedSteps: Set<UUID> = []
    @Published var savedAlgorithms: [Algorithm] = []
    @Published var isTrainingMode = false
    @Published var currentTrainingAlgorithm: Algorithm?
    
    init() {
        // Load saved algorithms from UserDefaults if needed
        loadSavedAlgorithms()
    }
    
    // Current tutorial step
    var currentStep: TutorialStep? {
        let steps = selectedMethod.steps
        guard currentStepIndex < steps.count else { return nil }
        return steps[currentStepIndex]
    }
    
    // Progress through method
    var progress: Double {
        let totalSteps = selectedMethod.steps.count
        guard totalSteps > 0 else { return 0 }
        return Double(completedSteps.count) / Double(totalSteps)
    }
    
    // Check if current step is completed
    var isCurrentStepCompleted: Bool {
        guard let step = currentStep else { return false }
        return completedSteps.contains(step.id)
    }
    
    // Move to next step
    func nextStep() {
        let steps = selectedMethod.steps
        if currentStepIndex < steps.count - 1 {
            currentStepIndex += 1
        }
    }
    
    // Move to previous step
    func previousStep() {
        if currentStepIndex > 0 {
            currentStepIndex -= 1
        }
    }
    
    // Toggle step completion
    func toggleStepCompletion() {
        guard let step = currentStep else { return }
        
        if completedSteps.contains(step.id) {
            completedSteps.remove(step.id)
        } else {
            completedSteps.insert(step.id)
        }
    }
    
    // Change method
    func changeMethod(_ method: SolvingMethod) {
        selectedMethod = method
        currentStepIndex = 0
        // Keep completed steps but reset if switching to different method
    }
    
    // Reset progress for current method
    func resetProgress() {
        currentStepIndex = 0
        completedSteps.removeAll()
    }
    
    // Save algorithm for practice
    func saveAlgorithm(_ algorithm: Algorithm) {
        if !savedAlgorithms.contains(where: { $0.id == algorithm.id }) {
            savedAlgorithms.append(algorithm)
            saveToPersistence()
        }
    }
    
    // Remove saved algorithm
    func removeSavedAlgorithm(_ algorithm: Algorithm) {
        savedAlgorithms.removeAll(where: { $0.id == algorithm.id })
        saveToPersistence()
    }
    
    // Start algorithm training
    func startTraining(with algorithm: Algorithm) {
        isTrainingMode = true
        currentTrainingAlgorithm = algorithm
    }
    
    // Stop training
    func stopTraining() {
        isTrainingMode = false
        currentTrainingAlgorithm = nil
    }
    
    // Update algorithm stats after practice
    func updateAlgorithmStats(algorithmId: UUID, time: Double) {
        if let index = savedAlgorithms.firstIndex(where: { $0.id == algorithmId }) {
            savedAlgorithms[index].practiceCount += 1
            
            if let currentPB = savedAlgorithms[index].personalBest {
                if time < currentPB {
                    savedAlgorithms[index].personalBest = time
                }
            } else {
                savedAlgorithms[index].personalBest = time
            }
            
            saveToPersistence()
        }
    }
    
    // Get algorithms for current step
    var currentStepAlgorithms: [Algorithm] {
        currentStep?.keyAlgorithms ?? []
    }
    
    // Get all algorithms for selected method
    var methodAlgorithms: [Algorithm] {
        switch selectedMethod {
        case .beginners:
            return AlgorithmLibrary.beginnersAlgorithms
        case .cfop:
            return AlgorithmLibrary.f2lAlgorithms +
                   AlgorithmLibrary.ollAlgorithms +
                   AlgorithmLibrary.pllAlgorithms

        default:
            return []
        }
    }
    
    // Persistence helpers
    private func saveToPersistence() {
        // In a real app, save to UserDefaults or CoreData
        if let encoded = try? JSONEncoder().encode(savedAlgorithms) {
            UserDefaults.standard.set(encoded, forKey: "savedAlgorithms")
        }
    }
    
    private func loadSavedAlgorithms() {
        if let data = UserDefaults.standard.data(forKey: "savedAlgorithms"),
           let decoded = try? JSONDecoder().decode([Algorithm].self, from: data) {
            savedAlgorithms = decoded
        }
    }
}
