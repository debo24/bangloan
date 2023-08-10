//SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import { FixedYieldVault } from "./vault/FixedYieldVault.sol";

contract BangloanFixedYieldVault is FixedYieldVault {
    constructor(FixedYieldVaultParams memory params) FixedYieldVault(params) { }
}
