import SwiftUI

struct ContentView: View {
    @StateObject var vm: Web3AuthViewModel
    @State private var showHandDetection = false
    
    var body: some View {
        NavigationView {
            VStack {
                if vm.isLoading {
                    ProgressView()
                } else {
                    if vm.loggedIn, let user = vm.user, let web3rpc = Web3RPC(user: user) {
                        TabView {
                            // First Tab: Video Feed
                            VideoFeedView()
                                .tabItem {
                                    Label("Watch", systemImage: "play.circle.fill")
                                }
                            
                            // Second Tab: Upload
                            UploadVideoView()
                                .tabItem {
                                    Label("Upload", systemImage: "arrow.up.circle.fill")
                                }
                        }
                    } else {
                        LoginView(vm: vm)
                    }
                }
                Spacer()
            }
        }
        .preferredColorScheme(.light)
        .onAppear {
            Task {
                await vm.setup()
            }
        }
    }
}
