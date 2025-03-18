import SwiftUI


enum MealType: String, CaseIterable, Identifiable, Codable {
    case breakfast = "breakfast"
    case lunch = "lunch"
    case dinner = "dinner"
    case snacks = "snack"
    
    var id: Self { self }
 
    var title: String {
        switch self {
        case .breakfast: return "Breakfast"
        case .lunch: return "Lunch"
        case .dinner: return "Dinner"
        case .snacks: return "Snack"
        }
    }

    var color: Color {
        switch self {
        case .breakfast: return .foodPrimary
        case .lunch: return .foodSecondary
        case .dinner: return .foodTertiary
        case .snacks: return .foodQuaternary
        }
    }
    

    var icon: String {
        switch self {
        case .breakfast: return "sun.max.fill"
        case .lunch: return "clock.fill"
        case .dinner: return "moon.fill"
        case .snacks: return "star.fill"
        }
    }
} 
