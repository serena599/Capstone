import SwiftUI

struct FoodItemRow: View {
    let food: FoodItem
    @EnvironmentObject private var viewModel: FoodViewModel
    @State private var showEditView = false
    @State private var isDeleting = false
    @State private var showFoodDetail = false
    
    var body: some View {
        VStack {
            // 主要内容
            HStack {
                // 如果有图片，显示图片
                if let imageUrl = food.imageUrl, !imageUrl.isEmpty {
                    AsyncImage(url: URL(string: imageUrl)) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 60, height: 60)
                                .cornerRadius(8)
                        } else if phase.error != nil {
                            Image(systemName: "photo")
                                .font(.system(size: 30))
                                .frame(width: 60, height: 60)
                                .foregroundColor(.gray)
                        } else {
                            ProgressView()
                                .frame(width: 60, height: 60)
                        }
                    }
                    .padding(.trailing, 8)
                }
                
                VStack(alignment: .leading) {
                    Text(food.name)
                        .font(.headline)
                        .lineLimit(2)
                    HStack {
                        if let amount = food.amount {
                            Text("\(amount, specifier: "%.1f")\(food.unit)")
                            Text("·")
                        }
                        Text("\(food.calories) kcal")
                    }
                    .font(.subheadline)
                    .foregroundColor(.foodGray)
                }
                
                Spacer()
                
                // 操作按钮
                HStack(spacing: 12) {
                    Button {
                        showEditView = true
                    } label: {
                        Image(systemName: "pencil")
                            .foregroundColor(.blue)
                            .padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.blue, lineWidth: 1)
                            )
                    }
                    
                    Button {
                        deleteFood()
                    } label: {
                        Image(systemName: "trash")
                            .foregroundColor(.foodSecondary)
                            .padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.foodSecondary, lineWidth: 1)
                            )
                    }
                    .disabled(isDeleting)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
        .onTapGesture {
            if food.imageUrl != nil && !food.imageUrl!.isEmpty {
                showFoodDetail = true
            }
        }
        .sheet(isPresented: $showEditView) {
            Group {
                if food.name.hasPrefix("Camera Food") {
                    // 照片记录的食物使用EditFoodView
                    EditFoodView(mealType: food.mealType ?? .breakfast, editingFood: food)
                } else {
                    // 手动添加的食物使用AddFoodView
                    AddFoodView(mealType: food.mealType ?? .breakfast, editingFood: food)
                }
            }
        }
        .sheet(isPresented: $showFoodDetail) {
            FoodDetailView(food: food)
        }
    }
    
    private func deleteFood() {
        guard let id = food.serverId else { return }
        
        isDeleting = true
        
        Task {
            do {
                print("Deleting food with ID:", id)
                try await NetworkService.shared.deleteMealRecord(id: String(id))
                print("Food deleted successfully")
                
                await MainActor.run {
                    isDeleting = false
                    viewModel.foodItems.removeAll { $0.id == food.id }
                }
            } catch {
                print("Error deleting food:", error)
                await MainActor.run {
                    isDeleting = false
                }
            }
        }
    }
}

// 添加食物详情视图
struct FoodDetailView: View {
    let food: FoodItem
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // 显示食物图片（如果有）
                    if let imageUrl = food.imageUrl, !imageUrl.isEmpty {
                        AsyncImage(url: URL(string: imageUrl)) { phase in
                            if let image = phase.image {
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxHeight: 250)
                                    .cornerRadius(12)
                            } else if phase.error != nil {
                                Image(systemName: "photo")
                                    .font(.system(size: 80))
                                    .frame(height: 200)
                                    .foregroundColor(.gray)
                                    .frame(maxWidth: .infinity)
                            } else {
                                ProgressView()
                                    .frame(height: 200)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .padding(.bottom)
                    }
                    
                    // 食物信息卡片
                    VStack(alignment: .leading, spacing: 12) {
                        Text(food.name)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Divider()
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Calories")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                Text("\(food.calories) kcal")
                                    .font(.headline)
                            }
                            
                            Spacer()
                            
                            if let amount = food.amount {
                                VStack(alignment: .trailing) {
                                    Text("Amount")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    Text("\(amount, specifier: "%.1f") \(food.unit)")
                                        .font(.headline)
                                }
                            }
                        }
                        
                        Divider()
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Meal Type")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                Text(food.mealType?.title ?? "Unknown")
                                    .font(.headline)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing) {
                                Text("Date")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                Text(dateFormatter.string(from: food.date))
                                    .font(.headline)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                }
                .padding()
            }
            .navigationTitle("Food Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }
}

#Preview {
    FoodItemRow(
        food: FoodItem(
            name: "Apple",
            calories: 52,
            unit: "piece",
            amount: 1,
            mealType: .breakfast,
            date: Date(),
            imageUrl: "https://example.com/apple.jpg"
        )
    )
    .padding()
    .background(Color.foodBackground)
    .environmentObject(FoodViewModel())
}
