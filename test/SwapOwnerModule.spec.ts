import { loadFixture, mine } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import hre from "hardhat";

const contracts = {
  avatar: "MockAvatar",
  swapOwnerModule: "SwapOwnerModule",
  delay: "Delay",
};

const ZeroState =
  '0x0000000000000000000000000000000000000000000000000000000000000000'
const ZeroAddress = '0x0000000000000000000000000000000000000000'
const FirstAddress = '0x0000000000000000000000000000000000000001'

describe("DelayModifier", async () => {
  const cooldown = 180;
  const expiration = 180 * 1000;

  async function setup() {
    const [admin] = await hre.ethers.getSigners()

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
      admin.address
    );

    return { avatar, modifier, module };
  }

  describe("setUp()", async () => {
    it('throws if avatar is zero address', async () => {
        const Module = await hre.ethers.getContractFactory(contracts.swapOwnerModule)
        await expect(
          Module.deploy(FirstAddress, ZeroAddress, FirstAddress)
        ).to.be.revertedWith('Avatar can not be zero address')
      })
  
      it('throws if target is zero address', async () => {
        const Module = await hre.ethers.getContractFactory(contracts.swapOwnerModule)
        await expect(
          Module.deploy(ZeroAddress, FirstAddress, FirstAddress)
        ).to.be.revertedWith('Target can not be zero address')
      })
      it('should emit event because of successful set up', async () => {
        const [user1] = await hre.ethers.getSigners()
        const Module = await hre.ethers.getContractFactory(contracts.swapOwnerModule)
        expect(
          await Module.deploy(user1.address, user1.address, user1.address)
        )
          .to.emit(Module, 'SwapOwnerSetup')
          .withArgs(user1.address, user1.address, user1.address)
      })
  });
});
