//  CubitApp.swift
//  A comprehensive Rubik's Cube learning and timing application


import SwiftUI

@main
struct CubitApp: App {
    @StateObject private var cubeViewModel = CubeViewModel()
    @StateObject private var timerViewModel = TimerViewModel()
    @StateObject private var tutorialViewModel = TutorialViewModel()
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                ContentView()
                    .environmentObject(cubeViewModel)
                    .environmentObject(timerViewModel)
                    .environmentObject(tutorialViewModel)
            } else {
                OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
            }
        }
    }
}
