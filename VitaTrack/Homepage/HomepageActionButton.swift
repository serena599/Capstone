// HomepageActionButton.swift
import SwiftUI

struct HomepageActionButton: View {
    let title: String
    let subtitle: String
    let buttonText: String
    let backgroundColor: Color
    let destination: AnyView
    
    var body: some View {
        NavigationLink(destination: destination) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.white)
                    Text(subtitle)
                        .font(.headline)
                        .foregroundColor(.white)
                }
                .padding(.leading, 20)
                
                Spacer()
                
                HStack {
                    Text(buttonText)
                        .font(.subheadline)
                        .foregroundColor(backgroundColor)
                        .lineLimit(1)
                        .fixedSize()
                    Image(systemName: "chevron.right")
                        .foregroundColor(backgroundColor)
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 12)
                .background(Color.white)
                .cornerRadius(15)
                .padding(.trailing, 20)
            }
            .frame(height: 70)
            .background(backgroundColor)
            .cornerRadius(20)
            .padding(.horizontal, 25)
        }
    }
}