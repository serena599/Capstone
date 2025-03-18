import SwiftUI
import PhotosUI

struct FoodScanView: View {
    @EnvironmentObject private var foodViewModel: FoodViewModel
    @State private var showPhotoPicker = false
    @State private var showCamera = false
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var navigateToResults = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.ignoresSafeArea()
                
                VStack {
                    Spacer()
                    
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 300)
                            .cornerRadius(10)
                            .padding()
                    } else {
                        Image("camera")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 300)
                            .padding()
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 40) {
                        Button(action: {
                            showPhotoPicker = true
                        }) {
                            Image(systemName: "photo.on.rectangle")
                                .font(.system(size: 24))
                                .foregroundColor(Color.black)
                                .frame(width: 60, height: 60)
                        }
                        
                        Button(action: {
                            showCamera = true
                        }) {
                            Circle()
                                .fill(Color.foodPrimary)
                                .frame(width: 70, height: 70)
                                .overlay(
                                    Image(systemName: "camera")
                                        .font(.system(size: 30))
                                        .foregroundColor(.white)
                                )
                        }
                        
                        Button(action: {}) {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .font(.system(size: 24))
                                .foregroundColor(Color.black)
                                .frame(width: 60, height: 60)
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
            .photosPicker(isPresented: $showPhotoPicker, selection: $selectedItem, matching: .images)
            .onChange(of: selectedItem) { newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        selectedImage = uiImage
                        navigateToResults = true
                    }
                }
            }
            .sheet(isPresented: $showCamera) {
                ImagePicker(selectedImage: $selectedImage, sourceType: .camera)
                    .ignoresSafeArea()
                    .onDisappear {
                        if selectedImage != nil {
                            navigateToResults = true
                        }
                    }
            }
            .navigationDestination(isPresented: $navigateToResults) {
                if let image = selectedImage {
                    FoodResultsView(image: image)
                        .environmentObject(foodViewModel)
                }
            }
        }
        .environmentObject(foodViewModel)
        .onAppear {
            print("Current food items count: \(foodViewModel.foodItems.count)")
        }
    }
}

#Preview("Food Scan") {
    FoodScanView()
        .environmentObject(FoodViewModel())
}
