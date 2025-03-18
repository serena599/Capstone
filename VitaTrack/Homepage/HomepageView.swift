import SwiftUI

struct HomepageView: View {
    @StateObject private var viewModel = HomepageViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 30) {
                // Date Picker Button
                Button(action: {
                    viewModel.showDatePicker.toggle()
                }) {
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.black)
                        Text(viewModel.dateFormatter.string(from: viewModel.selectedDate))
                            .font(.headline)
                            .foregroundColor(.black)
                    }
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(10)
                }
                .sheet(isPresented: $viewModel.showDatePicker) {
                    VStack {
                        DatePicker("Select Date", selection: $viewModel.selectedDate, displayedComponents: .date)
                            .datePickerStyle(GraphicalDatePickerStyle())
                            .padding()
                        
                        Button("Done") {
                            // Fetch progress for the selected date
                            viewModel.fetchNutritionProgress(for: viewModel.selectedDate)
                            viewModel.showDatePicker = false
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.customGreen)
                        .cornerRadius(10)
                        .padding(.bottom, 20)
                    }
                    .presentationDetents([.medium])
                }
                .padding(.top, 20)
                
                // Progress Ring
                ProgressRingView(progress: viewModel.totalProgress)
                    .padding(.vertical, 20)
                
                // Motivational Message
                Text(viewModel.motivationalMessage)
                    .font(.headline)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding(.bottom, 15)
                
                // Action Buttons
                VStack(spacing: 25) {
                    HomepageActionButton(
                        title: "Set",
                        subtitle: "Your Goal",
                        buttonText: "Set Now",
                        backgroundColor: .customGreen,
                        destination: AnyView(GoalSettingView())
                    )
                    
                    HomepageActionButton(
                        title: "Track",
                        subtitle: "Your Progress",
                        buttonText: "Track Now",
                        backgroundColor: .customPink,
                        destination: AnyView(GoalTrackingView())
                    )
                }
                
                Spacer()
            }
            .padding(.bottom, 20)
        }
        .navigationTitle("")
        .background(Color.white)
        .onAppear {
            // Fetch progress for the current date when the view appears
            viewModel.fetchNutritionProgress(for: viewModel.selectedDate)
        }
    }
}
