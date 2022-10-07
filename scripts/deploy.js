const { ethers } = require('hardhat');
const hre = require('hardhat');
const infuraUrl = `http://127.0.0.1:8545/`;

// import abi from json file
const { abi } = require('../artifacts/contracts/BlackJack.sol/BlackJack.json');
const provider = new ethers.providers.JsonRpcProvider(infuraUrl);

async function main() {
  const { blackJack } = await deployContract();
  const [owner, otherAccount] = await ethers.getSigners();
  await getAdressBalance(owner.address);
  await getAdressBalance(blackJack.address);
  // await blackJack.startGame(ethers.utils.parseEther('0.12'));
  await blackJack.deposit({ value: ethers.utils.parseEther('10') });
  await blackJack.startGame(ethers.utils.parseEther('0.1'));
  let Cards = await blackJack.getCards();
  await blackJack.hit();
  Cards = await blackJack.getCards();
  console.log('Cards: ', Cards);
  await blackJack.hit();
  Cards = await blackJack.getCards();
  console.log('Cards: ', Cards);
  // do stand and get response of the tx
  // const tx = await blackJack.stand();
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
