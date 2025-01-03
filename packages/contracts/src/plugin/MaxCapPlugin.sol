//SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

/// @notice - A Plugin to handle MaxCap
abstract contract MaxCapPlugin {
    error BangloanVault__MaxCapReached();

    /// @notice Event emitted when the max cap is updated
    event MaxCapUpdated(uint256 indexed maxCap);

    /// @notice Event emitted when the max cap check is updated
    event MaxCapCheckUpdated(bool indexed checkMaxCap);

    /// @notice - Params for the MaxCap Plugin
    struct MaxCapPluginParams {
        uint256 maxCap;
    }

    /// @notice Max no.of assets that can be deposited to the vault;
    uint256 public maxCap;

    /// @notice Flag to check for max cap
    bool public checkMaxCap;

    constructor(MaxCapPluginParams memory params) {
        maxCap = params.maxCap;
        checkMaxCap = true; // Set the check to true by default
    }

    /**
     * @notice - Function to check for max cap
     * @param value - The value to check against max cap
     */
    function _checkMaxCap(uint256 value) internal virtual {
        if (checkMaxCap && value > maxCap) {
            revert BangloanVault__MaxCapReached();
        }
    }

    /// @notice - Toggle the max cap check status
    function _setCheckMaxCap(bool _checkMaxCapStatus) internal virtual {
        checkMaxCap = _checkMaxCapStatus;

        emit MaxCapCheckUpdated(checkMaxCap);
    }

    /// @notice - Update the max cap value
    function _updateMaxCap(uint256 _value) internal virtual {
        maxCap = _value;

        emit MaxCapUpdated(maxCap);
    }
}
