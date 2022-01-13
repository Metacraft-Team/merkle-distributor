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
        args: ['0xa8a3d8b777c2f0bc7fbcc14a0ac529b4ab20b43ce0507047777219a936ceca3e'],
    })).newlyDeployed;
    
};
export default func;
func.tags = ["merkle"]