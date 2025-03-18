import Foundation

struct NutritionProgressCalculator {
    /// 计算总进度（简单平均法）
    static func calculateTotalProgress(dailyIntake: (vegetables: Double, fruits: Double, grains: Double, meat: Double, dairy: Double, extras: Double),
                                      goalSettings: (vegetables: Double, fruits: Double, grains: Double, meat: Double, dairy: Double, extras: Double)) -> Double {
        // 计算每个类别的进度
        let vegetablesProgress = min(dailyIntake.vegetables / goalSettings.vegetables, 1.0)
        let fruitsProgress = min(dailyIntake.fruits / goalSettings.fruits, 1.0)
        let grainsProgress = min(dailyIntake.grains / goalSettings.grains, 1.0)
        let meatProgress = min(dailyIntake.meat / goalSettings.meat, 1.0)
        let dairyProgress = min(dailyIntake.dairy / goalSettings.dairy, 1.0)
        let extrasProgress = min(dailyIntake.extras / goalSettings.extras, 1.0)
        
        // 计算总进度（简单平均法）
        let totalProgress = (vegetablesProgress + fruitsProgress + grainsProgress + meatProgress + dairyProgress + extrasProgress) / 6.0
        return totalProgress
    }
}

