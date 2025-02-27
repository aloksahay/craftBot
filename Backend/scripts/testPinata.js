import { uploadToIPFS } from '../config/ipfsConfig.js';
import fs from 'fs';

async function testPinataUpload() {
    try {
        // Create a test file
        const testData = {
            title: "Test Video",
            description: "How to tie a tie knot",
            timestamp: new Date().toISOString()
        };
        
        // Convert to Buffer since Pinata expects a Buffer or ReadStream
        const fileBuffer = Buffer.from(JSON.stringify(testData));
        
        const metadata = {
            title: "How to tie a tie knot",
            tags: ["tutorial", "fashion", "beginner"],
            creator: "0x177E7baaC808C6608f4D32F9E360F67E1cCB5165"
        };

        console.log('Uploading to IPFS...');
        const ipfsHash = await uploadToIPFS(fileBuffer, metadata);
        console.log('Upload successful! IPFS Hash:', ipfsHash);
        
        return ipfsHash;
    } catch (error) {
        console.error('Test failed:', error);
        throw error;
    }
}

testPinataUpload()
    .then(hash => console.log('Test completed successfully'))
    .catch(error => console.error('Test failed:', error)); 