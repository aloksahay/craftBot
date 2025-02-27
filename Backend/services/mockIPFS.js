// Mock IPFS service for development
class MockIPFSService {
    constructor() {
        this.files = new Map();
    }

    async uploadFile(file, metadata) {
        // Generate a mock CID
        const mockCID = 'Qm' + Math.random().toString(36).substring(2, 15);
        
        this.files.set(mockCID, {
            content: file,
            metadata,
            timestamp: new Date(),
        });

        return {
            IpfsHash: mockCID,
            timestamp: new Date().toISOString()
        };
    }

    async searchFiles(query) {
        // Mock search functionality
        const results = Array.from(this.files.entries())
            .filter(([_, file]) => {
                const title = file.metadata.title.toLowerCase();
                return title.includes(query.toLowerCase());
            })
            .map(([cid, file]) => ({
                ipfsHash: cid,
                metadata: file.metadata,
                timestamp: file.timestamp
            }));

        return { rows: results };
    }
}

export const mockIPFS = new MockIPFSService(); 