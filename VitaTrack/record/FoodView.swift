import SwiftUI


struct FoodView: View {
 
    @EnvironmentObject private var viewModel: FoodViewModel
    
  
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                
                ForEach(MealType.allCases) { type in
                    NavigationLink {
                        MealCompositionView(mealType: type)
                    } label: {
                        MealCard(type: type)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Food")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.white)
    }
}


struct MealCard: View {

    let type: MealType

    @EnvironmentObject private var viewModel: FoodViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
          
            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.3))
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: type.icon)
                        .font(.title3)
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.3))
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: "arrow.right")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            
            Spacer()
            
        
            Text(type.title)
                .font(.title.bold())
                .foregroundColor(.white)
            
            Text("Items Added")
                .font(.title3)
                .foregroundColor(.white.opacity(0.9))
        }
        .frame(height: 180)
        .padding()
        .background(
            ZStack {
                type.color
                
               
                ForEach(0..<3) { i in
                    Circle()
                        .fill(Color.white.opacity(0.2 - Double(i) * 0.05))
                        .frame(width: [90, 40, 60][i])
                        .offset(x: [50, -30, 20][i], y: [50, -20, -40][i])
                }
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    NavigationView {
        FoodView()
            .environmentObject(FoodViewModel())
    }
}
