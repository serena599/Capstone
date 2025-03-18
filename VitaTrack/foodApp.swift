import SwiftUI

struct FoodItem: Identifiable, Codable {
    let id: UUID
    var serverId: Int?
    var name: String
    var calories: Int
    var unit: String
    var amount: Double?
    var mealType: MealType?
    var date: Date
    var imageUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "local_id"
        case serverId = "db_id"
        case name
        case calories
        case unit
        case amount
        case mealType
        case date
        case imageUrl = "image_url"
    }
    

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = UUID()
        serverId = try? container.decode(Int.self, forKey: .serverId)
        name = try container.decode(String.self, forKey: .name)
        calories = try container.decode(Int.self, forKey: .calories)
        unit = try container.decode(String.self, forKey: .unit)
        amount = try? container.decodeIfPresent(Double.self, forKey: .amount)
        mealType = try? container.decodeIfPresent(MealType.self, forKey: .mealType)
        date = try container.decode(Date.self, forKey: .date)
        imageUrl = try? container.decodeIfPresent(String.self, forKey: .imageUrl)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(serverId, forKey: .serverId)
        try container.encode(name, forKey: .name)
        try container.encode(calories, forKey: .calories)
        try container.encode(unit, forKey: .unit)
        try container.encodeIfPresent(amount, forKey: .amount)
        try container.encodeIfPresent(mealType, forKey: .mealType)
        try container.encode(date, forKey: .date)
        try container.encodeIfPresent(imageUrl, forKey: .imageUrl)
    }
    
    init(id: UUID = UUID(),
         serverId: Int? = nil,
         name: String,
         calories: Int,
         unit: String = "g",
         amount: Double? = nil,
         mealType: MealType? = nil,
         date: Date,
         imageUrl: String? = nil) {
        self.id = id
        self.serverId = serverId
        self.name = name
        self.calories = calories
        self.unit = unit
        self.amount = amount
        self.mealType = mealType
        self.date = date
        self.imageUrl = imageUrl
    }
}
struct APIResponse<T: Codable>: Codable {
    let message: String
    let data: T
}

struct MealRecordResponse: Codable {
    let id: String
    let food_id: Int
    let name: String
    let calories: Int
    let unit: String
    let amount: Double
    let meal_type: String
    let record_date: String
    let image_url: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case food_id
        case name
        case calories
        case unit
        case amount
        case meal_type
        case record_date
        case image_url
    }
}

class NetworkService {
    static let shared = NetworkService()
    private let baseURL = "http://localhost:4000/api"
    
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        decoder.dateDecodingStrategy = .formatted(formatter)
        return decoder
    }()
    
    private let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        encoder.dateEncodingStrategy = .formatted(formatter)
        return encoder
    }()
    
    func getAllFoods() async throws -> [FoodItem] {
        guard let url = URL(string: "\(baseURL)/foods") else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
           let foodsData = json["data"] as? [[String: Any]] {
            
            return try foodsData.map { foodDict in
                let processedDict: [String: Any] = [
                    "name": foodDict["name"] as? String ?? "",
                    "calories": foodDict["calories"] as? Int ?? 0,
                    "unit": foodDict["unit"] as? String ?? "g"
                ]
                
                let foodData = try JSONSerialization.data(withJSONObject: processedDict)
                return try decoder.decode(FoodItem.self, from: foodData)
            }
        }
        throw URLError(.badServerResponse)
    }
    
    func addFood(_ food: FoodItem) async throws -> Int {
        guard let url = URL(string: "\(baseURL)/foods") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let foodData: [String: Any] = [
            "name": food.name.trimmingCharacters(in: .whitespacesAndNewlines),
            "calories": food.calories,
            "unit": food.unit.trimmingCharacters(in: .whitespacesAndNewlines)
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: foodData)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse,
           !(200...299).contains(httpResponse.statusCode) {
            throw URLError(.badServerResponse)
        }
        
        if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
           let responseData = json["data"] as? [String: Any],
           let id = responseData["id"] as? Int {
            return id
        }
        
        throw URLError(.badServerResponse)
    }
    
    func getMealRecords(userId: Int, date: Date? = nil, mealType: MealType? = nil) async throws -> [FoodItem] {
        // Check for valid UserID
        guard userId > 0 else {
            print("Error: Invalid user ID: \(userId)")
            throw URLError(.badURL)
        }
        
        print("Fetching meal records for user ID \(userId)")
        
        var urlComponents = URLComponents(string: "\(baseURL)/meal-records/\(userId)")!
        var queryItems: [URLQueryItem] = []
        
        if let date = date {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            queryItems.append(URLQueryItem(name: "date", value: formatter.string(from: date)))
        }
        
        if let mealType = mealType {
            queryItems.append(URLQueryItem(name: "meal_type", value: mealType.rawValue))
        }
        
        if !queryItems.isEmpty {
            urlComponents.queryItems = queryItems
        }
        
        guard let url = urlComponents.url else {
            throw URLError(.badURL)
        }
        
        print("Request URL: \(url.absoluteString)")
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        print("Response status code: \(httpResponse.statusCode)")
        
        if let responseString = String(data: data, encoding: .utf8) {
            print("Response data: \(responseString.prefix(200))...")
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        let apiResponse = try decoder.decode(APIResponse<[MealRecordResponse]>.self, from: data)
        
        apiResponse.data.forEach { record in
            print("Loaded record - id:", record.id, "food_id:", record.food_id)
        }
        
        // Server base URL
        let serverBaseUrl = "http://localhost:4000"
        
        return apiResponse.data.map { record in
            // Process image URL, ensure it's a complete URL
            var imageUrl: String? = nil
            if let recordImageUrl = record.image_url, !recordImageUrl.isEmpty {
                // If image URL is already a complete URL (starts with http:// or https://), use it directly
                if recordImageUrl.hasPrefix("http://") || recordImageUrl.hasPrefix("https://") {
                    imageUrl = recordImageUrl
                } else {
                    // Otherwise, add server base URL prefix
                    imageUrl = "\(serverBaseUrl)\(recordImageUrl)"
                }
                print("Processing food record image URL: \(imageUrl ?? "nil")")
            }
            
            let item = FoodItem(
                id: UUID(),
                serverId: record.food_id,
                name: record.name,
                calories: record.calories,
                unit: record.unit,
                amount: record.amount,
                mealType: MealType(rawValue: record.meal_type) ?? .breakfast,
                date: DateFormatter.yyyyMMdd.date(from: record.record_date) ?? Date(),
                imageUrl: imageUrl
            )
            print("Created FoodItem with serverId:", item.serverId ?? "nil", "imageUrl:", item.imageUrl ?? "nil")
            return item
        }
    }
    
    func addMealRecord(userId: Int, food: FoodItem) async throws -> (food_id: Int, id: Int) {
        guard let url = URL(string: "\(baseURL)/foods") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var record: [String: Any] = [
            "name": food.name.trimmingCharacters(in: .whitespacesAndNewlines),
            "calories": food.calories,
            "unit": food.unit.trimmingCharacters(in: .whitespacesAndNewlines),
            "date": ISO8601DateFormatter().string(from: food.date),
            "user_id": userId,
            "meal_type": food.mealType?.rawValue ?? "breakfast",
            "amount": food.amount ?? 1.0
        ]
        
        // Add image URL (if available)
        if let imageUrl = food.imageUrl, !imageUrl.isEmpty {
            record["image_url"] = imageUrl
            print("Including image URL in food record: \(imageUrl)")
        }
        
        request.httpBody = try JSONSerialization.data(withJSONObject: record)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let responseString = String(data: data, encoding: .utf8) {
            print("Server response:", responseString)
        }
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let responseData = json["data"] as? [String: Any] {
            
            let foodId = responseData["food_id"] as? Int ?? 0
            let id = responseData["id"] as? Int ?? 0
            
            print("Parsed server response - food_id:", foodId, "id:", id)
            
            if foodId == 0 {
                print("Warning: Server returned zero or missing food_id")
            }
            
            return (food_id: foodId, id: id)
        }
        
        throw URLError(.cannotParseResponse)
    }
    
    // Add delete method
    func deleteMealRecord(id: String) async throws {
        guard let url = URL(string: "\(baseURL)/meal-records/\(id)") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
    }
    
    // Updating food records
    func updateMealRecord(_ food: FoodItem) async throws {
        guard let serverId = food.serverId else {
            print("Error: No server ID found for food item")
            throw URLError(.badURL)
        }
        
        guard let url = URL(string: "\(baseURL)/foods/\(serverId)") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var record: [String: Any] = [
            "name": food.name.trimmingCharacters(in: .whitespacesAndNewlines),
            "calories": food.calories,
            "unit": food.unit.trimmingCharacters(in: .whitespacesAndNewlines),
            "amount": food.amount ?? 1.0
        ]
        
        // Add image URL (if available)
        if let imageUrl = food.imageUrl, !imageUrl.isEmpty {
            record["image_url"] = imageUrl
            print("Including image URL in food update: \(imageUrl)")
        }
        
        print("Sending update request to:", url.absoluteString)
        print("Update data:", record)
        
        request.httpBody = try JSONSerialization.data(withJSONObject: record)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let responseString = String(data: data, encoding: .utf8) {
            print("Server response:", responseString)
        }
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
    }
}

struct IdResponse: Codable {
    let id: Int
}

struct MealRecord: Codable {
    let userId: Int
    let foodId: Int
    let amount: Double
    let mealType: MealType
    let recordDate: Date
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case foodId = "food_id"
        case amount
        case mealType = "meal_type"
        case recordDate = "record_date"
    }
}

struct AnyCodable: Codable {
    let value: Any
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            value = NSNull()
        } else if let bool = try? container.decode(Bool.self) {
            value = bool
        } else if let int = try? container.decode(Int.self) {
            value = int
        } else if let double = try? container.decode(Double.self) {
            value = double
        } else if let string = try? container.decode(String.self) {
            value = string
        } else {
            value = NSNull()
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch value {
        case is NSNull:
            try container.encodeNil()
        case let bool as Bool:
            try container.encode(bool)
        case let int as Int:
            try container.encode(int)
        case let double as Double:
            try container.encode(double)
        case let string as String:
            try container.encode(string)
        case let float as Float:
            try container.encode(float)
        default:
            try container.encodeNil()
        }
    }
}

@main
struct foodApp: App {
    @StateObject private var viewModel = FoodViewModel()
    
    var body: some Scene {
        WindowGroup {
            AppView()
                .environmentObject(viewModel)
        }
    }
}


class FoodViewModel: ObservableObject {
    @Published var selectedImage: UIImage?
    @Published var searchTerm = ""
    @Published var foodItems: [FoodItem] = []
    @Published var recentHistory: [FoodItem] = []
    @Published var showImagePicker = false
    @Published var showCamera = false
    @Published var showPopup = false
    @Published var mealCounts: [MealType: Int] = [:]
    @Published var selectedDate = Date()
    
    // 初始化方法，确保用户登录后能加载数据
    init() {
        // 注册通知以观察用户登录状态
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(userDidLogin),
            name: Notification.Name("UserDidLoginNotification"),
            object: nil
        )
        
        // 注册通知以观察用户注销状态
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(userDidLogout),
            name: Notification.Name("UserDidLogoutNotification"),
            object: nil
        )
        
        // 如果已经有用户登录，立即加载数据
        if UserManager.shared.currentUser != nil {
            Task {
                await loadFoods()
            }
        }
    }
    
    // 用户登录后触发
    @objc private func userDidLogin() {
        Task {
            await loadFoods()
        }
    }
    
    // 用户注销后触发
    @objc private func userDidLogout() {
        clearData()
    }
    
    // 清空数据
    private func clearData() {
        DispatchQueue.main.async {
            self.foodItems = []
            self.recentHistory = []
            self.mealCounts = [:]
            print("User logged out: Cleared all food record data")
        }
    }
    
    // 析构函数
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func goToPreviousDay() {
        if let newDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) {
            DispatchQueue.main.async {
                // First update the date
                self.selectedDate = newDate
                print("Date changed to previous day: \(self.dateString)")
                
                // Then force refresh data
                Task {
                    await self.loadFoods()
                }
            }
        }
    }
    
    func goToNextDay() {
        if let newDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) {
            DispatchQueue.main.async {
                // First update the date
                self.selectedDate = newDate
                print("Date changed to next day: \(self.dateString)")
                
                // Then force refresh data
                Task {
                    await self.loadFoods()
                }
            }
        }
    }
    
    // Load all food
    @MainActor
    func loadFoods() async {
        // 确保从UserManager获取当前用户ID
        guard let user = UserManager.shared.currentUser else {
            print("Warning: No logged in user, cannot load food records")
            DispatchQueue.main.async {
                self.foodItems = []
                self.mealCounts = [:]
            }
            return
        }
        
        let userId = user.user_id
        print("Loading food records for user ID \(userId), username: \(user.username), date: \(dateString)")
        
        do {
            // Always reload data for current date
            let newFoodItems = try await NetworkService.shared.getMealRecords(userId: userId, date: selectedDate)
            
            // Update foodItems on main thread
            DispatchQueue.main.async {
                self.foodItems = newFoodItems
                print("Successfully loaded \(self.foodItems.count) food records for date \(self.dateString)")
                
                // Print each record for debugging
                self.foodItems.forEach { food in
                    print("Food record: id=\(food.id), name=\(food.name), userId=\(userId), date=\(food.date)")
                }
                
                // Update meal counts
                self.updateMealCounts()
            }
        } catch {
            print("Error loading foods:", error)
            if let urlError = error as? URLError {
                print("URL Error:", urlError.localizedDescription)
            } else {
                print("Other Error:", error.localizedDescription)
            }
            
            DispatchQueue.main.async {
                self.foodItems = []
                self.mealCounts = [:]
            }
        }
    }
    
    // Modify delete method
    @MainActor
    func deleteFood(_ food: FoodItem) async {
        do {
            if let serverId = food.serverId {
                try await NetworkService.shared.deleteMealRecord(id: String(serverId))
                foodItems.removeAll { $0.id == food.id }
                updateMealCounts()
            }
        } catch {
            print("Error deleting food:", error)
        }
    }
    
    // You also don't need to reload all your data after adding food
    @MainActor
    func addFood(_ food: FoodItem) async {
        do {
            print("Adding food:", food)
            
            guard let userId = UserManager.shared.currentUser?.user_id else {
                print("Cannot add food: No logged in user")
                return
            }
            
            let localFood = FoodItem(
                id: food.id,
                serverId: food.serverId,
                name: food.name,
                calories: food.calories,
                unit: food.unit,
                amount: food.amount,
                mealType: food.mealType,
                date: food.date,
                imageUrl: food.imageUrl
            )
            
            foodItems.append(localFood)
            
            updateMealCounts()
            
            print("Added food to local array:", localFood.name)
            print("Current food items:", foodItems.map { $0.name })
            
            let response = try await NetworkService.shared.addMealRecord(userId: userId, food: food)
            print("Food added successfully with IDs - food_id:", response.food_id, "id:", response.id)

            if let index = foodItems.firstIndex(where: { $0.id == localFood.id }) {
                foodItems[index].serverId = response.food_id
                print("Updated serverId for food:", foodItems[index].name, "new serverId:", response.food_id)
            }
        } catch {
            print("Error adding food:", error)
            if let urlError = error as? URLError {
                print("URL Error:", urlError.localizedDescription)
            } else {
                print("Other Error:", error.localizedDescription)
            }
        }
    }
    
  
    @MainActor
    func updateFood(_ food: FoodItem) async {
        do {
            print("Updating food:", food)
            try await NetworkService.shared.updateMealRecord(food)
            print("Food updated successfully")
            
         
            if let index = foodItems.firstIndex(where: { $0.id == food.id }) {
                foodItems[index] = food
            }
            
            updateMealCounts()
        } catch {
            print("Error updating food:", error)
        }
    }
    
  
    private func updateMealCounts() {
        var counts: [MealType: Int] = [:]
        
        // Only count items for the selected date
        let todayItems = foodItems.filter { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
        
        for type in MealType.allCases {
            counts[type] = todayItems.filter { $0.mealType == type }.count
        }
        
        self.mealCounts = counts
        print("Updated meal counts for \(dateString): \(counts)")
    }
    

    var dateString: String {
        let calendar = Calendar.current
        if calendar.isDateInToday(selectedDate) {
            return "Today"
        } else if calendar.isDateInYesterday(selectedDate) {
            return "Yesterday"
        } else if calendar.isDateInTomorrow(selectedDate) {
            return "Tomorrow"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d, yyyy"
            return formatter.string(from: selectedDate)
        }
    }
}

extension DateFormatter {
    static let yyyyMMdd: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}

