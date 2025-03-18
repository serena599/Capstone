//
//  RecipeDetail.swift
//  RecipeSearch
//
//  Created by chris on 15/12/2024.
//

import SwiftUI

struct RecipeDetail: View {
    @State var recipeToDisplay: Recipe = Recipe(recipe_ID: 1, recipe_name: "Grilled Meat and Egg Salad with Avocado", image_URL: "https://i2.chuimg.com/d7cb9c0430e34c69aca5f4ac7a2994a6_606w_404h.jpg", traffic_lights:
                                                    ["Saturates": "green",
                                                     "Sugar": "green",
                                                     "Salt": "green",
                                                     "Fat": "green",
                                                     "Source": "link:<www.123123123.com>"],
                                                food_type: "breakfast"
    )
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) var dismiss
    @ObservedObject private var favoriteManager = FavoriteManager.shared
    @State private var isFavorite: Bool = false
    
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
        
        ScrollView {
            VStack {
                HStack {
                    // recipe info: image, title, ingredients and favourate button
                    AsyncImage(url: URL(string: recipeToDisplay.image_URL)) { phase in
                                if let image = phase.image {
                                    image.resizable().scaledToFit()
                                } else if phase.error != nil {
                                    Image("ImagePlaceholder").resizable()
                                } else {
                                    ProgressView() // 显示加载指示器
                                }
                            }
                            .frame(width: 110, height: 140)
                            //.clipShape(Circle())
                   
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Spacer()
                            
                            Text(recipeToDisplay.recipe_name)
                                .font(.title3)

                            Spacer()
                            
                            Spacer()
                        }
                        
                        HStack {
                            Spacer()
                            
                            Text(recipeToDisplay.short_instruction ?? "")
                                .foregroundStyle(.secondary)
                                .font(.system(size: 15))
                            
                            Spacer()
                            
                            Spacer()
                        }
                    }
                    
                }
                .background(Color.searchResultBackground)
                .cornerRadius(15)
                //.padding(.bottom, 20)
                .overlay {
                    HStack {
                        Spacer()
                        
                        VStack {
                            Image(systemName: isFavorite ? "suit.heart.fill" : "suit.heart")
                                .imageScale(.large)
                                .tint(Color.green)
                                .foregroundStyle(Color.green)
                                .onTapGesture {
                                    favoriteManager.toggleFavorite(recipeID: recipeToDisplay.recipe_ID)
                                    isFavorite.toggle() // 立即反馈UI效果
                                }
                                .padding(5)
                            
                            Spacer()
                        }
                        
                    }
                }

                // Instruction
                if recipeToDisplay.instructions ?? "" != "" {
                    HStack {
                        Image(systemName: "lightbulb.max.fill")
                            .foregroundStyle(Color.yellow)
                        
                        Text("Instructions")
                            .font(.headline)
                        
                        Spacer()
                    }
                    .padding(.top, 20)
                    
                    // Instruction content
                    VStack {
                        Text(recipeToDisplay.instructions ?? "")
                            .foregroundStyle(.secondary)
                            .padding()
                    }
                    .background(Color.searchResultBackground)
                    .cornerRadius(20)
                }
                
                // Ingredients title
                HStack {
                    Image(systemName: "lightbulb.max.fill")
                        .foregroundStyle(Color.yellow)
                    
                    Text("Ingredients")
                        .font(.headline)
                    
                    Spacer()
                }
                .padding(.top, 20)
                
                // Ingredients content
                VStack {
                    ForEach(recipeToDisplay.ingredients ?? ["",""], id: \.self){ ingredient in
                        HStack {
                            Text("*   ")
                                .bold()
                            
                            Text(ingredient)
                                .bold()
                            
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 5)
                        .padding(.bottom, 5)
                    }
                }
                .background(Color.searchResultBackground)
                .cornerRadius(20)
            }
            
            // Method
            if recipeToDisplay.method ?? "" != "" {
                HStack {
                    Image(systemName: "lightbulb.max.fill")
                        .foregroundStyle(Color.yellow)
                    
                    Text("Method")
                        .font(.headline)
                    
                    Spacer()
                }
                .padding(.top, 20)
                
                // Dressing content
                VStack {
                    Text(recipeToDisplay.method ?? "")
                        .foregroundStyle(.secondary)
                        .padding()
                }
                .background(Color.searchResultBackground)
                .cornerRadius(20)
            }
            
            // Hint
            if recipeToDisplay.hint ?? "" != "" {
                HStack {
                    Image(systemName: "lightbulb.max.fill")
                        .foregroundStyle(Color.yellow)
                    
                    Text("Hint")
                        .font(.headline)
                    
                    Spacer()
                }
                .padding(.top, 20)
                
                // Dressing content
                VStack {
                    Text(recipeToDisplay.hint ?? "")
                        .foregroundStyle(.secondary)
                        .padding()
                }
                .background(Color.searchResultBackground)
                .cornerRadius(20)
            }
            
            // Dressing title
            if recipeToDisplay.dressing ?? ["",""] != ["",""] {
                HStack {
                    Image(systemName: "lightbulb.max.fill")
                        .foregroundStyle(Color.yellow)
                    
                    Text("Dressing")
                        .font(.headline)
                    
                    Spacer()
                }
                .padding(.top, 20)
                
                // Dressing content
                VStack {
                    ForEach(recipeToDisplay.dressing ?? ["",""], id: \.self){ dress in
                        HStack {
                            Text("*   ")
                                .bold()
                            
                            Text(dress)
                                .bold()
                            
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 5)
                        .padding(.bottom, 5)
                    }
                }
                .background(Color.searchResultBackground)
                .cornerRadius(20)
            }
            
            // Variation title
            if recipeToDisplay.variation ?? "" != "" {
                HStack {
                    Image(systemName: "lightbulb.max.fill")
                        .foregroundStyle(Color.yellow)
                    
                    Text("Variation")
                        .font(.headline)
                    
                    Spacer()
                }
                .padding(.top, 20)
                
                // Variation content
                VStack {
                    Text(recipeToDisplay.variation ?? "")
                        .foregroundStyle(.secondary)
                        .padding()
                }
                .background(Color.searchResultBackground)
                .cornerRadius(20)
            }
        
            // Traffic Lights title
            HStack {
                Image(systemName: "lightbulb.max.fill")
                    .foregroundStyle(Color.yellow)
                
                Text("Traffic Lights")
                    .font(.headline)
                
                Spacer()
            }
            .padding(.top, 20)
            
            // Traffic Lights contents
            VStack {
                // Flavours
                HStack {
                    Text(recipeToDisplay.recipe_name)
                        .font(.headline)
                        .padding(.horizontal, 10)
                    
                    Spacer()
                }
                .padding(.top, 10)
                .padding(.horizontal, 20)
                
                HStack(spacing: 10) {
                    HStack {
                        Text("Saturates: ")
                            .padding(.horizontal, 5)
                        
                        Spacer()
                           
                        Image(systemName: "circle.fill")
                            .imageScale(.large)
                            .foregroundStyle(Color.foodPrimary)

                    }
                    .padding(5)
                    .frame(maxWidth: 140, maxHeight: 40)
                    .background(
                        Capsule()
                            .stroke(Color.white, lineWidth: 0.8)
                            .background(Color.white)
                    )
                    .clipShape(Capsule())
                    
                    HStack {
                        Text("Salt: ")
                            .padding(.horizontal, 5)
                        
                        Spacer()
                        
                        Image(systemName: "circle.fill")
                            .imageScale(.large)
                            .foregroundStyle(Color.foodPrimary)

                    }
                    .padding(5)
                    .frame(maxWidth: 140, maxHeight: 40)
                    .background(
                        Capsule()
                            .stroke(Color.white, lineWidth: 0.8)
                            .background(Color.white)
                    )
                    .clipShape(Capsule())
                }
                
                HStack(spacing: 10) {
                    HStack {
                        Text("Sugers: ")
                            .padding(.horizontal, 5)
                        
                        Spacer()
                           
                        Image(systemName: "circle.fill")
                            .imageScale(.large)
                            .foregroundStyle(Color.foodPrimary)

                    }
                    .padding(5)
                    .frame(maxWidth: 140, maxHeight: 40)
                    .background(
                        Capsule()
                            .stroke(Color.white, lineWidth: 0.8)
                            .background(Color.white)
                    )
                    .clipShape(Capsule())
                    
                    HStack {
                        Text("Fat: ")
                            .padding(.horizontal, 5)
                           
                        Spacer()
                        
                        Image(systemName: "circle.fill")
                            .imageScale(.large)
                            .foregroundStyle(Color.foodTertiary)

                    }
                    .padding(5)
                    .frame(maxWidth: 140, maxHeight: 40)
                    .background(
                        Capsule()
                            .stroke(Color.white, lineWidth: 0.8)
                            .background(Color.white)
                    )
                    .clipShape(Capsule())
                }
                

                HStack {
                    //Text("Source: ")
                    Text("Source:")
                        .font(.system(size: 15))
                        .padding(.horizontal, 5)
                    
                        Text(recipeToDisplay.source ?? "https://www.eatforhealth.gov.au")
                            .font(.system(size: 15))
                            .bold()
                            .foregroundStyle(Color.foodPrimary)
                            .onTapGesture {
                                // todo: goto url......
                                if let url = URL(string: recipeToDisplay.source ?? "https://www.eatforhealth.gov.au") {
                                    UIApplication.shared.open(url)
                                }
                            }
                }
                .padding(.horizontal, 5)
                .padding()
                
                
                
            }
            .background(Color.searchResultBackground)
            .cornerRadius(20)
            
        }
        .padding(.horizontal, 20)
        //.border(Color.red)
        .safeAreaInset(edge: .top, spacing: 0) {
            Color.clear.frame(height: 20)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true) 
        .onAppear {
            // 检查当前菜谱是否已收藏
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isFavorite = favoriteManager.isFavorite(recipeID: recipeToDisplay.recipe_ID)
            }
        }
    }
}

#Preview {
    RecipeDetail()
}
