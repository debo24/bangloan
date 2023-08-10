//SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import { Script } from "forge-std/Script.sol";
import { console2 } from "forge-std/console2.sol";

import { HelperConfig, NetworkConfig } from "@script/HelperConfig.s.sol";

import { BangloanFixedYieldVaultFactory } from "@bangloan/BangloanFixedYieldVaultFactory.sol";
import { BangloanUpsideVaultFactory } from "@bangloan/BangloanUpsideVaultFactory.sol";
import { BangloanWhiteListProvider } from "@bangloan/BangloanWhiteListProvider.sol";

import { DeployedContracts } from "./DeployedContracts.s.sol";

contract DeployVaultFactory is Script {
    bool private isTestMode;

    function runTest()
        public
        returns (
            BangloanFixedYieldVaultFactory factory,
            BangloanUpsideVaultFactory upsideFactory,
            BangloanWhiteListProvider whiteListProvider,
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
            BangloanUpsideVaultFactory upsideFactory,
            BangloanWhiteListProvider whiteListProvider,
            HelperConfig helperConfig
        )
    {
        helperConfig = new HelperConfig(isTestMode);
        NetworkConfig memory config = helperConfig.getNetworkConfig();

        address owner = config.factoryParams.owner;
        address operator = config.factoryParams.operator;
        address[] memory custodians = new address[](1);
        custodians[0] = config.factoryParams.custodian;

        DeployedContracts deployChecker = new DeployedContracts();

        vm.startBroadcast();

        if (isTestMode || deployChecker.isDeployRequired("BangloanFixedYieldVaultFactory")) {
            factory = new BangloanFixedYieldVaultFactory(owner, operator, custodians);
            console2.log("!!!!! Deploying BangloanFixedYieldVaultFactory !!!!!");
        }

        if (isTestMode || deployChecker.isDeployRequired("BangloanUpsideVaultFactory")) {
            upsideFactory = new BangloanUpsideVaultFactory(owner, operator, custodians);
            console2.log("!!!!! Deploying BangloanVaultWithUpsideFactory !!!!!");
        }

        if (isTestMode || deployChecker.isDeployRequired("BangloanWhiteListProvider")) {
            whiteListProvider = new BangloanWhiteListProvider(operator);
            console2.log("!!!!! Deploying BangloanWhiteListProvider !!!!!");
        }

        vm.stopBroadcast();

        return (factory, upsideFactory, whiteListProvider, helperConfig);
    }
}
