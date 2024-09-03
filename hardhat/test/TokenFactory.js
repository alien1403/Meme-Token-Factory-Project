const { expect } = require("chai");
const hre = require("hardhat");
const { time } = require("@nomicfoundation/hardhat-toolbox/network-helpers");

describe("Token Factory", function () {
  it("Should create the meme token successfully", async function () {
    const tokenCt = await hre.ethers.deployContract("TokenFactory");
    const tx = await tokenCt.createMemeToken(
      "Test",
      "TEST",
      "img://img.png",
      "hello there",
      {
        value: hre.ethers.parseEther("0.0001"),
      }
    );
  });

  it("Should allow a user to purchase the meme token", async function () {
    const tokenCt = await hre.ethers.deployContract("TokenFactory");
    const tx1 = await tokenCt.createMemeToken(
      "Test",
      "TEST",
      "img://img.png",
      "hello there",
      {
        value: hre.ethers.parseEther("0.0001"),
      }
    );
    const memeTokenAddress = await tokenCt.memeTokenAddresses(0);
    const tx2 = await tokenCt.buyMemeToken(memeTokenAddress, 800000, {
      value: hre.ethers.parseEther("24"),
    });
  });
});
