import SwiftUI
import PhotosUI
import AVKit

struct VideoPicker: UIViewControllerRepresentable {
    @Binding var videoURL: URL?
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .videos
        config.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: VideoPicker
        
        init(_ parent: VideoPicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            guard let provider = results.first?.itemProvider else { return }
            
            if provider.canLoadObject(ofClass: URL.self) {
                provider.loadObject(ofClass: URL.self) { url, error in
                    DispatchQueue.main.async {
                        if let videoURL = url as? URL {
                            self.parent.videoURL = videoURL
                        }
                    }
                }
            }
        }
    }
} 