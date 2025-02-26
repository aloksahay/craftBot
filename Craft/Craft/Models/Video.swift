import Foundation
import UIKit

struct Video: Identifiable {
    let id: String
    var title: String
    let creator: String
    let thumbnailImage: UIImage
    var isUploaded: Bool = false
    let videoURL: URL?  // Store the URL of the recorded video
}

// Mock data
extension Video {
    static let mockVideos: [Video] = []
} 
