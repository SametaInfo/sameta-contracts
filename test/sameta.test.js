const Sameta = artifacts.require("SametaAvtarV1");
//const assert = require("assert");
let sameta;

beforeEach(async () => {
  sameta = await Sameta.deployed();
});

contract("SAMETA TEST", function (accounts) {
  it("should return public data", async () => {
    const name = await sameta.name();
    const symbol = await sameta.symbol();
    const issuer = await sameta.ISSUER();
    assert.strictEqual(name, "SAMETA AVTAR", "name error");
    assert.strictEqual(symbol, "SAMETA", "symbol error");
    assert.strictEqual(
      issuer,
      "0x76afa8a5929fef1b4c03674b2152ae5aaad1d974b8a4021c59477bcc846ccc1e",
      "ISSUER hash error"
    );
    return;
  });
  it("should allow ISSUER to mint new NFT", async () => {
    const newToken = await sameta.createItem(
      "https://ipfs.moralis.io:2053/ipfs/QmZXgEc6rLddGGDHisNur9jKzebBbcJkWFmDV5tsibWHZg",
      accounts[1]
    );
    const from = newToken.logs[0].args["from"];
    const to = newToken.logs[0].args["to"];
    const tokenId = newToken.logs[0].args["tokenId"];
    assert.strictEqual(from, "0x0000000000000000000000000000000000000000"); //0x address
    assert.strictEqual(to, accounts[1]);
    assert.strictEqual("1", tokenId.toString());
    return;
  });
  it("should fail if minted by anyone other than ISSUER", async () => {
    try {
      await sameta.createItem(
        "https://ipfs.moralis.io:2053/ipfs/QmZXgEc6rLddGGDHisNur9jKzebBbcJkWFmDV5tsibWHZg",
        "0x7Adb261Bea663ee06E4ff0a657E65aE91aC7167f",
        { from: accounts[1] }
      );
      assert.fail(
        "TEST: 'should fail if minted by anyone other than ISSUER' Failed"
      );
    } catch (error) {
      assert.strictEqual(
        error.message,
        "VM Exception while processing transaction: revert -- Reason given: Custom error (could not decode)."
      );
    }
    return;
  });
  it("should fail if transferd by anyone other than ISSUER", async () => {
    try {
      await sameta.transferFrom(accounts[1], accounts[2], 1, {
        from: accounts[1],
      });
      assert.fail(
        "TEST: 'should fail if transferd by anyone other than ISSUER' Failed"
      );
    } catch (error) {
      assert.strictEqual(
        error.message,
        "VM Exception while processing transaction: revert Sameta_Avtar: transfer restricted to ISSUER -- Reason given: Sameta_Avtar: transfer restricted to ISSUER."
      );
    }
  });
  it("allows owner to lift transfer restriction", async () => {
    await sameta.updateTransferRestriction(false);
    const value = await sameta.transferRestricted();
    assert.strictEqual(value, false);
  });
  it("Allows token transfer if no transfer restriction", async () => {
    const tokenOwnerBefore = await sameta.ownerOf(1);
    await sameta.transferFrom(accounts[1], accounts[2], 1, {
      from: accounts[1],
    });
    const tokenOwnerAfter = await sameta.ownerOf(1);
    assert.strictEqual(
      tokenOwnerBefore,
      accounts[1],
      "tokenOwnerBefore failed"
    );
    assert.strictEqual(tokenOwnerAfter, accounts[2], "tokenOwnerAfter failed");
  });
});
