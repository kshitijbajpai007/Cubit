//  HapticManager.swift
//  Utilities

import UIKit

struct HapticManager {

    // Fired when the circle turns green (ready state)
    static func timerReady() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }

    // Fired the moment the timer starts counting
    static func timerStart() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred(intensity: 0.8)
    }

    // Fired when the timer stops and the solve is saved
    static func timerStop() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    // Fired when a split is recorded
    static func splitRecorded() {
        let generator = UIImpactFeedbackGenerator(style: .rigid)
        generator.impactOccurred(intensity: 0.6)
    }

    // Standard selection feedback
    static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }

    // Standard success feedback
    static func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    // Generic impact feedback
    static func impact(style: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }

    // Fired when navigating between tutorial steps
    static func stepChanged() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
}
