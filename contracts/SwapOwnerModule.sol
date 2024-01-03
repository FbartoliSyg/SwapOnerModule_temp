// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Module, Enum} from "@gnosis.pm/zodiac/contracts/core/Module.sol";

interface IOwnerManager {
    function swapOwner(
        address prevOwner,
        address oldOwner,
        address newOwner
    ) external;
}

contract SwapOwnerModule is Module {
    event SwapOwnerSetup(
        address indexed initiator,
        address indexed owner,
        address indexed avatar,
        address target
    );

    /// @param avatar Address of the avatar (e.g. a Gnosis Safe) Avatars must expose an interface like IAvatar.sol.
    /// @param target Address of the contract that will call execTransactionFromModule function (Delay modifier)
    /// @param owner Address of the owner
    constructor(address target, address avatar, address owner) {
        bytes memory initParams = abi.encode(target, avatar, owner);
        setUp(initParams);
    }

    function setUp(bytes memory initializeParams) public override initializer {
        __Ownable_init(msg.sender);
        (address _target, address _avatar, address _owner) = abi.decode(
            initializeParams,
            (address, address, address)
        );
        require(_avatar != address(0), "Avatar can not be zero address");
        require(_target != address(0), "Target can not be zero address");
        require(_owner != address(0), "Owner can not be zero address");
        avatar = _avatar;
        target = _target;
        transferOwnership(_owner);

        emit SwapOwnerSetup(msg.sender, _target, _avatar, _owner);
        emit AvatarSet(address(0), _avatar);
        emit TargetSet(address(0), _target);
    }

    function startRecovery(
        address prevOwner,
        address oldOwners,
        address newOwners
    ) external onlyOwner {
        require(
            _swapOwner(prevOwner, oldOwners, newOwners),
            "Module transaction failed"
        );
    }

    function _swapOwner(
        address prevOwner,
        address oldOwner,
        address newOwner
    ) internal returns (bool) {
        return
            exec(
                target,
                0,
                abi.encodeCall(
                    IOwnerManager.swapOwner,
                    (prevOwner, oldOwner, newOwner)
                ),
                Enum.Operation.Call
            );
    }
}
