import { loadFixture, mine } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import hre from "hardhat";

const contracts = {
  avatar: "MockAvatar",
  swapOwnerModule: "SwapOwnerModule",
  delay: "Delay",
};

describe("DelayModifier", async () => {
  const cooldown = 180;
  const expiration = 180 * 1000;

  async function setup() {
    const Avatar = await hre.ethers.getContractFactory(contracts.avatar);
    const avatar = await Avatar.deploy();
    const avatarAddress = await avatar.getAddress();

    const Modifier = await hre.ethers.getContractFactory(contracts.delay);
    const modifier = await Modifier.deploy(
      avatarAddress,
      avatarAddress,
      avatarAddress,
      cooldown,
      expiration
    );

    const Module = await hre.ethers.getContractFactory(
      contracts.swapOwnerModule
    );
    const module = await Module.deploy(
      modifier.address,
      avatarAddress,
      avatarAddress
    );

    return { avatar, modifier, module };
  }

  describe("setUp()", async () => {});
});
