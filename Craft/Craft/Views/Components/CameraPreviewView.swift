import UIKit
import SwiftUI
import AVFoundation

class CameraPreview: UIView {
    var previewLayer: AVCaptureVideoPreviewLayer {
        layer as! AVCaptureVideoPreviewLayer
    }
    
    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }
}

struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession?
    
    func makeUIView(context: Context) -> CameraPreview {
        let view = CameraPreview()
        view.previewLayer.session = session
        view.previewLayer.videoGravity = .resizeAspectFill
        return view
    }
    
    func updateUIView(_ uiView: CameraPreview, context: Context) {}
} 

