import SwiftUI

struct AppView: View {
    @StateObject private var userManager = UserManager()
    @StateObject private var foodViewModel = FoodViewModel()
    
    var body: some View {
        if userManager.isLoggedIn {
            ContentView()
                .environmentObject(userManager)
                .environmentObject(foodViewModel)
        } else {
            LoginView()
                .environmentObject(userManager)
                .environmentObject(foodViewModel)
        }
    }
}

#Preview {
    AppView()
} 
