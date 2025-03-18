//
//  RecipeFetcher.swift
//  RecipeSearch
//
//  Created by chris on 2/2/2025.
//

//Search function implementation class file. The example is used to process the sent request and get the result of the database data returned by node.js

import Foundation

class RecipeFetcher: ObservableObject {
    @Published var recipes: [Recipe] = []
    
    
    //This method is the get method and is used only to get the default recommended recipes, assign the result to a Recipe array instance of the RecipeList, and iterate through the SearchView to show all Recipe instances in the RecipeList instance
    func fetchRecipes() {
        guard let url = URL(string: "http://localhost:4000/api/recipes") else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            //test code, fetch predefined json data from node.js
//            if let data = data {
//                do {
//                    let decodedData = try JSONDecoder().decode([Recipe].self, from: data)
//                    DispatchQueue.main.async {
//                        self.recipes = decodedData
//                        print(self.recipes)
//                    }
//                } catch {
//                    print("JSON parsing error:", error)
//                }
//            }
            
            //test code, fetch all recommended recipes from mysql database via app.js
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async {
                do {
                    self.recipes = try JSONDecoder().decode([Recipe].self, from: data)
                    print("✅ Search successful. Receive \(self.recipes.count) results")
                    print(self.recipes)
                } catch {
                    print("❌ JSON parsing failed:", error)
                }
            }
        }.resume()
    }
    
    
    //This method is the post method, which is used to trigger keyword search in the SearchBar, obtain the database query data returned by app.js, and update the data in the SearchResultView
    func searchRecipes(searchQuery: String) {
        print("🔍 Trigger a search request, search for keywords: \(searchQuery)")
        
        guard let url = URL(string: "http://localhost:4000/api/search") else {
            print("❌ URL invalid")
            return
        }
                
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ["query": searchQuery]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Request error:", error.localizedDescription)
                return
            }
            
            guard let data = data else {
                print("❌ No data received")
                return
            }
            
            do {
                let decodedRecipes = try JSONDecoder().decode([Recipe].self, from: data)
                DispatchQueue.main.async {
                    self.recipes = decodedRecipes
                    print("✅ The search is successful and \(decodedRecipes.count) results are received")
                    print(decodedRecipes)
                }
            } catch {
                print("Decoding error: \(error)")
            }
        }.resume()
    }
    
    // Fetch user's favorite recipes
    func fetchFavoriteRecipes(userID: String) {
        print("🔍 Fetching favorite recipes for user \(userID)")
        
        guard !userID.isEmpty else {
            print("❌ User ID cannot be empty")
            return
        }
        
        guard let url = URL(string: "http://localhost:4000/api/user-favorite-recipes/\(userID)") else {
            print("❌ Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ Request error:", error.localizedDescription)
                return
            }
            
            guard let data = data else {
                print("❌ No data received")
                return
            }
            
            do {
                let decodedRecipes = try JSONDecoder().decode([Recipe].self, from: data)
                DispatchQueue.main.async {
                    self.recipes = decodedRecipes
                    print("✅ Successfully fetched favorite recipes, total: \(decodedRecipes.count) results")
                }
            } catch {
                print("❌ Decoding error: \(error)")
            }
        }.resume()
    }
}
