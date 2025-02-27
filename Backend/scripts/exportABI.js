import fs from 'fs';

// Read the compiled contract artifact
const artifact = JSON.parse(
    fs.readFileSync('./artifacts/contracts/CraftAgent.sol/CraftAgent.json')
);

// Create contracts directory if it doesn't exist
if (!fs.existsSync('./contracts')) {
    fs.mkdirSync('./contracts');
}

// Write just the ABI to our contracts folder
fs.writeFileSync(
    './contracts/CraftAgent.json',
    JSON.stringify(artifact.abi, null, 2)
);

console.log('ABI exported successfully'); 