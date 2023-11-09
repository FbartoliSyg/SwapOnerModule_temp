// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@gnosis.pm/zodiac/contracts/core/Module.sol";

interface IOwnerManager {
    function swapOwner(
        address prevOwner,
        address oldOwner,
        address newOwner
    ) external;
}

contract SwapOwnerModule is Module {
    constructor(address target, address avatar, address owner) {
        bytes memory initParams = abi.encode(
            target,
            avatar,
            owner
        );
        setUp(initParams);
    }

    function setUp(bytes memory initializeParams) public override initializer {
        (address target, address avatar, address owner) = abi.decode(
            initializeParams,
            (address,address, address)
        );
        __Ownable_init();
        setAvatar(avatar);
        setTarget(target);
        transferOwnership(owner);
    }

    function startRecovery(address oldOwners, address newOwners) external onlyOwner {
        require(_swapOwner(address(0x1), oldOwners, newOwners), 'Module transaction failed');
    }



    function _swapOwner(
        address prevOwner,
        address oldOwner,
        address newOwner
    ) internal returns (bool) {
        return exec(
            avatar,
            0,
            abi.encodeCall(
                IOwnerManager.swapOwner,
                (prevOwner, oldOwner, newOwner)
            ),
            Enum.Operation.Call
        );
    }
}
