// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IERC20 } from "@openzeppelin/contracts/interfaces/IERC20.sol";
import { Math } from "@openzeppelin/contracts/utils/math/Math.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { FixedYieldVault } from "./FixedYieldVault.sol";

contract UpsideVault is FixedYieldVault {
    using Math for uint256;

    /// @notice Error to indicate that the provided share balance is insufficient.
    error BangloanVault__InsufficientShareBalance();

    /// @notice Error to indicate that the provided collateral percentage is invalid.
    error BangloanVault__InvalidUpsidePercentage();

    struct UpsideVaultParams {
        FixedYieldVaultParams fixedYieldVault;
        IERC20 cblToken;
        uint256 upsidePercentage;
    }

    /// @notice address of the Bangloan token CBL
    IERC20 public token;

    uint256 public twap = 100_00;

    /// @notice Percentage of collateral (100_00) is 100%
    uint256 public upsidePercentage;

    mapping(address account => uint256) private _upsideBalance;

    /// @notice Total collateral deposited
    // uint256 public totalCollateralDeposited;

    /// @notice Maximum percentage value (100%)
    uint256 private constant MAX_PERCENTAGE = 100_00;

    /// @notice Precision used for math
    uint256 private constant PRECISION = 1e18;

    /// @notice Additional precision required for math
    uint256 private additionalPrecision;

    constructor(UpsideVaultParams memory params) FixedYieldVault(params.fixedYieldVault) {
        if (params.upsidePercentage > MAX_PERCENTAGE) {
            revert BangloanVault__InvalidUpsidePercentage();
        }
        upsidePercentage = params.upsidePercentage;
        token = params.cblToken;

        uint8 assetDecimal = _checkValidDecimalValue(address(params.fixedYieldVault.maturityVault.vault.asset));
        uint8 tokenDecimal = _checkValidDecimalValue(address(params.cblToken));

        if (tokenDecimal >= assetDecimal) {
            additionalPrecision = 10 ** (tokenDecimal - assetDecimal);
        } else {
            revert BangloanVault__UnsupportedDecimalValue(assetDecimal);
        }
    }

    /// @dev - Overridden internal deposit method to handle collateral
    function _deposit(address caller, address receiver, uint256 assets, uint256 shares)
        internal
        override
        onDepositOrMint(caller, receiver, assets, shares)
        whenNotPaused
    {
        (, uint256 reminder) = assets.tryMod(10 ** VAULT_DECIMALS);
        if (reminder > 0) {
            revert BangloanVault__InvalidAssetAmount(assets);
        }

        uint256 collateral = getCollateralAmount(assets);

        _upsideBalance[receiver] += collateral;
        totalAssetDeposited += assets;

        if (totalAssetDeposited > maxCap) {
            revert BangloanVault__MaxCapReached();
        }

        SafeERC20.safeTransferFrom(token, caller, address(this), collateral);
        SafeERC20.safeTransferFrom(IERC20(asset()), caller, CUSTODIAN, assets);

        _mint(receiver, shares);

        emit Deposit(caller, receiver, assets, shares);
    }

    /// @dev - Overridden withdraw method to handle collateral
    function _withdraw(address caller, address receiver, address owner, uint256 assets, uint256 shares)
        internal
        override
        onWithdrawOrRedeem(caller, receiver, owner, assets, shares)
        whenNotPaused
    {
        if (caller != owner) {
            _spendAllowance(owner, caller, shares);
        }

        uint256 collateral = calculateTokenRedemption(shares, owner);

        _upsideBalance[owner] -= collateral;
        totalAssetDeposited -= assets;

        SafeERC20.safeTransfer(token, receiver, collateral);

        _burn(owner, shares);
        SafeERC20.safeTransfer(IERC20(asset()), receiver, assets);

        emit Withdraw(caller, receiver, owner, assets, shares);
    }

    /// @notice - Get the collateral amount to deposit for the given asset
    function getCollateralAmount(uint256 assets) public view virtual returns (uint256) {
        return ((assets * additionalPrecision).mulDiv(upsidePercentage, MAX_PERCENTAGE)).mulDiv(MAX_PERCENTAGE, twap);
    }

    /// @notice - Get the collateral amount to redeem for the given shares
    function calculateTokenRedemption(uint256 shares, address account) public view virtual returns (uint256) {
        if (balanceOf(account) < shares) {
            revert BangloanVault__InsufficientShareBalance();
        }

        uint256 sharePercent = shares.mulDiv(PRECISION, balanceOf(account));
        return _upsideBalance[account].mulDiv(sharePercent, PRECISION);
    }

    /// @notice - Update the twap value
    function setTWAP(uint256 _twap) public onlyRole(OPERATOR_ROLE) {
        twap = _twap;
    }
}
