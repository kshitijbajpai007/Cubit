# CubIt: The Intelligent Speedcubing Coach

**CubIt** is a minimalist, professional-grade iOS application designed to bridge the gap between learning to solve a Rubik's Cube and mastering it. 

While traditional timers only track how long a solve takes, CubIt answers *why*. By leveraging Apple's native `FoundationModels` framework, CubIt acts as an on-device AI coach, analyzing solve DNA to provide personalized, privacy-first coaching and technique focus. 



## ⚠️ Important Reviewer Note: Simulator Only

**This application is configured to run exclusively on the Xcode Simulator.** It will not build or deploy to a physical iOS device. Please evaluate the project using an iOS 26 Simulator. 



## ✨ Key Features

* **On-Device AI Coaching:** Utilizes iOS 26 Apple Intelligence to analyze solve trends (e.g., F2L vs. Last Layer micro-splits). It generates dynamic, actionable feedback locally, without a single byte of user data ever leaving the device.
* **Gestural Timer Interface:** A massive, 340x340 point edge-to-edge timer driven entirely by intuitive touch gestures and `UIImpactFeedbackGenerator` haptics. It uses stark contrast (thickness and opacity) rather than color to communicate state, allowing users to keep their eyes purely on the puzzle.
* **Achromatic UI Design:** A strict grayscale and Indigo design system. By intentionally reserving the colors red, green, blue, yellow, and orange exclusively for the 3D cube rendering, the user's cognitive focus remains unbroken.
* **Advanced Analytics:** Interactive, professional-grade heatmaps and performance timelines built natively with Swift `Charts`.



## 🛠️ Technologies & Frameworks

* **SwiftUI:** For a fluid, declarative user interface and interactive 3D elements.
* **FoundationModels:** Powering the `LanguageModelSession` for local, secure AI coaching.
* **Charts:** For rendering complex statistical solve data.
* **Swift 6:** Utilizing modern Swift concurrency for seamless UI updates during complex data processing.



## 📱 System Requirements

* **Target OS:** iOS 26.0 Simulator.
* **Hardware Environment:** A Mac running Xcode 18+. 
* **AI Coach Requirement:** To fully experience the FoundationModels generative AI coaching, please ensure your Mac is Apple Silicon-based, as local Apple Intelligence features are optimized for this architecture within the Simulator.



## 🚀 How to Run

1. Open the `.swiftpm` file or Xcode Project in Xcode 18+.
2. At the top of the Xcode window, click the device destination dropdown.
3. **Crucial Step:** Select an **iOS 26 Simulator** (e.g., iPhone 16 Pro). Do *not* select "Any iOS Device" or a connected physical iPhone.
4. Build and Run (`Cmd + R`). 
5. On the initial onboarding screen, swipe the 3D cube to interact, then select your path to explore the gestural timer or the interactive learning guides.
