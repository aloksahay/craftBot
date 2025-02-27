import SwiftUI

@main
struct CraftApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(vm: Web3AuthViewModel())
//            TrackBodyPoseView()
//            UploadVideoView()
        }
    }
}
