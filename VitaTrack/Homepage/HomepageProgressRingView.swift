import SwiftUI

struct ProgressRingView: View {
    let progress: Double
    var size: CGFloat = 200
    var lineWidth: CGFloat = 15
    
    private let customGreen = Color(red: 0.567, green: 0.778, blue: 0.531)
    private let customPink = Color(red: 1.0, green: 0.578, blue: 0.522)
    private let customPurple = Color(red: 0.686, green: 0.541, blue: 0.933)
    private let customOrange = Color(red: 1.0, green: 0.647, blue: 0.314)
    private let customBlue = Color(red: 0.2, green: 0.6, blue: 1.0)
    
    var body: some View {
        ZStack {
            // Background Ring
            Circle()
                .trim(from: 0.1, to: 0.9)
                .stroke(Color.gray.opacity(0.2), lineWidth: lineWidth)
                .rotationEffect(.degrees(180))
            
            // Progress Ring with Gradient
            Circle()
                .trim(from: 0.1, to: min(0.9, 0.1 + (0.8 * progress)))
                .stroke(
                    LinearGradient(
                        colors: getGradientColors(for: progress),
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(180))
            
            // Leaf Icon and Progress Percentage
            VStack(spacing: 8) {
                Image(systemName: "leaf.fill")
                    .font(.system(size: size / 5))
                    .foregroundColor(customGreen)
                
                Text("\(Int(progress * 100))%")
                    .font(.system(size: size / 10, weight: .bold))
                    .foregroundColor(.black)
            }
        }
        .frame(width: size, height: size)
    }
    
    // Helper function to get gradient colors based on progress
    private func getGradientColors(for progress: Double) -> [Color] {
        let colors = [customOrange, customPink, customPurple, customBlue, customGreen]
        let step = 0.2
        let index = Int(progress / step)
        return Array(colors.prefix(max(1, index + 1)))
    }
}
