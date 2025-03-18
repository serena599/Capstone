import SwiftUI

///Meal details view
struct MealCompositionView: View {

    let mealType: MealType
    @EnvironmentObject private var viewModel: FoodViewModel
    @Environment(\.dismiss) var dismiss

    @State private var showDatePicker = false
    
    var filteredFoodItems: [FoodItem] {
        viewModel.foodItems.filter { food in
            let foodMealType = food.mealType
            return foodMealType == mealType &&
                Calendar.current.isDate(food.date, inSameDayAs: viewModel.selectedDate)
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
      
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                        .font(.system(size: 20))
                }
                
                Text(mealType.title)
                    .foregroundColor(.white)
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            .padding()
            .background(Color.foodPrimary)
            
            ScrollView {
                VStack(spacing: 20) {
               
                    HStack {
                        Button {
                            viewModel.goToPreviousDay()
                        } label: {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.gray)
                                .font(.system(size: 16))
                        }
                        
                        Spacer()
                        
                        Button {
                            showDatePicker = true
                        } label: {
                            Text(viewModel.dateString)
                                .font(.system(size: 17))
                                .foregroundColor(.black)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 24)
                                .background(
                                    Capsule()
                                        .fill(Color.white)
                                        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                                )
                        }
                        
                        Spacer()
                        
                        Button {
                            viewModel.goToNextDay()
                        } label: {
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                                .font(.system(size: 16))
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
         
                    ForEach(filteredFoodItems) { food in
                        FoodItemRow(food: food)
                    }
                    
                    NavigationLink {
                        AddFoodView(mealType: mealType)
                    } label: {
                        HStack {
                            Image(systemName: "plus")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Add Food")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color.blue, lineWidth: 1)
                        )
                    }
                    .padding(.horizontal)
                }
                .padding(.top)
            }
            .background(Color(.systemGroupedBackground))
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showDatePicker) {
            DatePickerView(selectedDate: $viewModel.selectedDate)
        }
        .onAppear {
            Task {
                print("MealCompositionView appeared for mealType: \(mealType.title)")
                
                // Always force a fresh data load when view appears
                await viewModel.loadFoods()
                
                print("Filtered food items for \(mealType.title): \(filteredFoodItems.count)")
                filteredFoodItems.forEach { item in
                    print("- \(item.name) (Meal: \(item.mealType?.title ?? "None"), Date: \(item.date))")
                }
            }
        }
    }
}


struct DatePickerView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedDate: Date
    @EnvironmentObject var viewModel: FoodViewModel
    
    var body: some View {
        NavigationView {
            DatePicker(
                "Select Date",
                selection: $selectedDate,
                displayedComponents: .date
            )
            .datePickerStyle(.graphical)
            .navigationBarItems(
                trailing: Button("Done") {
                    // Reload foods when date changes
                    Task {
                        await viewModel.loadFoods()
                    }
                    dismiss()
                }
            )
            .padding()
        }
    }
}

#Preview {
    NavigationView {
        MealCompositionView(mealType: .breakfast)
            .environmentObject(FoodViewModel())
    }
} 
