import Foundation

enum CameraError: Error {
    case deviceNotFound
    case inputError
    case outputError
    
    var description: String {
        switch self {
        case .deviceNotFound:
            return "Camera device not found"
        case .inputError:
            return "Failed to setup camera input"
        case .outputError:
            return "Failed to setup camera output"
        }
    }
} 