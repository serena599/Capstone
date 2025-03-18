import SwiftUI

struct EditFoodView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var viewModel: FoodViewModel
    
    let mealType: MealType
    let editingFood: FoodItem?
    
    @State private var name: String = ""
    @State private var amount: Double = 1.0
    @State private var unit: String = "g"
    @State private var calories: Int = 0
    @State private var imageUrl: String = ""
    @State private var isCamera: Bool = false
    @State private var imageLoadError: String? = nil
    
    // Food categories
    @State private var vegetables: Int = 0
    @State private var fruit: Int = 0
    @State private var grains: Int = 0
    @State private var meat: Int = 0
    @State private var dairy: Int = 0
    @State private var extras: Int = 0
    
    // Selected meal type
    @State private var selectedMealType: String = "Breakfast"
    private let mealTypes = ["Breakfast", "Lunch", "Dinner", "Snack"]
    
    init(mealType: MealType, editingFood: FoodItem? = nil) {
        self.mealType = mealType
        self.editingFood = editingFood
        
        if let food = editingFood {
            _name = State(initialValue: food.name)
            _calories = State(initialValue: food.calories)
            _unit = State(initialValue: food.unit)
            _amount = State(initialValue: food.amount ?? 1.0)
            _imageUrl = State(initialValue: food.imageUrl ?? "")
            _isCamera = State(initialValue: food.name.hasPrefix("Camera Food"))
            
            // Initialize meal type
            _selectedMealType = State(initialValue: food.mealType?.rawValue.capitalized ?? "Breakfast")
            
            // Parse food name to extract categories if it's a camera food
            if food.name.hasPrefix("Camera Food") {
                let nameComponents = food.name.replacingOccurrences(of: "Camera Food (", with: "")
                    .replacingOccurrences(of: ")", with: "")
                    .components(separatedBy: ", ")
                
                for component in nameComponents {
                    let parts = component.components(separatedBy: ": ")
                    if parts.count == 2, let value = Int(parts[1]) {
                        switch parts[0].lowercased() {
                        case "vegetables": _vegetables = State(initialValue: value)
                        case "fruit": _fruit = State(initialValue: value)
                        case "grains": _grains = State(initialValue: value)
                        case "meat": _meat = State(initialValue: value)
                        case "dairy": _dairy = State(initialValue: value)
                        case "extras": _extras = State(initialValue: value)
                        default: break
                        }
                    }
                }
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Navigation bar with back button
            HStack {
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 17))
                        Text("Back")
                            .font(.system(size: 17))
                    }
                    .foregroundColor(.blue)
                }
                
                Spacer()
                
                Text("Food Record")
                    .font(.headline)
                
                Spacer()
                
                // Empty spacer for alignment
                HStack(spacing: 5) {
                    Image(systemName: "chevron.left")
                        .opacity(0)
                    Text("Back")
                        .opacity(0)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
            
            ScrollView {
                VStack(spacing: 20) {
                    // Food image
                    if !imageUrl.isEmpty {
                        AsyncImage(url: URL(string: imageUrl)) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(height: 200)
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 180)
                                    .cornerRadius(5)
                            case .failure:
                                Image(systemName: "photo")
                                    .font(.system(size: 80))
                                    .foregroundColor(.gray)
                                    .frame(height: 180)
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Meal type selector
                    Picker("", selection: $selectedMealType) {
                        ForEach(mealTypes, id: \.self) { type in
                            Text(type).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    // Food categories
                    VStack(spacing: 12) {
                        CategoryRow(title: "Vegetables", value: $vegetables)
                        CategoryRow(title: "Fruit", value: $fruit)
                        CategoryRow(title: "Grains", value: $grains)
                        CategoryRow(title: "Meat", value: $meat)
                        CategoryRow(title: "Dairy", value: $dairy)
                        CategoryRow(title: "Extras", value: $extras)
                    }
                    .padding(.horizontal)
                    
                    // Add Record button
                    Button(action: saveFood) {
                        Text(editingFood == nil ? "Add Record" : "Save Record")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.foodPrimary)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    .padding(.bottom, 30)
                }
                .padding(.top, 10)
            }
        }
        .navigationBarHidden(true)
        .background(Color(.systemGroupedBackground).edgesIgnoringSafeArea(.all))
        .onAppear {
            if !imageUrl.isEmpty {
                print("Image URL in EditFoodView: \(imageUrl)")
            }
        }
    }
    
    private func saveFood() {
        // Calculate total calories based on food categories
        let totalCalories = vegetables * 100 + fruit * 100 + grains * 100 + 
                           meat * 100 + dairy * 100 + extras * 100
        
        // Generate food name with categories
        let categoryParts = [
            vegetables > 0 ? "Vegetables: \(vegetables)" : nil,
            fruit > 0 ? "Fruit: \(fruit)" : nil,
            grains > 0 ? "Grains: \(grains)" : nil,
            meat > 0 ? "Meat: \(meat)" : nil,
            dairy > 0 ? "Dairy: \(dairy)" : nil,
            extras > 0 ? "Extras: \(extras)" : nil
        ].compactMap { $0 }
        
        let foodName = categoryParts.isEmpty ? 
            "Camera Food" : 
            "Camera Food (\(categoryParts.joined(separator: ", ")))"
        
        // Get MealType enum from string
        let selectedMealTypeEnum: MealType = {
            switch selectedMealType.lowercased() {
            case "breakfast": return .breakfast
            case "lunch": return .lunch
            case "dinner": return .dinner
            case "snack": return .snacks
            default: return mealType
            }
        }()
        
        if let existingFood = editingFood {
            print("Editing existing food with serverId:", existingFood.serverId ?? "nil")
            
            guard let serverId = existingFood.serverId else {
                print("Error: Cannot update food without serverId")
                return
            }
            
            let updatedFood = FoodItem(
                id: existingFood.id,
                serverId: serverId,
                name: foodName,
                calories: totalCalories,
                unit: "photo",
                amount: 1.0,
                mealType: selectedMealTypeEnum,
                date: existingFood.date,
                imageUrl: imageUrl.isEmpty ? nil : imageUrl
            )
            
            Task {
                await viewModel.updateFood(updatedFood)
            }
        } else {
            let newFood = FoodItem(
                name: foodName,
                calories: totalCalories,
                unit: "photo",
                amount: 1.0,
                mealType: selectedMealTypeEnum,
                date: viewModel.selectedDate,
                imageUrl: imageUrl.isEmpty ? nil : imageUrl
            )
            
            Task {
                await viewModel.addFood(newFood)
            }
        }
        
        dismiss()
    }
}

// Helper view for food category row
struct CategoryRow: View {
    let title: String
    @Binding var value: Int
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(.black)
            
            Spacer()
            
            TextField("0", value: $value, format: .number)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.trailing)
                .padding(8)
                .frame(width: 70)
                .background(Color.white)
                .cornerRadius(5)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 15)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

struct EditFoodView_Previews: PreviewProvider {
    static var previews: some View {
        EditFoodView(mealType: .breakfast)
            .environmentObject(FoodViewModel())
    }
} 
