//SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import { Script } from "forge-std/Script.sol";

import { HelperConfig, NetworkConfig } from "@script/HelperConfig.s.sol";

import { BangloanFixedYieldVaultFactory } from "@bangloan/BangloanFixedYieldVaultFactory.sol";
import { BangloanFixedYieldVault } from "@bangloan/BangloanFixedYieldVault.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { Vault } from "@bangloan/vault/Vault.sol";
import { MaturityVault } from "@bangloan/vault/MaturityVault.sol";
import { FixedYieldVault } from "@bangloan/vault/FixedYieldVault.sol";
import { WindowPlugin } from "@bangloan/plugin/WindowPlugin.sol";
import { WhiteListPlugin } from "@bangloan/plugin/WhiteListPlugin.sol";
import { MaxCapPlugin } from "@bangloan/plugin/MaxCapPlugin.sol";

import { console2 } from "forge-std/console2.sol";

contract DeployStakingVaults is Script {
    bool private isTestMode;

    function runTest()
        public
        returns (
            BangloanFixedYieldVaultFactory factory,
            BangloanFixedYieldVault stakingVault50APY_,
            BangloanFixedYieldVault stakingVault0APY_,
            HelperConfig helperConfig
        )
    {
        isTestMode = true;
        return run();
    }

    function run()
        public
        returns (
            BangloanFixedYieldVaultFactory factory,
            BangloanFixedYieldVault stakingVault50APY_,
            BangloanFixedYieldVault stakingVault0APY_,
            HelperConfig helperConfig
        )
    {
        helperConfig = new HelperConfig(isTestMode);

        vm.startBroadcast();

        BangloanFixedYieldVault stakingVault50APY = new BangloanFixedYieldVault(
            createStakingVaultParams(helperConfig, "inBangloan Earn CBL Staking Challenge", "iceCBLsc", 50)
        );
        console2.log(
            string.concat(
                "!!!!! Deploying BangloanFixedYieldVault 50APY [", vm.toString(address(stakingVault50APY)), "] !!!!!"
            )
        );

        BangloanFixedYieldVault stakingVault0APY = new BangloanFixedYieldVault(
            createStakingVaultParams(helperConfig, "inBangloan Earn CBL Booster Vault", "iceCBLBooster", 0)
        );
        console2.log(
            string.concat(
                "!!!!! Deploying BangloanFixedYieldVault OAPY [", vm.toString(address(stakingVault0APY)), "] !!!!!"
            )
        );

        vm.stopBroadcast();

        return (factory, stakingVault50APY, stakingVault0APY, helperConfig);
    }

    function createStakingVaultParams(
        HelperConfig helperConfig,
        string memory shareName,
        string memory shareSymbol,
        uint256 _yieldPercentage
    ) internal view returns (BangloanFixedYieldVault.FixedYieldVaultParams memory) {
        NetworkConfig memory config = helperConfig.getNetworkConfig();
        Vault.VaultParams memory _vaultParams = Vault.VaultParams({
            asset: IERC20(config.cblToken),
            shareName: shareName,
            shareSymbol: shareSymbol,
            custodian: config.factoryParams.custodian
        });

        MaturityVault.MaturityVaultParams memory _maturityVaultParams =
            MaturityVault.MaturityVaultParams({ vault: _vaultParams });

        FixedYieldVault.ContractRoles memory _contractRoles = FixedYieldVault.ContractRoles({
            owner: config.factoryParams.owner,
            operator: config.factoryParams.operator,
            custodian: config.factoryParams.custodian
        });

        uint256 depositStart = 1730973600; // Deposit Start: Nov 7 10 AM UTC - okay
        WindowPlugin.Window memory _depositWindow =
            WindowPlugin.Window({ opensAt: depositStart, closesAt: depositStart + 14 days - 1 });

        uint256 redeemStart = _depositWindow.closesAt + 30 days + 1; // Withdraw Start: Deposit End + 30 days
        WindowPlugin.Window memory _redemptionWindow =
            WindowPlugin.Window({ opensAt: (redeemStart), closesAt: (redeemStart + 30 days - 1) });

        _logWindowTimestamps(_depositWindow, _redemptionWindow);

        WindowPlugin.WindowPluginParams memory _windowPluginParams =
            WindowPlugin.WindowPluginParams({ depositWindow: _depositWindow, redemptionWindow: _redemptionWindow });

        WhiteListPlugin.WhiteListPluginParams memory _whiteListPluginParams = WhiteListPlugin.WhiteListPluginParams({
            whiteListProvider: config.factoryParams.owner, // using owner as the whitelist provider
            depositThresholdForWhiteListing: type(uint256).max // logically disable the whitelist
         });

        uint256 maxCap = 10_000_000 ether;
        MaxCapPlugin.MaxCapPluginParams memory _maxCapPluginParams = MaxCapPlugin.MaxCapPluginParams({ maxCap: maxCap }); // Max cap not necessary for staking vaults

        return FixedYieldVault.FixedYieldVaultParams({
            maturityVault: _maturityVaultParams,
            roles: _contractRoles,
            windowPlugin: _windowPluginParams,
            whiteListPlugin: _whiteListPluginParams,
            maxCapPlugin: _maxCapPluginParams,
            promisedYield: _yieldPercentage
        });
    }

    //@dev - see https://www.epochconverter.com/batch#results
    function _logWindowTimestamps(WindowPlugin.Window memory depositWindow, WindowPlugin.Window memory redemptionWindow)
        internal
        pure
    {
        console2.log("===============================================================");
        console2.log("Vault windows: depositStart, depositEnd, redeemStart, redeemEnd");
        console2.log("===============================================================");
        console2.log(depositWindow.opensAt);
        console2.log(depositWindow.closesAt);
        console2.log(redemptionWindow.opensAt);
        console2.log(redemptionWindow.closesAt);
        console2.log("===============================================================");
    }
}
