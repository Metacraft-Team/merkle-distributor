import { HardhatRuntimeEnvironment } from 'hardhat/types';
import { ethers, network } from 'hardhat';
import { DeployFunction } from 'hardhat-deploy/types';
const TEST_MONEY = ethers.utils.parseEther('100000');
const DECIMALS = ethers.utils.parseEther('1');


const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
    const { deployments, getNamedAccounts } = hre;
    const { deploy } = deployments;

    const { deployer } = await getNamedAccounts();
    console.log(deployer)


    const isOracleNew = (await deploy('MerkleDistributor', {
        from: deployer,
        args: ['0x1fe4549be478cc1af80780fc09cb768475822ca88620eb584119767377b7b00d'],
    })).newlyDeployed;
    
};
export default func;
func.tags = ["merkle"]