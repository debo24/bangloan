// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { WhiteListProvider } from "./provider/whiteList/WhiteListProvider.sol";

/**
 * @title Bangloan White List Provider implementation.
 * @author @pasviegas
 * @notice The deployable white list provider contract.
 */
contract BangloanWhiteListProvider is WhiteListProvider {
    constructor(address _owner) WhiteListProvider(_owner) { }
}
