//  MethodCard.swift
//  Views/Components

import SwiftUI

struct MethodCard: View {
    let method: SolvingMethod
    let isSelected: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // Icon
                Image(systemName: method.icon)
                    .font(.title)
                    .foregroundColor(isSelected ? .indigo : .primary)
                    .frame(width: 50, height: 50)
                    .background(isSelected ? Color.indigo.opacity(0.1) : Color.secondary.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(method.rawValue)
                        .font(.headline)
                        .foregroundColor(isSelected ? .indigo : .primary)
                    
                    Text(method.difficulty)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.indigo)
                }
            }
            
            Divider()
            
            // Description
            Text(method.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(3)
            
            // Stats
            HStack(spacing: 20) {
                StatBadge(icon: "brain", text: method.estimatedAlgorithms)
                StatBadge(icon: "move.3d", text: method.averageMoves)
            }
        }
        .padding()
        .background(isSelected ? Color.indigo.opacity(0.05) : Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isSelected ? Color.indigo : Color.clear, lineWidth: 2)
        )
    }
}

struct StatBadge: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(text)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(8)
    }
}

#Preview {
    VStack {
        MethodCard(method: .beginners, isSelected: true)
            .padding()
        
        MethodCard(method: .cfop, isSelected: false)
            .padding()
    }
}
