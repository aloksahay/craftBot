import { ethers } from 'ethers';
import { CraftAgentService } from '../services/agentService.js';
import dotenv from 'dotenv';
dotenv.config();

async function testAgent() {
    try {
        console.log('Initializing test...');
        
        // Initialize provider
        const provider = new ethers.JsonRpcProvider(process.env.BASE_TESTNET_RPC);
        
        // Initialize agent service
        const agentService = new CraftAgentService(
            process.env.CRAFT_AGENT_CONTRACT_ADDRESS,
            provider
        );

        // Test queries
        const testCases = [
            {
                query: "How do I tie a tie knot?",
                userAddress: "0x177E7baaC808C6608f4D32F9E360F67E1cCB5165"
            },
            {
                query: "Show me beginner cooking tutorials",
                userAddress: "0x177E7baaC808C6608f4D32F9E360F67E1cCB5165"
            }
        ];

        for (const test of testCases) {
            console.log('\n-----------------------------------');
            console.log(`Testing query: "${test.query}"`);
            console.log('-----------------------------------');
            
            const response = await agentService.handleUserQuery(test.query, test.userAddress);
            
            console.log('\nAgent Response:', response.agentResponse);
            console.log('\nRelevant Content:', response.content);
            console.log('\nSubscription Status:', response.isPremium ? 'Premium' : 'Free');
        }

    } catch (error) {
        console.error('Test failed:', error);
        console.error('Error details:', error.stack);
    }
}

testAgent()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    }); 