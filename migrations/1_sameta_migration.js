const Sameta = artifacts.require("SametaAvtarV1");
const { deployProxy } = require('@openzeppelin/truffle-upgrades');

module.exports = async function (deployer) {
  const instance = await deployProxy(Sameta, ["SAMETA AVTAR", "SAMETA"], { deployer, initializer: '__SametaAvtarV1_init' });
  console.log('Deployed Proxy Address', instance.address);
};
