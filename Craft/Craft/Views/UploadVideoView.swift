import SwiftUI
import QuickPoseSwiftUI
import QuickPoseCore

struct UploadVideoView: View {
    @State private var title = ""
    @State private var isShowingRecorder = false
    @State private var isUploading = false
    @State private var uploadProgress = 0.0
    @State private var hasRecordedVideo = false
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Add title", text: $title)
                }
                
                Section {
                    Button(action: {
                        isShowingRecorder = true
                    }) {
                        HStack {
                            Image(systemName: "video.circle.fill")
                                .foregroundColor(.black)
                            Text("Record Video")
                                .foregroundColor(.black)
                        }
                    }
                }
                
                if hasRecordedVideo {
                    Section {
                        Button(action: {
                            mockUploadProcess()
                        }) {
                            HStack {
                                Spacer()
                                Text("Upload")
                                    .foregroundColor(.black)
                                    .bold()
                                Spacer()
                            }
                        }
                        .disabled(title.isEmpty)
                    }
                }
            }
            .navigationTitle("Create Content")
            .tint(.black)
            .fullScreenCover(isPresented: $isShowingRecorder) {
                RecordingView()
                    .onDisappear {
                        if !VideoStore.shared.videos.isEmpty {
                            hasRecordedVideo = true
                        }
                    }
            }
            .overlay {
                if isUploading {
                    UploadingOverlay(progress: $uploadProgress)
                }
            }
        }
    }
    
    private func mockUploadProcess() {
        // Dismiss keyboard
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        
        isUploading = true
        uploadProgress = 0.0
        
        // Update the last recorded video's title and status
        if var lastVideo = VideoStore.shared.videos.first {
            lastVideo.title = title
            lastVideo.isUploaded = true
            VideoStore.shared.updateVideo(lastVideo)
            print("Debug: Updated video - Title: \(lastVideo.title), Uploaded: \(lastVideo.isUploaded)")
        }
        
        // Simulate upload process
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            uploadProgress += 0.05
            if uploadProgress >= 1.0 {
                timer.invalidate()
                isUploading = false
                // Reset form
                title = ""
                hasRecordedVideo = false
            }
        }
    }
}

struct UploadingOverlay: View {
    @Binding var progress: Double
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                ProgressView("Uploading to IPFS...", value: progress, total: 1.0)
                    .progressViewStyle(.linear)
                    .tint(.black)
                    .foregroundColor(.white)
                
                Text("\(Int(progress * 100))%")
                    .foregroundColor(.white)
                    .font(.headline)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .padding(.horizontal, 40)
        }
    }
} 

