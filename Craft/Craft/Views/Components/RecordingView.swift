import SwiftUI
import QuickPoseSwiftUI
import QuickPoseCore
import AVFoundation

struct RecordingView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var recordingModel = RecordingDataModel()
    @State private var overlayImage: UIImage?
    @State private var showOverlay = true
    @State private var recordedFramesData: [FrameData] = []
    
    private let quickPose = QuickPose(sdkKey: CraftEnvironmentVariables.quickPoseSDKKey)
    
    var body: some View {
        ZStack {
            // Camera view with QuickPose tracking
            GeometryReader { geometry in
                ZStack(alignment: .top) {
                    if ProcessInfo.processInfo.isiOSAppOnMac,
                       let url = Bundle.main.url(forResource: "happy-dance", withExtension: "mov") {
                        QuickPoseSimulatedCameraView(useFrontCamera: false, delegate: quickPose, video: url)
                    } else {
                        QuickPoseCameraView(useFrontCamera: true, delegate: quickPose)
                    }
                    
                    if showOverlay {
                        QuickPoseOverlayView(overlayImage: $overlayImage)
                    }
                }
                .frame(width: geometry.size.width)
            }
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                quickPose.start(features: [.overlay(.wholeBodyAndHead)]) { status, image, features, feedback, landmarks in
                    if showOverlay {
                        overlayImage = image
                    }
                    
                    if case .success = status, recordingModel.isRecording {
                        let frameData = FrameData(
                            timestamp: Date().timeIntervalSince1970,
                            features: features,
                            landmarks: landmarks
                        )
                        recordedFramesData.append(frameData)
                    }
                }
            }
            .onDisappear {
                quickPose.stop()
            }
            
            // Record button overlay at bottom
            VStack {
                HStack {
                    Button(action: { showOverlay.toggle() }) {
                        Image(systemName: showOverlay ? "eye.fill" : "eye.slash.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                            .frame(width: 50, height: 50)
                            .background(Circle().fill(Color.black.opacity(0.6)))
                    }
                    .padding(.top, 40)
                    .padding(.leading, 20)
                    Spacer()
                }
                
                Spacer()
                recordButton
                    .padding(.bottom, 50)
            }
            
            // Recording indicator
            if recordingModel.isRecording {
                VStack {
                    HStack {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 10, height: 10)
                        Text("Recording")
                            .foregroundColor(.white)
                    }
                    .padding(8)
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(20)
                    .padding(.top, 100)
                    Spacer()
                }
            }
        }
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
                recordedFramesData.removeAll()
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
        // Create RecordingData with the collected frames
        let recordingData = RecordingData(
            id: UUID().uuidString,
            timestamp: Date(),
            frames: recordedFramesData
        )
        
        // Save video locally and update VideoStore
        VideoStore.shared.addVideo(
            Video(
                id: recordingData.id,
                title: "My Recording",
                creator: "You",
                thumbnailImage: recordingModel.thumbnailImage ?? UIImage(systemName: "video.fill")!,
                isUploaded: false,
                videoURL: recordingModel.recordedVideoURL,
                recordingData: recordingData
            )
        )
        print("Debug: Added new video to VideoStore with \(recordedFramesData.count) frames")
        dismiss()
    }
} 
