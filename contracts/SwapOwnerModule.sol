// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@gnosis.pm/zodiac/contracts/core/Module.sol";

interface IOwnerManager {
    function swapOwner(
        address prevOwner,
        address oldOwner,
        address newOwner
    ) external;
     function getThreshold() external view returns (uint256);
}

contract SwapOwnerModule is Module {
    constructor() {
        _disableInitializers();
    }

    function setUp(bytes memory initializeParams) public initializer {
        (address avatar, address target) = abi.decode(
            initializeParams,
            (address)
        );
        __Ownable_init();
        setAvatar(avatar);
        setTarget(target);
        transferOwnership(address(0));
    }

    function startRecovery(address oldOwners, address newOwners) external {
        require(_swapOwner(address(0x1), oldOwners, newOwners), 'Module transaction failed');
    }
    

    function _swapOwner(
        address prevOwner,
        address oldOwner,
        address newOwner
    ) internal return (bool) {
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