import SwiftUI
import QuickPoseCore
import QuickPoseSwiftUI
import Foundation
import AVFoundation
import UIKit

struct RecordingData: Codable {
    let id: String
    let timestamp: Date
    let frames: [FrameData]
    
    enum CodingKeys: String, CodingKey {
        case id
        case timestamp
        case frames
    }
    
    func toJSON() throws -> [String: Any] {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(self)
        guard let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw NSError(domain: "JSONError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert to dictionary"])
        }
        return dict
    }
    
    static func fromJSON(_ json: [String: Any]) throws -> RecordingData {
        let data = try JSONSerialization.data(withJSONObject: json)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(RecordingData.self, from: data)
    }
}

struct FrameData: Codable {
    let timestamp: TimeInterval
        
    struct Feature: Codable {
        let value: Double
        let stringValue: String
    }
    
    // Store the feature type as string and its result
    let features: [String: Feature]
    let landmarks: [Landmark]?
    
    init(timestamp: TimeInterval,
         features: [QuickPose.Feature: QuickPose.FeatureResult],
         landmarks: QuickPose.Landmarks?) {
        self.timestamp = timestamp
                
        var convertedFeatures: [String: Feature] = [:]
        for (key, value) in features {
            convertedFeatures[key.displayString] = Feature(
                value: value.value,
                stringValue: value.stringValue
            )
        }
        self.features = convertedFeatures
                
        if let landmarks = landmarks {
            self.landmarks = landmarks.allLandmarksForBody().map { point3d in
                Landmark(
                    location: Point3D(
                        x: point3d.x,
                        y: point3d.y,
                        cameraAspectY: point3d.cameraAspectY,
                        z: point3d.z,
                        visibility: point3d.visibility,
                        presence: point3d.presence
                    ),
                    type: "body"
                )
            }
        } else {
            self.landmarks = nil
        }
    }
}

struct Landmark: Codable {
    let location: Point3D
    let type: String
}

struct Point3D: Codable {
    let x: Double
    let y: Double
    let cameraAspectY: Double
    let z: Double
    let visibility: Double
    let presence: Double
}

class RecordingDataModel: NSObject, ObservableObject {
    @Published var isRecording = false
    @Published var isRecordingComplete = false
    @Published var recordedVideoURL: URL?
    @Published var thumbnailImage: UIImage?
    
    private let quickPose = QuickPose(sdkKey: CraftEnvironmentVariables.quickPoseSDKKey)
    private var captureSession: AVCaptureSession?
    private var movieFileOutput: AVCaptureMovieFileOutput?
    
    override init() {
        super.init()
        setupCaptureSession()
    }
    
    private func setupCaptureSession() {
        captureSession = AVCaptureSession()
        
        guard let captureSession = captureSession,
              let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            return
        }
        
        do {
            let videoInput = try AVCaptureDeviceInput(device: camera)
            if captureSession.canAddInput(videoInput) {
                captureSession.addInput(videoInput)
            }
            
            // Add audio input
            if let audioDevice = AVCaptureDevice.default(for: .audio),
               let audioInput = try? AVCaptureDeviceInput(device: audioDevice),
               captureSession.canAddInput(audioInput) {
                captureSession.addInput(audioInput)
            }
            
            movieFileOutput = AVCaptureMovieFileOutput()
            if let movieFileOutput = movieFileOutput,
               captureSession.canAddOutput(movieFileOutput) {
                captureSession.addOutput(movieFileOutput)
            }
            
            captureSession.startRunning()
        } catch {
            print("Error setting up capture session: \(error)")
        }
    }
    
    func startRecording() {
        guard let movieFileOutput = movieFileOutput else { return }
        
        isRecording = true
        
        let tempDir = FileManager.default.temporaryDirectory
        let videoURL = tempDir.appendingPathComponent("\(UUID().uuidString).mov")
        
        movieFileOutput.startRecording(to: videoURL, recordingDelegate: self)
    }
    
    func stopRecording() {
        movieFileOutput?.stopRecording()
    }
    
    private func generateThumbnail(from videoURL: URL) {
        let asset = AVAsset(url: videoURL)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        
        do {
            let cgImage = try imageGenerator.copyCGImage(at: .zero, actualTime: nil)
            thumbnailImage = UIImage(cgImage: cgImage)
        } catch {
            print("Failed to generate thumbnail: \(error)")
            thumbnailImage = UIImage(systemName: "video.fill")
        }
    }
}

extension RecordingDataModel: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        DispatchQueue.main.async {
            if error == nil {
                self.recordedVideoURL = outputFileURL
                self.generateThumbnail(from: outputFileURL)
            }
            self.isRecording = false
            self.isRecordingComplete = true
        }
    }
}
