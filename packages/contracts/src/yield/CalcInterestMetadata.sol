// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { ICalcInterestMetadata } from "@bangloan/yield/ICalcInterestMetadata.sol";
import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

/**
 * @title CalcInterestMetadata
 * @dev Implements interest calculation parameters like rate, frequency, and scale.
 */
abstract contract CalcInterestMetadata is Initializable, ICalcInterestMetadata {
    uint256 public RATE_PERCENT_SCALED; // rate in percentage * scale.  e.g., at scale 1e3, 5% = 5000.
    uint256 public FREQUENCY;
    uint256 public SCALE;

    constructor() {
        _disableInitializers();
    }

    function __CalcInterestMetadata_init(uint256 ratePercentageScaled_, uint256 frequency_, uint256 decimals_)
        internal
        onlyInitializing
    {
        RATE_PERCENT_SCALED = ratePercentageScaled_;
        FREQUENCY = frequency_;
        SCALE = 10 ** decimals_;
    }

    /// @notice Returns the frequency of interest application.
    function frequency() public view virtual returns (uint256 frequency_) {
        return FREQUENCY;
    }

    /// @notice Returns the annual interest rate as a percentage, scaled.
    function rateScaled() public view virtual returns (uint256 ratePercentageScaled_) {
        return RATE_PERCENT_SCALED;
    }

    /// @notice Returns the scale factor for calculations (e.g., 10^18 for 18 decimals).
    function scale() public view virtual returns (uint256 scale_) {
        return SCALE;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}
