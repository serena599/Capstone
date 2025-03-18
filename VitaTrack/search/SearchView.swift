//
//  SearchView.swift
//  RecipeSearch
//
//  Created by chris on 9/12/2024.
//

import SwiftUI

struct SearchView: View {
    //@State var selectedRecipe: Recipe = Recipe(title: "", image: Image("ImagePlaceholder"))
    
    @State private var viewName: String = "SearchView"
    
    @State private var receipeList: [String] = []
    @State private var searchText = ""
    @State private var searhIsActive: Bool = false
    @State private var tabSelection: Int = 1
    @State private var hasResult: Bool = false
    
    
    @State var show_favorite_recipes: Bool
    
    //test code, initial a recipe list
//    @State var recommend_recipes: [Recipe] = []
    
    //用于处理请求获取node.js返回的数据库数据的实例
    @StateObject private var fetcher = RecipeFetcher()
    @ObservedObject private var favoriteManager = FavoriteManager.shared
    
    var body: some View {
        
        // send request to get recommendation recipe list
        //recommend_recipes = fetcher.recipes
        
        //ScrollView {
  
        NavigationStack() {
                
                VStack {
                    // search bar
                    SearchBar(searchText: $searchText, parentViewName: $viewName, fetcher: fetcher)
                    
                    // debuug for navigation
                    //Text("\(tabSelection) is selected")
                    
                    // meal navigation
                    HStack(spacing: 10) {
                        // meal lists navigation tabs (4)
                        
                        //Recommendation
                        Button {
                            if tabSelection != 1 {
                                tabSelection = 1
                            }
                            
                            // to do: switch to recommendation list of popular recipes...
                            show_favorite_recipes = false
                            
                        } label: {
                            if tabSelection == 1 {
                                Text("Recommendation").font(.headline)
                                    .frame(maxWidth: 170, maxHeight: 40)
                                    .foregroundColor(.white)
                                    .background(
                                        Capsule()
                                            .stroke(Color("IconGreen"), lineWidth: 0.8)
                                            //.background(Color("IconGreen"))
                                            .background(Color.foodPrimary)
                                        //.clipped()
                                    )
                                    .clipShape(Capsule())
                            } else {
                                Text("Recommendation").font(.headline)
                                    .frame(maxWidth: 170, maxHeight: 40)
                                    .foregroundColor(.black)
                                
                            }
                        }
                        
                        
                        //My favorite
                        Button {
                            if tabSelection != 2 {
                                tabSelection = 2
                            }
                            
                            // 切换到收藏夹，从服务器获取最新收藏数据
                            show_favorite_recipes = true
                            
                            // 从服务器获取用户收藏的食谱详情
                            if !favoriteManager.currentUserID.isEmpty {
                                fetcher.fetchFavoriteRecipes(userID: favoriteManager.currentUserID)
                            } else {
                                print("Warning: No logged in user, cannot fetch favorites data")
                            }
                            
                        } label: {
                            if tabSelection == 2 {
                                Text("My favorite").font(.headline)
                                    .frame(maxWidth: 170, maxHeight: 40)
                                    .foregroundColor(.white)
                                    .background(
                                        Capsule()
                                            .stroke(Color("IconGreen"), lineWidth: 0.8)
                                            //.background(Color("IconGreen"))
                                            .background(Color.foodPrimary)
                                    )
                                    .clipShape(Capsule())
                            } else {
                                Text("My favorite").font(.headline)
                                    .frame(maxWidth: 170, maxHeight: 40)
                                    .foregroundColor(.black)
                            }
                            //.cornerRadius(100)
                        }
                        
                    }
                    .tint(Color.gray)
                    .frame(height: 40)
                    //.padding(.top, 10)
                    //.border(Color.red)
                    //ScrollView {
                    
                    RecipeList(fetcher: fetcher, show_favorite_recipes: $show_favorite_recipes)
                        .onAppear() {
                            fetcher.fetchRecipes()
                        }
                }
        }
        .navigationTitle("Search")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.white)
        .onAppear {
            // 不再需要设置硬编码的用户ID，现在FavoriteManager会从UserManager获取
            // 如果需要，仍然可以触发收藏数据的刷新
            if !favoriteManager.currentUserID.isEmpty {
                favoriteManager.fetchUserFavorites()
            }
        }
    }
}

#Preview {
    SearchView(show_favorite_recipes: false)
}
