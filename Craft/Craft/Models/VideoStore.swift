import SwiftUI

class VideoStore: ObservableObject {
    static let shared = VideoStore()
    
    @Published private(set) var videos: [Video] = Video.mockVideos
    
    func addVideo(_ video: Video) {
        videos.insert(video, at: 0) // Add new videos at the beginning
        objectWillChange.send()
    }
    
    func updateVideo(_ video: Video) {
        if let index = videos.firstIndex(where: { $0.id == video.id }) {
            videos[index] = video
            objectWillChange.send()
        }
    }
} 