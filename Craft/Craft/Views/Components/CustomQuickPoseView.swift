import SwiftUI
import QuickPoseSwiftUI
import QuickPoseCore

struct CustomQuickPoseView: View {
    var body: some View {
        TrackBodyPoseView()
            .overlay(
                // This empty view overlay will cover the record button
                Color.clear
                    .frame(width: 60, height: 60)
                    .position(x: UIScreen.main.bounds.width - 40, y: 60)
            )
    }
} 
