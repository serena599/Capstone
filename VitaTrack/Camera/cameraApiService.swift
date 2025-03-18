import UIKit

class ApiService {
    static let shared = ApiService()
    private let baseUrl = "http://localhost:4000/api"
    
    func uploadImage(_ image: UIImage, completion: @escaping (String?) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(nil)
            return
        }
        
        let url = URL(string: "\(baseUrl)/uploadFoodImage")!
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
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error uploading image: \(error)")
                completion(nil)
                return
            }
            
            if let data = data,
               let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let imageUrl = json["imageUrl"] as? String {
                completion(imageUrl)
            } else {
                completion(nil)
            }
        }.resume()
    }
    
    func saveFoodRecord(userId: Int, recordDate: String, imageUrl: String, mealType: String,
                        categories: [FoodCategory], completion: @escaping (Bool) -> Void) {
        let record: [String: Any] = [
            "user_id": userId,
            "recordDate": recordDate,
            "imageUrl": imageUrl,
            "mealType": mealType,
            "vegetables": categories.first(where: { $0.name == "vegetables" })?.quantity ?? 0,
            "fruit": categories.first(where: { $0.name == "fruit" })?.quantity ?? 0,
            "grains": categories.first(where: { $0.name == "grains" })?.quantity ?? 0,
            "meat": categories.first(where: { $0.name == "meat" })?.quantity ?? 0,
            "dairy": categories.first(where: { $0.name == "dairy" })?.quantity ?? 0,
            "extras": categories.first(where: { $0.name == "extras" })?.quantity ?? 0
        ]
        
        let url = URL(string: "\(baseUrl)/food-records")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: record, options: [])
            request.httpBody = jsonData
        } catch {
            completion(false)
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error saving record: \(error)")
                completion(false)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response")
                completion(false)
                return
            }
            
            completion(httpResponse.statusCode == 200)
        }.resume()
    }
}
