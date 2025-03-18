import SwiftUI

extension Color {
    /// Create a color from a hexadecimal string
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    // MARK: - Customize the color
    static let foodPrimary = Color(hex: "#91C788")
    static let foodSecondary = Color(hex: "#ec6552")
    static let foodTertiary = Color(hex: "#e2b05b")
    static let foodQuaternary = Color(hex: "#3856b9")
    static let foodGray = Color(hex: "#797980")
    static let foodBackground = Color(hex: "#E7EDF1")
    static let loginGreen = Color(hex: "#91C788")
    static let searchResultBackground = Color(hex: "#FFEFE6")
    static let black = Color(hex: "#000000")
    
    // MARK: - Custom Colors
    static let customGreen = Color(red: 0.567, green: 0.778, blue: 0.531)
    static let customPink = Color(red: 1.0, green: 0.578, blue: 0.522)
    static let customPurple = Color(red: 0.686, green: 0.541, blue: 0.933)
    static let customOrange = Color(red: 1.0, green: 0.647, blue: 0.314)
    static let customBlue = Color(red: 0.2, green: 0.6, blue: 1.0)
}
