import SwiftUI

struct FoodResultsView: View {
    @EnvironmentObject private var foodViewModel: FoodViewModel
    let image: UIImage
    @State private var notes = ""
    @State private var categories: [FoodCategory] = [
        FoodCategory(name: "vegetables", quantity: 0),
        FoodCategory(name: "fruit", quantity: 0),
        FoodCategory(name: "grains", quantity: 0),
        FoodCategory(name: "meat", quantity: 0),
        FoodCategory(name: "dairy", quantity: 0),
        FoodCategory(name: "extras", quantity: 0)
    ]
    @State private var imageURL: String = ""
    @State private var mealType: String = "Breakfast"
    @Environment(\.dismiss) var dismiss
    
    private let mealTypes = ["Breakfast", "Lunch", "Dinner", "Snack"]
    private let serverBaseUrl = "http://localhost:4000" // Server base URL
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 200)
                    .cornerRadius(10)
                
                Picker("Meal Type", selection: $mealType) {
                    ForEach(mealTypes, id: \.self) { type in
                        Text(type)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.black)
                            .padding(10)
                            .frame(maxWidth: .infinity)
                            .background(Color.foodTertiary)
                            .cornerRadius(8)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 8) {
                    ForEach($categories) { $item in
                        HStack {
                            Text(item.name.capitalized)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.black)
                                .frame(width: 100, alignment: .leading)
                            
                            Spacer()
                            
                            TextField("Quantity", value: $item.quantity, formatter: NumberFormatter())
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 100)
                                .multilineTextAlignment(.trailing)
                                .keyboardType(.numberPad)
                        }
                        .padding(10)
                        .background(Color.foodGray.opacity(0.2))
                        .cornerRadius(8)
                    }

                }
                .padding()
                
                Button(action: {
                    saveRecord()
                    dismiss() // Save and return
                }) {
                    Text("Add Record")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.foodPrimary)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .padding(.top, -8)
            }
        }
        .navigationTitle("Food Record")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.white)
        .onAppear {
            uploadImage()
        }
    }
    
    private func uploadImage() {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }
        
        // Get current user ID
        guard let userId = UserManager.shared.currentUser?.user_id else {
            print("Error: No logged in user, cannot upload image")
            return
        }
        
        let url = URL(string: "\(serverBaseUrl)/api/uploadFoodImage")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"foodImage\"; filename=\"food.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        
        // Add user_id to form data
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"user_id\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(userId)".data(using: .utf8)!)
        body.append("\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error uploading image: \(error)")
                return
            }
            
            if let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                if let relativePath = json["imageUrl"] as? String {
                    // Convert relative path to full URL
                    let fullImageURL = "\(serverBaseUrl)\(relativePath)"
                    print("Image uploaded successfully, full URL: \(fullImageURL)")
                    
                    DispatchQueue.main.async {
                        self.imageURL = fullImageURL
                    }
                }
            }
        }.resume()
    }
    
    private func saveRecord() {
        // Get current user ID from UserManager
        guard let userId = UserManager.shared.currentUser?.user_id else {
            print("Error: No logged in user, cannot save food record")
            return
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let recordDate = dateFormatter.string(from: Date())
        
        // Calculate total calories (simple calculation method, 100 calories per unit for each category)
        let totalQuantity = categories.reduce(0) { $0 + $1.quantity }
        let estimatedCalories = totalQuantity * 100
        
        // Create server record
        let record: [String: Any] = [
            "user_id": userId,
            "recordDate": recordDate,
            "imageUrl": imageURL,
            "mealType": mealType.lowercased(),
            "vegetables": categories.first(where: { $0.name == "vegetables" })?.quantity ?? 0,
            "fruit": categories.first(where: { $0.name == "fruit" })?.quantity ?? 0,
            "grains": categories.first(where: { $0.name == "grains" })?.quantity ?? 0,
            "meat": categories.first(where: { $0.name == "meat" })?.quantity ?? 0,
            "dairy": categories.first(where: { $0.name == "dairy" })?.quantity ?? 0,
            "extras": categories.first(where: { $0.name == "extras" })?.quantity ?? 0
        ]
        
        // Immediately create local food record, do not wait for server response
        let mealTypeEnum = self.getMealTypeEnum(from: self.mealType)
        let categoryNames = self.categories.filter { $0.quantity > 0 }
            .map { "\($0.name.capitalized): \($0.quantity)" }
            .joined(separator: ", ")
        
        let foodName = categoryNames.isEmpty ? 
            "Camera Food" : 
            "Camera Food (\(categoryNames))"
        
        let totalCalories = self.categories.reduce(0) { $0 + $1.quantity * 100 }
        
        let newFood = FoodItem(
            name: foodName,
            calories: totalCalories,
            unit: "photo",
            amount: 1.0,
            mealType: mealTypeEnum,
            date: Date(),
            imageUrl: imageURL
        )
        
        // Directly add food record to ViewModel
        Task {
            print("Adding camera food to ViewModel: \(newFood.name), imageURL: \(newFood.imageUrl ?? "none")")
            await foodViewModel.addFood(newFood)
            
            // Set current date to the date of the new record, so it can be seen when returning
            await MainActor.run {
                foodViewModel.selectedDate = newFood.date
            }
        }
        
        // Save to server
        let url = URL(string: "\(serverBaseUrl)/api/food-records")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: record, options: [])
            request.httpBody = jsonData
        } catch {
            print("Error serializing food record data: \(error)")
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error saving record: \(error)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response")
                return
            }
            
            if httpResponse.statusCode == 200 {
                print("Record saved successfully to server")
                
                // Parse response to get server ID
                if let data = data, let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let recordId = json["recordId"] as? Int {
                    
                    // Update local record's serverId
                    DispatchQueue.main.async {
                        // Here we only need to update the serverId, because the food record has already been added to the model
                        Task {
                            // Find and update the serverId of the most recently added food record
                            if let index = self.foodViewModel.foodItems.firstIndex(where: { $0.name == foodName }) {
                                await MainActor.run {
                                    self.foodViewModel.foodItems[index].serverId = recordId
                                    print("Updated serverId for food record: \(foodName), serverId: \(recordId)")
                                }
                            }
                        }
                    }
                }
            } else {
                print("Error saving record: HTTP status \(httpResponse.statusCode)")
            }
        }.resume()
    }
    
    // Convert string to MealType enum
    private func getMealTypeEnum(from string: String) -> MealType {
        switch string.lowercased() {
        case "breakfast": return .breakfast
        case "lunch": return .lunch
        case "dinner": return .dinner
        case "snack": return .snacks
        default: return .breakfast
        }
    }
}

#Preview("Food Results") {
    NavigationStack {
        FoodResultsView(image: UIImage(systemName: "photo") ?? UIImage())
            .environmentObject(FoodViewModel())
    }
}

