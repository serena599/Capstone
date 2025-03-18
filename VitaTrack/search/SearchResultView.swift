//
//  SearchResultView.swift
//  RecipeSearch
//
//  Created by chris on 14/12/2024.
//

import SwiftUI

struct SearchResultView: View { 
    @Binding var searchText: String
    
    @State private var viewName: String = "SearchResultView"
    
    @Environment(\.presentationMode) var presentationMode
    
    @Environment(\.dismiss) var dismiss
    
    
    //观察外部的RecipeFetcher，即来自SearchBar的searchFetcher获取的数据
    @ObservedObject var fetcher: RecipeFetcher
    
    var body: some View {
        
        //导航栏自定义，采用Serana的代码，统一格式
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .foregroundColor(.white)
                    .font(.system(size: 20))
            }
            
            Text("Search")
                .foregroundColor(.white)
                .font(.title3)
                .fontWeight(.semibold)
            
            Spacer()
        }
        .padding()
        .background(Color.foodPrimary)
        
        // 搜索结果界面
        VStack(spacing: 0) {

            // 搜索框
            SearchBar(searchText: $searchText, parentViewName: $viewName, fetcher: fetcher)

            // 获取搜索结果
            if !fetcher.recipes.isEmpty {
                List($fetcher.recipes, id: \.recipe_name) { $recipe in

                        HStack(spacing: 10) {
                            NavigationLink(destination: RecipeDetail(recipeToDisplay: recipe)){
                                
                                AsyncImage(url: URL(string: recipe.image_URL)) { phase in
                                            if let image = phase.image {
                                                image.resizable().scaledToFit()
                                            } else if phase.error != nil {
                                                Image("ImagePlaceholder").resizable()
                                            } else {
                                                ProgressView() // 显示加载指示器
                                            }
                                        }
                                        .frame(width: 110, height: 140)
                                
                                VStack(alignment: .leading, spacing: 10) {
                                    //HStack {
                                    Text(recipe.recipe_name)
                                        .lineLimit(2)
                                    
                                    Text(recipe.short_instruction ?? "")
                                        .foregroundStyle(.secondary)
                                        .font(.system(size: 15))
                                        .lineLimit(2)
                                }
                            }
                            
                            Spacer()

                        }
                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0)) // 自定义左右边距
                        .background(Color.searchResultBackground)
                        .cornerRadius(15)
                        .overlay {
                            HStack {
                                Spacer()
                                
                                VStack {
                                    Image(systemName: recipe.is_recommend ? "suit.heart.fill" : "suit.heart")
                                        .imageScale(.large)
                                        .tint(Color.foodPrimary)
                                        .foregroundStyle(Color.foodPrimary)
                                        .onTapGesture {
                                            recipe.is_recommend.toggle()
                                            
                                            // identify if the current recipe is already added to user's favourate
                                            
                                            // to do: add to user's favourate recipes list ..............
                                            
                                        }
                                        .padding(5)
                                    
                                    Spacer()
                                }
                                .background(Color.searchResultBackground)

                        }
                        //.border(Color.red)
                    }
                }
                .scrollContentBackground(.hidden)
            } else {
                // 如果搜索结果为空，显示无结果图片
                Image("NoResult")
                //.border(Color.red)
                
                Spacer()
            }
        }
        .onAppear {
            fetcher.searchRecipes(searchQuery: searchText) // 避免没有数据
        }
//        .safeAreaInset(edge: .top, spacing: 0) { // 自定义顶部安全区域
//            Color.clear.frame(height: 0) // 模拟一个 0 点的安全区域
//        }
//        .navigationBarTitleDisplayMode(.inline) //移除navigationTitle及其占用的空间
        .navigationBarBackButtonHidden(true) // 隐藏默认返回按钮
    }
}

#Preview {
    @Previewable @State var searchText: String = ""
    @Previewable @State var hasResult: Bool = true
    @Previewable @State var fetcher: RecipeFetcher! = nil
    
    SearchResultView(searchText: $searchText, fetcher: fetcher)
}
