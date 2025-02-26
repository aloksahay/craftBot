import Foundation

// MARK: - Request Types
struct UploadVideoRecord: Codable {
    let _id: String
    let wallet_address: String
    let video_cid: String
    let chunk_index: Int
    let total_chunks: Int
    let recording_data: RecordingDataAllot
    
    struct RecordingDataAllot: Codable {
        let allot: String
        
        enum CodingKeys: String, CodingKey {
            case allot = "$allot"
        }
    }
    
    init(recordingData: RecordingData, walletAddress: String, videoCID: String, chunkIndex: Int = 0, totalChunks: Int = 1) {
        self._id = UUID().uuidString
        self.wallet_address = walletAddress
        self.video_cid = videoCID
        self.chunk_index = chunkIndex
        self.total_chunks = totalChunks
        
        // Encode the recording data to a string
        let jsonData = try! JSONEncoder().encode(recordingData)
        let jsonString = String(data: jsonData, encoding: .utf8)!
        self.recording_data = RecordingDataAllot(allot: jsonString)
    }
}

// MARK: - Response Types
struct UploadResponse: Codable {
    let success: Bool
    let data: ChunkUploadResult?
    let errors: [ErrorMessage]?
}

struct FetchResponse: Codable {
    let success: Bool
    let data: [RecordingData]
    let errors: [ErrorMessage]?
}

struct ChunkUploadResult: Codable {
    let chunks: Int
    let total_chunks: Int
    let results: [NodeResult]
}

struct NodeResult: Codable {
    let node: String
    let result: NodeResultData
}

struct NodeResultData: Codable {
    let data: NodeResultDataContent
    
    var isSuccess: Bool {
        return data.errors.isEmpty
    }
}

struct NodeResultDataContent: Codable {
    let created: [String]
    let errors: [String]
}

struct ErrorMessage: Codable {
    let message: String
}

struct ErrorResponse: Codable {
    let success: Bool
    let errors: [ErrorMessage]?
}
