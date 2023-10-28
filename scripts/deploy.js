// scripts/deploy.js
async function main() {
    const Betting = await ethers.getContractFactory("Depositor");
    console.log("Deploying Depositor...");
    const betting = await upgrades.deployProxy(Betting, ["0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3","0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee"], { initializer: 'initialize' });
    console.log("Box deployed to:", betting.address);
  }
  
  main()
    .then(() => process.exit(0))
    .catch(error => {
      console.error(error);
      process.exit(1);
    });