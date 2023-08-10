//SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import { BangloanFixedYieldVaultWithUpside } from "./BangloanFixedYieldVaultWithUpside.sol";
import { VaultFactory } from "./factory/VaultFactory.sol";

contract BangloanUpsideVaultFactory is VaultFactory {
    /// @notice Event to emit when a new vault is created
    event VaultDeployed(
        address indexed vault, BangloanFixedYieldVaultWithUpside.UpsideVaultParams params, string options
    );

    /**
     * @param owner - The owner of the factory contract
     * @param operator - The operator of the factory contract
     * @param custodians - The custodians allowable for the vaults
     */
    constructor(address owner, address operator, address[] memory custodians)
        VaultFactory(owner, operator, custodians)
    { }

    /**
     * @notice - Function to create a new upside vault. Should be called only by the owner
     * @param params - The VaultParams
     * @param options - A JSON string that contains additional info about vault (Off-chain use case)
     */
    function createVault(BangloanFixedYieldVaultWithUpside.UpsideVaultParams memory params, string memory options)
        public
        onlyRole(OPERATOR_ROLE)
        onlyAllowedCustodians(params.fixedYieldVault.maturityVault.vault.custodian)
        returns (address)
    {
        BangloanFixedYieldVaultWithUpside newVault = new BangloanFixedYieldVaultWithUpside(params);

        emit VaultDeployed(address(newVault), params, options);

        _addVault(address(newVault));

        return address(newVault);
    }
}
