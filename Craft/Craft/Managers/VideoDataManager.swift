//
//  VideoDataManager.swift
import Foundation

class VideoDataManager {
    private let baseURL = "http://192.168.105.23:3000/api/v1"
    
    init() {
        // No initialization needed
    }
    
    func checkServerConnection() async throws -> Bool {
        print("Checking server connection...")
        print("Connecting to:", baseURL)
        
        let url = URL(string: "\(baseURL)/health")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 5
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Error: Response is not HTTP")
                return false
            }
            
            if httpResponse.statusCode == 200,
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let status = json["status"] as? String,
               status == "ok" {
                print("Successfully connected to server")
                return true
            }
            
            print("Server returned invalid status code:", httpResponse.statusCode)
            return false
        } catch {
            print("Server connection failed:", error.localizedDescription)
            return false
        }
    }
    
    func uploadVideoData(walletAddress: String, videoCID: String, recordingData: RecordingData) async throws {
        print("Starting video data upload:")
        print("- Wallet:", walletAddress)
        print("- Video CID:", videoCID)
        print("- Recording frames:", recordingData.frames.count)
        
        let url = URL(string: "\(baseURL)/data/create")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Prepare the upload payload
        let payload: [String: Any] = [
            "wallet_address": walletAddress,
            "video_cid": videoCID,
            "recording_data": try recordingData.toJSON()
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NSError(domain: "UploadError", code: -1,
                            userInfo: [NSLocalizedDescriptionKey: "Invalid response type"])
            }
            
            if httpResponse.statusCode != 200 {
                throw NSError(domain: "UploadError", code: httpResponse.statusCode,
                            userInfo: [NSLocalizedDescriptionKey: "Upload failed with status \(httpResponse.statusCode)"])
            }
            
            guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let success = json["success"] as? Bool, success else {
                throw NSError(domain: "UploadError", code: -1,
                            userInfo: [NSLocalizedDescriptionKey: "Server returned error"])
            }
            
            print("Upload completed successfully")
        } catch {
            print("Upload failed with error:", error)
            print("Error details:", error.localizedDescription)
            throw error
        }
    }
    
    func fetchVideoData(videoCID: String) async throws -> RecordingData? {
        let url = URL(string: "\(baseURL)/data/query?video_cid=\(videoCID)")!
        let request = URLRequest(url: url)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NSError(domain: "APIError", code: -1,
                         userInfo: [NSLocalizedDescriptionKey: "Fetch failed"])
        }
        
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let success = json["success"] as? Bool,
              success,
              let responseData = json["data"] as? [String: Any] else {
            return nil
        }
        
        return try RecordingData.fromJSON(responseData)
    }
    
    func fetchVideosForWallet(walletAddress: String) async throws -> [RecordingData] {
        let url = URL(string: "\(baseURL)/data/query?wallet_address=\(walletAddress)")!
        let request = URLRequest(url: url)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NSError(domain: "APIError", code: -1,
                         userInfo: [NSLocalizedDescriptionKey: "Fetch failed"])
        }
        
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let success = json["success"] as? Bool,
              success,
              let responseData = json["data"] as? [[String: Any]] else {
            return []
        }
        
        return try responseData.map { try RecordingData.fromJSON($0) }
    }
}
