import { mockIPFS } from '../services/mockIPFS.js';

export const pinata = mockIPFS;

export const uploadToIPFS = async (file, metadata) => {
    try {
        const result = await pinata.uploadFile(file, {
            pinataMetadata: {
                name: metadata.title,
                keyvalues: {
                    title: metadata.title,
                    tags: metadata.tags.join(','),
                    creator: metadata.creator
                }
            }
        });
        return result.IpfsHash;
    } catch (error) {
        console.error('IPFS upload failed:', error);
        throw error;
    }
};

export const searchIPFS = async (query) => {
    try {
        const results = await pinata.searchFiles({
            metadata: {
                keyvalues: {
                    title: {
                        value: query,
                        op: 'ilike'
                    }
                }
            }
        });
        return results.rows;
    } catch (error) {
        console.error('IPFS search failed:', error);
        throw error;
    }
}; 