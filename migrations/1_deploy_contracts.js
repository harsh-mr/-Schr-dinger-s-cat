const fs = require('fs');
const path = require('path');

const DataProvidersNFTs = artifacts.require("DataProvidersNFTs");
const DataAnalystsNFTs = artifacts.require("DataAnalystsNFTs");
const VerifierProvenance = artifacts.require("VerifierProvenance");
const SchrodingerProtocol = artifacts.require("SchrodingerProtocol");

module.exports = async function(deployer, network){
    // Skip if we're testing
    if (network === 'test') return;

    const deployedAddresses = {};
    
    await deployer.deploy(DataProvidersNFTs);
    deployedAddresses.DataProvidersNFTs = DataProvidersNFTs.address;
    
    await deployer.deploy(DataAnalystsNFTs, DataProvidersNFTs.address);
    deployedAddresses.DataAnalystsNFTs = DataAnalystsNFTs.address;
    
    await deployer.deploy(VerifierProvenance);
    deployedAddresses.VerifierProvenance = VerifierProvenance.address;
    
    await deployer.deploy(
        SchrodingerProtocol,
        DataProvidersNFTs.address,
        DataAnalystsNFTs.address,
        VerifierProvenance.address,
    );
    deployedAddresses.SchrodingerProtocol = SchrodingerProtocol.address;

    // Save deployed addresses
    const deploymentsPath = path.join(__dirname, '../build/deployed-addresses.json');
    let deployments = {};
    
    if (fs.existsSync(deploymentsPath)) {
        deployments = JSON.parse(fs.readFileSync(deploymentsPath));
    }
    
    deployments[network] = deployedAddresses;
    
    fs.writeFileSync(
        deploymentsPath,
        JSON.stringify(deployments, null, 2)
    );
};