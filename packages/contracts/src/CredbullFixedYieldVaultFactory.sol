//SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import { BangloanFixedYieldVault } from "./BangloanFixedYieldVault.sol";
import { VaultFactory } from "./factory/VaultFactory.sol";

contract BangloanFixedYieldVaultFactory is VaultFactory {
    /// @notice Event to emit when a new vault is created
    event VaultDeployed(address indexed vault, BangloanFixedYieldVault.FixedYieldVaultParams params, string options);

    /**
     * @param owner - The owner of the factory contract
     * @param operator - The operator of the factory contract
     * @param custodians - The custodians allowable for the vaults
     */
    constructor(address owner, address operator, address[] memory custodians)
        VaultFactory(owner, operator, custodians)
    { }

    /**
     * @notice - Function to create a new vault. Should be called only by the owner
     * @param params - The VaultParams
     */
    function createVault(BangloanFixedYieldVault.FixedYieldVaultParams memory params, string memory options)
        public
        virtual
        onlyRole(OPERATOR_ROLE)
        onlyAllowedCustodians(params.maturityVault.vault.custodian)
        returns (address)
    {
        BangloanFixedYieldVault newVault = new BangloanFixedYieldVault(params);

        emit VaultDeployed(address(newVault), params, options);

        _addVault(address(newVault));

        return address(newVault);
    }
}
