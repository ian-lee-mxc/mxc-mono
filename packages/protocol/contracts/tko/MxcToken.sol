// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./TaikoTokenBase.sol";

/// @title TaikoToken
/// @notice The TaikoToken (TKO), in the protocol is used for prover collateral
/// in the form of bonds. It is an ERC20 token with 18 decimal places of precision.
/// @dev Labeled in AddressResolver as "taiko_token"
/// @custom:security-contact luanxu@mxc.org
contract MxcToken is TaikoTokenBase {
    error TT_INVALID_PARAM();

    /// @notice Initializes the contract.
    /// @param _owner The owner of this contract. msg.sender will be used if this value is zero.
    /// @param _recipient The address to receive initial token minting.
    function init(address _owner, address _recipient) public initializer {
        __Essential_init(_owner);
        __ERC20_init("MXC Token", "MXC");
        __ERC20Votes_init();
        __ERC20Permit_init("MXC Token");
        // Mint 1 billion tokens
        _mint(_recipient, 1_000_000_000 ether);
    }

    /// @notice Initializes the contract.
    /// @param _owner The owner of this contract. msg.sender will be used if this value is zero.
    /// @param _recipient The address to receive initial token minting.
    function init2(
        address _addressManager,
        address _owner,
        address _oldTokenVault,
        address _recipient
    )
        public
        reinitializer(2)
    {
        __Essential_init(_owner, _addressManager);
        __ERC20_init("MXC Token", "MXC");
        __ERC20Votes_init();
        __ERC20Permit_init("MXC Token");

        if (_oldTokenVault != address(0)) {
            // burn old tokenValue, testnet
            uint256 balance = super.balanceOf(_oldTokenVault);
            _burn(_oldTokenVault, balance);
            _mint(_recipient, balance);
        }
        if (totalSupply() == 0) {
            _mint(_recipient, 1_000_000_000 ether);
        }
    }

    /// @notice Batch transfers tokens
    /// @param recipients The list of addresses to transfer tokens to.
    /// @param amounts The list of amounts for transfer.
    /// @return true if the transfer is successful.
    function batchTransfer(
        address[] calldata recipients,
        uint256[] calldata amounts
    )
        external
        returns (bool)
    {
        if (recipients.length != amounts.length) revert TT_INVALID_PARAM();
        for (uint256 i; i < recipients.length; ++i) {
            if (recipients[i] == address(0)) {
                continue;
            }
            _transfer(msg.sender, recipients[i], amounts[i]);
        }
        return true;
    }

    function delegates(address account) public view virtual override returns (address) {
        return super.delegates(account);
    }

    function mint(address to, uint256 amount) public onlyFromOptionalNamed(LibStrings.B_TAIKO) {
        super._mint(to, amount);
    }

    function burn(address from, uint256 amount) public onlyFromOptionalNamed(LibStrings.B_TAIKO) {
        super._burn(from, amount);
    }
}
