import SwiftUI
import AVKit

struct VideoFeedView: View {
    @StateObject private var videoStore = VideoStore.shared
    
    var body: some View {
        ScrollView {
            LazyVStack {
                let uploadedVideos = videoStore.videos.filter { $0.isUploaded }                
                ForEach(uploadedVideos) { video in
                    VideoCard(video: video)
                }
            }
        }
    }
}

struct VideoCard: View {
    let video: Video
    @State private var isShowingVideo = false
    
    var body: some View {
        VStack(alignment: .leading) {
            Image(uiImage: video.thumbnailImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 200)
                .clipped()
                .onTapGesture {
                    isShowingVideo = true
                }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(video.title)
                    .font(.headline)
                Text(video.creator)
                    .font(.subheadline)
            }
            .padding()
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 5)
        .padding(.horizontal)
        .fullScreenCover(isPresented: $isShowingVideo) {
            VideoPlayerView(video: video)
        }
    }
}

struct VideoPlayerView: View {
    let video: Video
    @Environment(\.dismiss) private var dismiss
    @State private var player: AVPlayer?
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            if let player = player {
                VideoPlayer(player: player)
                    .edgesIgnoringSafeArea(.all)
            }
            
            // Close button
            VStack {
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding()
                    }
                }
                Spacer()
            }
        }
        .onAppear {
            if let videoURL = video.videoURL {
                player = AVPlayer(url: videoURL)
                player?.play()
            }
        }
        .onDisappear {
            player?.pause()
            player = nil
        }
    }
} 
