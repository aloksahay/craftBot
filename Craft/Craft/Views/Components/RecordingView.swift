import SwiftUI
import QuickPoseSwiftUI
import QuickPoseCore
import AVFoundation

struct RecordingView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var recordingModel = RecordingDataModel()
    
    var body: some View {
        ZStack {
            // QuickPose view with disabled record button
            CustomQuickPoseView()
            
            // Record button overlay at bottom
            VStack {
                Spacer()
                recordButton
                    .padding(.bottom, 50)
            }
        }
        .ignoresSafeArea()
        .onChange(of: recordingModel.isRecordingComplete) { complete in
            if complete {
                saveAndDismiss()
            }
        }
    }
    
    private var recordButton: some View {
        Button(action: {
            if recordingModel.isRecording {
                recordingModel.stopRecording()
            } else {
                recordingModel.startRecording()
            }
        }) {
            Circle()
                .fill(recordingModel.isRecording ? .red : .white)
                .frame(width: 80, height: 80)
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 4)
                )
        }
    }
    
    private func saveAndDismiss() {
        // Save video locally and update VideoStore
        VideoStore.shared.addVideo(
            Video(
                id: UUID().uuidString,
                title: "My Recording",
                creator: "You",
                thumbnailImage: recordingModel.thumbnailImage ?? UIImage(systemName: "video.fill")!,
                isUploaded: false,
                videoURL: recordingModel.recordedVideoURL
            )
        )
        print("Debug: Added new video to VideoStore")
        dismiss()
    }
} 
