//
//  FavoriteManager.swift
//  VitaTrack
//
//  Created by AI Assistant on 13/03/2025.
//

import Foundation
import Combine

// User favorite data model
struct FavoriteRecipe: Identifiable, Codable {
    let id: String
    var user_id: String
    var recipe_ID: Int
}

// Class for managing user favorites
class FavoriteManager: ObservableObject {
    static let shared = FavoriteManager()
    @Published var currentUserID: String = ""
    @Published var userFavorites: [Int] = [] // Store the list of recipe IDs favorited by the current user
    
    private init() {
        // 注册通知监听用户登录和注销
        NotificationCenter.default.addObserver(
            self, 
            selector: #selector(userDidLogin),
            name: Notification.Name("UserDidLoginNotification"),
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self, 
            selector: #selector(userDidLogout),
            name: Notification.Name("UserDidLogoutNotification"),
            object: nil
        )
        
        // 检查是否已有用户登录
        if let user = UserManager.shared.currentUser {
            self.currentUserID = String(user.user_id)
            fetchUserFavorites()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func userDidLogin() {
        if let user = UserManager.shared.currentUser {
            self.currentUserID = String(user.user_id)
            print("FavoriteManager: User logged in, updated current user ID to \(self.currentUserID)")
            fetchUserFavorites()
        }
    }
    
    @objc private func userDidLogout() {
        self.currentUserID = ""
        self.userFavorites = []
        print("FavoriteManager: User logged out, cleared favorites list")
    }
    
    func setCurrentUser(userID: String) {
        self.currentUserID = userID
        fetchUserFavorites()
    }
    
    func fetchUserFavorites() {
        // Get user's favorite list from server
        guard !currentUserID.isEmpty else { return }
        guard let url = URL(string: "http://localhost:4000/api/favorites/\(currentUserID)") else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else { return }
            
            do {
                let favorites = try JSONDecoder().decode([FavoriteRecipe].self, from: data)
                DispatchQueue.main.async {
                    self.userFavorites = favorites.map { $0.recipe_ID }
                    print("✅ Successfully retrieved user favorites, total: \(self.userFavorites.count)")
                }
            } catch {
                print("❌ Failed to parse user favorites:", error)
            }
        }.resume()
    }
    
    func toggleFavorite(recipeID: Int) {
        guard !currentUserID.isEmpty else { return }
        
        if userFavorites.contains(recipeID) {
            removeFavorite(recipeID: recipeID)
        } else {
            addFavorite(recipeID: recipeID)
        }
    }
    
    private func addFavorite(recipeID: Int) {
        guard let url = URL(string: "http://localhost:4000/api/favorites/add") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["user_id": currentUserID, "recipe_ID": recipeID] as [String : Any]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if error == nil {
                DispatchQueue.main.async {
                    self.userFavorites.append(recipeID)
                    print("✅ Successfully added to favorites")
                }
            } else {
                print("❌ Failed to add favorite:", error?.localizedDescription ?? "")
            }
        }.resume()
    }
    
    private func removeFavorite(recipeID: Int) {
        guard let url = URL(string: "http://localhost:4000/api/favorites/remove") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["user_id": currentUserID, "recipe_ID": recipeID] as [String : Any]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if error == nil {
                DispatchQueue.main.async {
                    self.userFavorites.removeAll { $0 == recipeID }
                    print("✅ Successfully removed from favorites")
                }
            } else {
                print("❌ Failed to remove favorite:", error?.localizedDescription ?? "")
            }
        }.resume()
    }
    
    func isFavorite(recipeID: Int) -> Bool {
        return userFavorites.contains(recipeID)
    }
}