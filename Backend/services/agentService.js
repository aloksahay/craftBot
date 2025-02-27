import { ethers } from 'ethers';
import { pinata, searchIPFS } from '../config/ipfsConfig.js';
import { readFile } from 'fs/promises';

// Load ABI dynamically
const craftAgentABI = JSON.parse(
    await readFile(new URL('../contracts/CraftAgent.json', import.meta.url))
);

export class CraftAgentService {
    constructor(contractAddress, provider) {
        this.contract = new ethers.Contract(
            contractAddress,
            craftAgentABI,
            provider
        );
    }

    async handleUserQuery(query, userAddress) {
        try {
            // Check subscription status
            const hasPremium = await this.contract.hasActiveSubscription(userAddress);
            
            // Search for relevant content
            const relevantContent = await this.findRelevantContent(query);

            // Format response
            const response = {
                content: relevantContent.map(content => ({
                    title: content.title,
                    videoCID: content.videoCID,
                    modelAccess: hasPremium ? content.modelCID : null,
                    creator: content.creator
                })),
                isPremium: hasPremium,
                agentResponse: this.generateResponse(query, relevantContent, hasPremium)
            };

            return response;
        } catch (error) {
            console.error('Agent query failed:', error);
            throw error;
        }
    }

    async findRelevantContent(query) {
        // Search IPFS content
        const ipfsResults = await searchIPFS(query);
        
        // Get content details from smart contract
        const contentDetails = await Promise.all(
            ipfsResults.map(async (result) => {
                const contentId = await this.contract.getContentIdByCID(result.ipfsHash);
                const content = await this.contract.contents(contentId);
                return {
                    ...content,
                    ipfsHash: result.ipfsHash,
                    metadata: result.metadata
                };
            })
        );

        return contentDetails;
    }

    generateResponse(query, content, isPremium) {
        const contentSummary = content.map(item => 
            `- ${item.title} by ${item.creator}`
        ).join('\n');

        const premiumMessage = isPremium ? 
            "As a premium member, you have access to AI models for each tutorial." :
            "Upgrade to premium to access AI models and enhance your learning experience.";

        return `
Here are some relevant tutorials for "${query}":

${contentSummary}

${premiumMessage}

How can I help you get started with these tutorials?`;
    }
} 