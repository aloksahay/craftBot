import SwiftUI
import BigInt
import Foundation
import web3

struct LoginView: View {
    @StateObject var vm: Web3AuthViewModel
    @State private var emailInput: String = ""
    
    var body: some View {
        // Main container
        ZStack {
            // Background layer
            Image("splash")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(minWidth: 0, maxWidth: .infinity)
                .edgesIgnoringSafeArea(.all)
            
            // Content layer
            VStack {
                Spacer() // Push content to bottom
                
                // Login form container
                VStack(spacing: 20) {
                    // Title and description
                    VStack(spacing: 12) {
                        Text("Save Rob")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                        
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.white.opacity(0.3))
                            .padding(.horizontal, 40)
                        
                        Text("Save Rob from being scraped and replaced by the AI overlords")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                    .padding(.bottom, 30)
                    
                    // Email field
                    TextField("Enter your email", text: $emailInput)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .frame(height: 50)
                        .textFieldStyle(CustomTextFieldStyle())
                    
                    // Login button
                    Button(action: {
                        vm.loginEmailPasswordless(provider: .EMAIL_PASSWORDLESS, email: emailInput)
                    }) {
                        Text("Login")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.black.opacity(0.5))
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 50)
            }
            
            // Loading overlay
            if vm.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
            }
        }
    }
}


struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        let mockViewModel = Web3AuthViewModel()
        
        // Initialize preview environment
        return Group {
            LoginView(vm: mockViewModel)
                .onAppear {
                    Task {
                        await mockViewModel.setup()
                    }
                }
                .previewDisplayName("Login Screen")
        }
    }
}
