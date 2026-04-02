//  ContentView.swift
//  Views


import SwiftUI

struct ContentView: View {
    @EnvironmentObject var cubeViewModel: CubeViewModel
    @EnvironmentObject var timerViewModel: TimerViewModel
    @EnvironmentObject var tutorialViewModel: TutorialViewModel

    @AppStorage("initialTab") private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            // Timer (Tab 0)
            TimerView()
                .tabItem {
                    Label("Timer", systemImage: "timer")
                }
                .tag(0)

            // Learn (Tab 1)
            MethodSelectionView()
                .tabItem {
                    Label("Learn", systemImage: "book.fill")
                }
                .tag(1)

            // Train (Tab 2)
            AlgorithmTrainerView()
                .tabItem {
                    Label("Train", systemImage: "figure.run")
                }
                .tag(2)

            // Stats with AI Coach (Tab 3)
            StatisticsView()
                .tabItem {
                    Label("Stats", systemImage: "chart.bar.fill")
                }
                .tag(3)
        }
        .accentColor(.indigo)
    }
}

#Preview {
    ContentView()
        .environmentObject(CubeViewModel())
        .environmentObject(TimerViewModel())
        .environmentObject(TutorialViewModel())
}
