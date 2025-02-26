import Foundation

// MARK: - Error Types
enum NillionError: LocalizedError {
    case invalidResponse
    case httpError(statusCode: Int)
    case serverError(message: String)
    case notInitialized
    case encodingError
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(statusCode: let code):
            return "HTTP error with status code: \(code)"
        case .serverError(message: let msg):
            return "Server error: \(msg)"
        case .notInitialized:
            return "NillionWrapper not initialized. Call initialize() first"
        case .encodingError:
            return "Error encoding RecordingData to JSON"
        }
    }
}

class NillionWrapper {
    private let baseURL: String
    private let session: URLSession
    private let orgCredentials: NillionConfig.OrgCredentials
    private let nodes: [NillionConfig.Node]
    private var isInitialized: Bool = false
    
    init(baseURL: String = "http://192.168.1.112:3000") {
        self.baseURL = baseURL
        self.orgCredentials = NillionConfig.orgCredentials
        self.nodes = NillionConfig.nodes
        let config = URLSessionConfiguration.default
        self.session = URLSession(configuration: config)
    }
    
    func initialize() async throws {
        isInitialized = true
    }
    
    func encrypt(_ data: RecordingData) async throws -> String {
        guard isInitialized else {
            print("Error: NillionWrapper not initialized")
            throw NillionError.notInitialized
        }
        
        print("Starting encryption process")
        print("- Data ID:", data.id)
        print("- Frames count:", data.frames.count)
        
        do {
            // First encode the RecordingData to a JSON string
            let jsonData = try JSONEncoder().encode(data)
            guard let jsonString = String(data: jsonData, encoding: .utf8) else {
                print("Error: Failed to encode data to JSON string")
                throw NillionError.encodingError
            }
            
            print("Data encoded successfully")
            print("- JSON size:", jsonData.count, "bytes")
            
            // Then create the allot structure with the JSON string
            let allotData = [
                "recording_data": [
                    "$share": jsonString
                ]
            ]
            
            print("Preparing to encrypt with Nillion")
            return try await prepareAndAllot(allotData)
            
        } catch {
            print("Encryption failed:")
            print("- Error:", error)
            print("- Description:", error.localizedDescription)
            throw error
        }
    }
    
    func decrypt(_ shares: String) async throws -> RecordingData {
        // Use Nillion SDK to decrypt
        let unifiedData = try await unify(shares)
        return try JSONDecoder().decode(RecordingData.self, from: unifiedData)
    }
    
    // Upload recording data to Nillion vault
    func uploadRecording(walletAddress: String, videoCID: String, recordingData: RecordingData) async throws -> Bool {
        let url = URL(string: "\(baseURL)/api/v1/data/create")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        print("Preparing to upload recording data:")
        print("- Frames:", recordingData.frames.count)
        
        // Create the upload record
        let uploadRecord = UploadVideoRecord(
            recordingData: recordingData,
            walletAddress: walletAddress,
            videoCID: videoCID
        )
        
        // Encode the entire record
        request.httpBody = try JSONEncoder().encode(uploadRecord)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NillionError.invalidResponse
        }
        
        if httpResponse.statusCode != 200 {
            if let errorJson = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                print("Server errors:", errorJson.errors ?? [])
                throw NillionError.serverError(message: errorJson.errors?.first?.message ?? "Unknown error")
            }
            throw NillionError.httpError(statusCode: httpResponse.statusCode)
        }
        
        let result = try JSONDecoder().decode(UploadResponse.self, from: data)
        if let uploadResult = result.data {
            print("Upload completed successfully:")
            print("- Total chunks:", uploadResult.total_chunks)
            print("- Processed chunks:", uploadResult.chunks)
            return uploadResult.results.allSatisfy { $0.result.isSuccess }
        }
        return false
    }
    
    // Fetch recording data from Nillion vault
    func fetchRecording(walletAddress: String? = nil, videoCID: String? = nil) async throws -> [RecordingData] {
        var components = URLComponents(string: "\(baseURL)/api/v1/data/query")!
        
        var queryItems: [URLQueryItem] = []
        if let walletAddress = walletAddress {
            queryItems.append(URLQueryItem(name: "wallet_address", value: walletAddress))
        }
        if let videoCID = videoCID {
            queryItems.append(URLQueryItem(name: "video_cid", value: videoCID))
        }
        components.queryItems = queryItems
        
        let request = URLRequest(url: components.url!)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NillionError.invalidResponse
        }
        
        if httpResponse.statusCode != 200 {
            throw NillionError.httpError(statusCode: httpResponse.statusCode)
        }
        
        let result = try JSONDecoder().decode(FetchResponse.self, from: data)
        return result.data
    }
    
    private func generateSecretKey() async throws -> Any {
        // TODO: Implement with actual Nillion SDK
        // This should generate a secret key using the Nillion SDK
        // For now, returning a placeholder
        throw NSError(domain: "NillionError", code: -1,
                     userInfo: [NSLocalizedDescriptionKey: "Nillion SDK integration pending"])
    }
    
    private func prepareAndAllot(_ data: [String: Any]) async throws -> String {
        // Real implementation using Nillion SDK
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: data)
            
            // For now, we'll just send the raw JSON data since we're using the backend for actual encryption
            // The backend will handle the actual Nillion encryption
            return String(data: jsonData, encoding: .utf8) ?? ""
        } catch {
            print("PrepareAndAllot failed:")
            print("- Error:", error)
            throw error
        }
    }
    
    private func unify(_ shares: String) async throws -> Data {
        // For now, since actual decryption happens on the backend,
        // we'll just convert the string back to Data
        guard let data = shares.data(using: .utf8) else {
            throw NillionError.encodingError
        }
        return data
    }
}
