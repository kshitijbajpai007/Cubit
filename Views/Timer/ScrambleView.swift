//  ScrambleView.swift
//  Views/Timer


import SwiftUI

struct ScrambleView: View {
    let scramble: String

    var body: some View {
        VStack(alignment: .center, spacing: 6) {
            Text("Scramble")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(scramble)
                .font(.system(.subheadline, design: .monospaced))
                .multilineTextAlignment(.center)
                .lineLimit(nil)          // ← no cap on lines
                .fixedSize(horizontal: false, vertical: true)  // ← grow vertically, never clip
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.secondary.opacity(0.10))
                .cornerRadius(10)
        }
    }
}

#Preview {
    ScrambleView(scramble: "R U R' U' R' F R2 U' R' U' R U R' F' U R U' R'")
        .padding()
}
