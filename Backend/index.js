import { SecretVaultWrapper } from 'nillion-sv-wrappers';
import { v4 as uuidv4 } from 'uuid';
import { orgConfig } from './nillionOrgConfig.js';

const SCHEMA_ID = '7a37fe2b-0f1d-42c7-abb5-afd41890a0af';

// testthis sample paylaod
const data = [ 
    {
        wallet_address: "0x123456789",
        video_cid: "QmTest123",
        recording_data: {
            $allot: {
                id: "test-recording-1",
                timestamp: new Date().toISOString(),
                frames: [{
                    timestamp: 1.5,
                    features: {
                        "pose_quality": {
                            value: 0.95,
                            stringValue: "excellent"
                        }
                    },
                    landmarks: [{
                        location: {
                            x: 0.5,
                            y: 0.5,
                            cameraAspectY: 1.0,
                            z: 0.1,
                            visibility: 1.0,
                            presence: 1.0
                        },
                        type: "body"
                    }]
                }]
            }
        }
    }
];

async function main() {
    try {        
        const collection = new SecretVaultWrapper(
            orgConfig.nodes,
            orgConfig.orgCredentials,
            SCHEMA_ID
        );
        await collection.init();
        
        const dataWritten = await collection.writeToNodes(data);
        console.log(
            '👀 Data written to nodes:',
            JSON.stringify(dataWritten, null, 2)
        );
        
        const newIds = [
            ...new Set(dataWritten.map((item) => item.result.data.created).flat()),
        ];
        console.log('uploaded record ids:', newIds);

        // Test retrieving the data by wallet address
        const queryResult = await collection.readFromNodes({
            wallet_address: "0x123456789"
        });
        console.log('📥 Retrieved data by wallet:', queryResult);

        // Test retrieving the data by video CID
        const videoResult = await collection.readFromNodes({
            video_cid: "QmTest123"
        });
        console.log('📥 Retrieved data by CID:', videoResult);

    } catch (error) {
        console.error('❌ SecretVaultWrapper error:', error.message);
        process.exit(1);
    }
}

main();