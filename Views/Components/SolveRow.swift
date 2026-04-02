//  SolveRow.swift
//  Views/Components


import SwiftUI

struct SolveRow: View {
    let solve: TimerSolve
    let number: Int
    
    var body: some View {
        HStack(spacing: 12) {
            Text("#\(number)")
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 40, alignment: .leading)
            
            Text(solve.displayTime)
                .font(.body)
                .fontWeight(.semibold)
                .monospacedDigit()
            
            Spacer()
            
            if solve.hasDNAData {
                Image(systemName: "waveform.path.ecg")
                    .font(.caption)
                    .foregroundStyle(.indigo)
            }
            
            if solve.dnf {
                Text("DNF")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(Color(uiColor: .systemBackground))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.primary)
                    .clipShape(Capsule())
            } else if solve.penalty == .plus2 {
                Text("+2")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.secondary.opacity(0.2))
                    .clipShape(Capsule())
            }
        }
        .padding(.vertical, 4)
    }
}
