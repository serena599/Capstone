import Foundation

struct FoodCategory: Identifiable, Codable {
    var id = UUID()
    var name: String
    var quantity: Int
    var isEditing: Bool = false
}
