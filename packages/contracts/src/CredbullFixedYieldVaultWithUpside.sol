// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { UpsideVault } from "./vault/UpsideVault.sol";

contract BangloanFixedYieldVaultWithUpside is UpsideVault {
    constructor(BangloanFixedYieldVaultWithUpside.UpsideVaultParams memory params) UpsideVault(params) { }
}
