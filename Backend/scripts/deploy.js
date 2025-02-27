import { ethers } from "hardhat";

async function main() {
    try {
        console.log("Deploying CraftAgent contract...");
        
        const CraftAgent = await ethers.getContractFactory("CraftAgent");
        const craftAgent = await CraftAgent.deploy();
        
        console.log("Waiting for deployment...");
        await craftAgent.waitForDeployment();
        
        const address = await craftAgent.getAddress();
        console.log("CraftAgent deployed to:", address);
        
        // Optional: Verify on Etherscan
        console.log("Verifying contract on Basescan...");
        await run("verify:verify", {
            address: address,
            constructorArguments: []
        });
        
    } catch (error) {
        console.error("Deployment failed:", error);
        process.exit(1);
    }
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    }); 