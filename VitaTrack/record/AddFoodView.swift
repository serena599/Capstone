import SwiftUI

struct AddFoodView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var viewModel: FoodViewModel
    
    let mealType: MealType
    let editingFood: FoodItem?
    
    @State private var name: String = ""
    @State private var amount: Double = 1.0
    @State private var unit: String = "g"
    @State private var calories: Int = 0
    
    init(mealType: MealType, editingFood: FoodItem? = nil) {
        self.mealType = mealType
        self.editingFood = editingFood
        
        if let food = editingFood {
            _name = State(initialValue: food.name)
            _calories = State(initialValue: food.calories)
            _unit = State(initialValue: food.unit)
            _amount = State(initialValue: food.amount ?? 1.0)
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {

            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(.white)
                        .font(.system(size: 20))
                }
                
                Spacer()
                
                Text(editingFood == nil ? "Add Food" : "Edit Food")
                    .foregroundColor(.white)
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button {
                    saveFood()
                } label: {
                    Text("Save")
                        .foregroundColor(.white)
                        .font(.system(size: 17))
                }
            }
            .padding()
            .background(Color.foodPrimary)
            
            ScrollView {
                VStack(spacing: 20) {
               
                    VStack(alignment: .leading) {
                        Text("Food Name")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        TextField("Enter food name", text: $name)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    .padding(.horizontal)
                    
                  
                    VStack(alignment: .leading) {
                        Text("Amount")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        HStack {
                            TextField("Enter amount", value: $amount, format: .number)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.decimalPad)
                            
                            Picker("Unit", selection: $unit) {
                                Text("g").tag("g")
                                Text("serving").tag("serving")
                            }
                            .pickerStyle(.segmented)
                            .frame(width: 120)
                        }
                    }
                    .padding(.horizontal)
                    
           
                    VStack(alignment: .leading) {
                        Text("Calories")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        HStack {
                            TextField("Enter calories", value: $calories, format: .number)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.numberPad)
                            Text("kcal")
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.top)
            }
            .background(Color(.systemGroupedBackground))
        }
        .navigationBarHidden(true)
    }
    
    private func saveFood() {
      
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              calories > 0 else {
            return
        }
        
        
        if let existingFood = editingFood {
            print("Editing existing food with serverId:", existingFood.serverId ?? "nil")
            
            
            guard let serverId = existingFood.serverId else {
                print("Error: Cannot update food without serverId")
                return
            }
            
            let updatedFood = FoodItem(
                id: existingFood.id,
                serverId: serverId,
                name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                calories: calories,
                unit: unit.trimmingCharacters(in: .whitespacesAndNewlines),
                amount: amount,
                mealType: existingFood.mealType,
                date: existingFood.date
            )
            
            Task {
                await viewModel.updateFood(updatedFood)
            }
        } else {
     
            let newFood = FoodItem(
                name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                calories: calories,
                unit: unit.trimmingCharacters(in: .whitespacesAndNewlines),
                amount: amount,
                mealType: mealType,
                date: viewModel.selectedDate
            )
            
            Task {
                await viewModel.addFood(newFood)
            }
        }
        
        dismiss()
    }
}

struct AddFoodView_Previews: PreviewProvider {
    static var previews: some View {
        AddFoodView(mealType: .breakfast)
            .environmentObject(FoodViewModel())
    }
} 