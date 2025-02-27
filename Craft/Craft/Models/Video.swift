import Foundation
import UIKit

struct Video: Identifiable {
    let id: String
    var title: String
    let creator: String
    let thumbnailImage: UIImage
    var isUploaded: Bool = false
    let videoURL: URL?  // Store the URL of the recorded video
    let recordingData: RecordingData?  // Store the QuickPose tracking data
    
    init(id: String, title: String, creator: String, thumbnailImage: UIImage, isUploaded: Bool = false, videoURL: URL?, recordingData: RecordingData? = nil) {
        self.id = id
        self.title = title
        self.creator = creator
        self.thumbnailImage = thumbnailImage
        self.isUploaded = isUploaded
        self.videoURL = videoURL
        self.recordingData = recordingData
    }
}

// Mock data
extension Video {
    static let mockVideos: [Video] = []
} 
