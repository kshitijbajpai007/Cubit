//  OnboardingView.swift
//  Views/Onboarding


import SwiftUI

enum OnboardingStep {
    case hook
    case pathSelection
    case valueProp // Only for Pro
    case timerTutorial
}

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @AppStorage("initialTab") private var initialTab = 0
    
    @State private var currentStep: OnboardingStep = .hook
    
    var body: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground)
                .ignoresSafeArea()
            
            VStack {
                HStack {
                    Spacer()
                    Button("Skip") {
                        completeOnboarding(tab: 0)
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding()
                }
                
                Spacer()
                
                switch currentStep {
                case .hook:
                    hookView
                        .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .move(edge: .leading).combined(with: .opacity)))
                case .pathSelection:
                    pathSelectionView
                        .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .move(edge: .leading).combined(with: .opacity)))
                case .valueProp:
                    valuePropView
                        .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .move(edge: .leading).combined(with: .opacity)))
                case .timerTutorial:
                    timerTutorialView
                        .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .move(edge: .leading).combined(with: .opacity)))
                }
                
                Spacer()
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: currentStep)
    }
    
    // MARK: - Step 1: Hook
    
    private var hookView: some View {
        VStack(spacing: 40) {
            // Interactive Cube
            ZStack {
                Circle()
                    .fill(Color(uiColor: .secondarySystemGroupedBackground))
                    .frame(width: 280, height: 280)
                
                Cube3DView(cubeState: CubeState())
                    .frame(height: 240)
                    .scaleEffect(0.9)
                    // Simplified swipe interaction for onboarding
                    .gesture(
                        DragGesture()
                            .onChanged { _ in
                                HapticManager.impact(style: .light)
                            }
                    )
            }
            
            VStack(spacing: 12) {
                Text("Welcome to Cubit.")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.primary)
                
                Text("Swipe the cube to explore.")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
            
            Button {
                HapticManager.selection()
                currentStep = .pathSelection
            } label: {
                Text("Get Started")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(Color.indigo)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .padding(.horizontal, 32)
            .padding(.top, 20)
        }
    }
    
    // MARK: - Step 2: Path Selection
    
    private var pathSelectionView: some View {
        VStack(spacing: 32) {
            VStack(spacing: 8) {
                Text("Choose Your Path")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.primary)
                
                Text("We'll set up Cubit for your experience level.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            VStack(spacing: 20) {
                // Beginner Card
                Button {
                    HapticManager.selection()
                    // Lean -> Tab 1, finish onboarding immediately
                    completeOnboarding(tab: 1)
                } label: {
                    pathCard(
                        icon: "book.fill",
                        title: "I want to learn.",
                        subtitle: "Step-by-step 3D guides to your first solve."
                    )
                }
                .buttonStyle(.plain)
                
                // Pro Card
                Button {
                    HapticManager.selection()
                    // Faster -> Tab 0, continue to AI coach explanation
                    currentStep = .valueProp
                } label: {
                    pathCard(
                        icon: "timer",
                        title: "I want to get faster.",
                        subtitle: "Advanced timer and AI DNA analysis."
                    )
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 24)
        }
    }
    
    private func pathCard(icon: String, title: String, subtitle: String) -> some View {
        HStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundStyle(.indigo)
                .frame(width: 50)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
            }
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.body.weight(.semibold))
                .foregroundStyle(Color(uiColor: .tertiaryLabel))
        }
        .padding(24)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
    
    // MARK: - Step 3: Value Prop
    
    private var valuePropView: some View {
        VStack(spacing: 40) {
            // Infographic
            ZStack {
                // Background connections
                VStack(spacing: 0) {
                    HStack(spacing: 60) {
                        roundedBox("F2L")
                        roundedBox("LL")
                    }
                    .padding(.bottom, 20)
                    
                    // Connecting lines
                    Path { path in
                        path.move(to: CGPoint(x: 100, y: 0))
                        path.addLine(to: CGPoint(x: 150, y: 40))
                        path.move(to: CGPoint(x: 200, y: 0))
                        path.addLine(to: CGPoint(x: 150, y: 40))
                    }
                    .stroke(Color(uiColor: .tertiaryLabel), style: StrokeStyle(lineWidth: 2, dash: [5]))
                    .frame(width: 300, height: 40)
                    
                    // AI Brain
                    ZStack {
                        Circle()
                            .fill(Color.indigo.opacity(0.1))
                            .frame(width: 100, height: 100)
                        
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 50))
                            .foregroundStyle(.indigo)
                            .shadow(color: .indigo.opacity(0.5), radius: 10, x: 0, y: 0)
                    }
                    .padding(.top, -10)
                }
            }
            .frame(height: 240)
            
            VStack(spacing: 16) {
                Text("Meet your AI Coach.")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.primary)
                
                Text("Cubit analyzes your F2L and Last Layer splits to find your weaknesses and generate custom, on-device coaching.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            Button {
                HapticManager.selection()
                currentStep = .timerTutorial
            } label: {
                Text("Continue")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(Color.indigo)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .padding(.horizontal, 32)
            .padding(.top, 20)
        }
    }
    
    private func roundedBox(_ text: String) -> some View {
        Text(text)
            .font(.headline)
            .fontWeight(.bold)
            .foregroundColor(.primary)
            .frame(width: 70, height: 50)
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
    
    // MARK: - Step 4: Timer Tutorial
    
    @State private var mockTimerState: MockTimerState = .idle
    @State private var mockTime: Double = 0
    @State private var timer: Timer?
    @State private var isHoldingDown = false
    @State private var holdTimer: Timer?
    @State private var hasCompletedMockTimer = false
    
    enum MockTimerState {
        case idle, ready, running, stopped
    }
    
    private var timerTutorialView: some View {
        VStack(spacing: 40) {
            VStack(spacing: 8) {
                Text("The Timer")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.primary)
                
                Text(timerTutorialInstructions)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .animation(.easeInOut, value: mockTimerState)
            }
            
            // Mock Timer Circle
            ZStack {
                if mockTimerState != .running {
                    Circle()
                        .stroke(mockRingColor, lineWidth: mockRingWidth)
                        .frame(width: 320, height: 320)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: mockTimerState)
                }
                
                Circle()
                    .fill(mockRingColor.opacity(0.05))
                    .frame(width: 320, height: 320)
                
                VStack(spacing: 8) {
                    Text(formatMockTime(mockTime))
                        .font(.system(size: 80, weight: .light, design: .rounded))
                        .foregroundColor(mockRingColor)
                        .monospacedDigit()
                    
                    Text(mockHintText)
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
            }
            .contentShape(Circle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        guard !isHoldingDown else { return }
                        isHoldingDown = true
                        handleMockDown()
                    }
                    .onEnded { _ in
                        handleMockUp()
                    }
            )
            .padding(.vertical, 20)
            
            Button {
                HapticManager.success()
                completeOnboarding(tab: 0)
            } label: {
                Text("Enter Cubit")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(hasCompletedMockTimer ? Color.indigo : Color.secondary)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .disabled(!hasCompletedMockTimer)
            .padding(.horizontal, 32)
        }
        .onDisappear {
            timer?.invalidate()
            holdTimer?.invalidate()
        }
    }
    
    private var timerTutorialInstructions: String {
        switch mockTimerState {
        case .idle: return "Place and hold your finger on the circle."
        case .ready: return "Release your finger to start the timer."
        case .running: return "Tap anywhere on the circle to stop."
        case .stopped: return "Great job! You're ready to go."
        }
    }
    
    private var mockRingColor: Color {
        switch mockTimerState {
        case .idle: return .primary.opacity(0.1)
        case .ready: return .primary
        case .running: return .secondary.opacity(0.3)
        case .stopped: return .primary
        }
    }
    
    private var mockRingWidth: CGFloat {
        switch mockTimerState {
        case .idle: return 4
        case .ready: return 8
        case .running: return 2
        case .stopped: return 4
        }
    }
    
    private var mockHintText: String {
        switch mockTimerState {
        case .idle: return "Hold to ready"
        case .ready: return "Release to start"
        case .running: return "Tap to stop"
        case .stopped: return "Ready!"
        }
    }
    
    private func handleMockDown() {
        switch mockTimerState {
        case .running:
            stopMockTimer()
            isHoldingDown = false
        case .stopped:
            // Do nothing, force user to click Enter Cubit
            isHoldingDown = false
        case .idle:
            holdTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
                if isHoldingDown {
                    mockTimerState = .ready
                    HapticManager.impact(style: .medium)
                }
            }
        case .ready:
            break
        }
    }
    
    private func handleMockUp() {
        holdTimer?.invalidate()
        holdTimer = nil
        if mockTimerState == .ready {
            startMockTimer()
        }
        isHoldingDown = false
    }
    
    private func startMockTimer() {
        mockTimerState = .running
        mockTime = 0
        HapticManager.impact(style: .light)
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
            mockTime += 0.01
        }
    }
    
    private func stopMockTimer() {
        timer?.invalidate()
        timer = nil
        mockTimerState = .stopped
        hasCompletedMockTimer = true
        HapticManager.success()
    }
    
    private func formatMockTime(_ time: Double) -> String {
        let sec = Int(time) % 60
        let ms = Int((time.truncatingRemainder(dividingBy: 1)) * 100)
        return String(format: "%d.%02d", sec, ms)
    }
    
    // MARK: - Completion
    
    private func completeOnboarding(tab: Int) {
        initialTab = tab
        withAnimation(.spring()) {
            hasCompletedOnboarding = true
        }
    }
}
