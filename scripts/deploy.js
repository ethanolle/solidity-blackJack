const { ethers } = require('hardhat');

const infuraUrl = `http://127.0.0.1:8545/`;

// import abi from json file
const { abi } = require('../artifacts/contracts/BlackJack.sol/BlackJack.json');
const provider = new ethers.providers.JsonRpcProvider(infuraUrl);
const hre = require('hardhat');

async function main() {
  const { blackJack } = await deployContract();
  const [owner, otherAccount] = await ethers.getSigners();
  await getAdressBalance(owner.address);
  await getAdressBalance(blackJack.address);
  // await blackJack.startGame(ethers.utils.parseEther('0.12'));
  await blackJack.deposit({ value: ethers.utils.parseEther('10') });
  await blackJack.startGame(ethers.utils.parseEther('0.1'));
  const info = await blackJack.getPlayerGameInfo();
  console.log('info: ', info);
  const playerBalance = await blackJack.getPlayerBalance();
  console.log('Player Balance: ', ethers.utils.formatEther(playerBalance));
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

async function deployContract() {
  const BlackJack = await hre.ethers.getContractFactory('BlackJack');
  const blackJack = await BlackJack.deploy();
  await blackJack.deployed();
  return { blackJack };
}

async function getAdressBalance(address) {
  const balance = await ethers.provider.getBalance(address);
  console.log('Balance: ', ethers.utils.formatEther(balance));
  return balance;
}
