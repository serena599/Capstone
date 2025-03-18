import SwiftUI
import Foundation

class HomepageViewModel: ObservableObject {
    @Published var totalProgress: Double = 0.0
    @Published var selectedDate: Date = Date()
    @Published var showDatePicker: Bool = false
    
    var motivationalMessage: String {
        if totalProgress < 0.2 {
            return "Start your day with purpose! Every step counts on your journey to better health."
        } else if totalProgress < 0.4 {
            return "You're making great progress! Keep moving forward and remember that consistency leads to results."
        } else if totalProgress < 0.6 {
            return "You're halfway there! Your dedication is truly inspiring. Push through these next steps."
        } else if totalProgress < 0.8 {
            return "You're almost there! Keep up the great work and stay motivated."
        } else if totalProgress < 1.0 {
            return "So close to the finish line! Perseverance is the key to success."
        } else {
            return "Congratulations on achieving your goal today! Celebrate this win!"
        }
    }
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter
    }()
    
    // Fetch nutrition progress for a specific date
    func fetchNutritionProgress(for date: Date) {
        let userId = 1 // 假设当前用户 ID
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        
        // 获取每日摄入数据
        fetchDailyIntake(userId: userId, date: dateString) { dailyIntake in
            // 获取目标设置数据
            self.fetchGoalSettings(userId: userId) { goalSettings in
                // 计算总进度
                let totalProgress = NutritionProgressCalculator.calculateTotalProgress(
                    dailyIntake: dailyIntake,
                    goalSettings: goalSettings
                )
                
                // 更新总进度
                DispatchQueue.main.async {
                    self.totalProgress = totalProgress
                }
            }
        }
    }
    
    // Fetch daily intake from the backend
    private func fetchDailyIntake(userId: Int, date: String, completion: @escaping ((vegetables: Double, fruits: Double, grains: Double, meat: Double, dairy: Double, extras: Double)) -> Void) {
        guard let url = URL(string: "http://localhost:4000/api/daily_intake?userId=\(userId)&date=\(date)") else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    let vegetables = json["vegetables"] as? Double ?? 0
                    let fruits = json["fruits"] as? Double ?? 0
                    let grains = json["grains"] as? Double ?? 0
                    let meat = json["meat"] as? Double ?? 0
                    let dairy = json["dairy"] as? Double ?? 0
                    let extras = json["extras"] as? Double ?? 0
                    completion((vegetables, fruits, grains, meat, dairy, extras))
                }
            }
        }.resume()
    }
    
    // Fetch goal settings from the backend
    private func fetchGoalSettings(userId: Int, completion: @escaping ((vegetables: Double, fruits: Double, grains: Double, meat: Double, dairy: Double, extras: Double)) -> Void) {
        guard let url = URL(string: "http://localhost:4000/api/goal_settings?userId=\(userId)") else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    let vegetables = json["vegetables"] as? Double ?? 0
                    let fruits = json["fruits"] as? Double ?? 0
                    let grains = json["grains"] as? Double ?? 0
                    let meat = json["meat"] as? Double ?? 0
                    let dairy = json["dairy"] as? Double ?? 0
                    let extras = json["extras"] as? Double ?? 0
                    completion((vegetables, fruits, grains, meat, dairy, extras))
                }
            }
        }.resume()
    }
}
