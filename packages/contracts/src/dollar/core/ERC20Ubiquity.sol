// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ERC20, ERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import {ERC20Pausable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import {IAccessControl} from "../interfaces/IAccessControl.sol";
import {DEFAULT_ADMIN_ROLE, PAUSER_ROLE} from "../libraries/Constants.sol";
import {IERC20Ubiquity} from "../../dollar/interfaces/IERC20Ubiquity.sol";

/**
 * @notice Base contract for Ubiquity ERC20 tokens (Dollar, Credit, Governance)
 * @notice ERC20 with:
 * - ERC20 minter, burner and pauser
 * - draft-ERC20 permit
 * - Ubiquity Manager access control
 */
abstract contract ERC20Ubiquity is ERC20Permit, ERC20Pausable, IERC20Ubiquity {
    /// @notice Token symbol
    string private _symbol;

    /// @notice Access control interface
    IAccessControl public accessControl;

    /// @notice Modifier checks that the method is called by a user with the "pauser" role
    modifier onlyPauser() {
        require(
            accessControl.hasRole(PAUSER_ROLE, msg.sender),
            "ERC20Ubiquity: not pauser"
        );
        _;
    }

    /// @notice Modifier checks that the method is called by a user with the "admin" role
    modifier onlyAdmin() {
        require(
            accessControl.hasRole(DEFAULT_ADMIN_ROLE, msg.sender),
            "ERC20Ubiquity: not admin"
        );
        _;
    }

    /**
     * @notice Contract constructor
     * @param _manager Access control address
     * @param name_ Token name
     * @param symbol_ Token symbol
     */
    constructor(
        address _manager,
        string memory name_,
        string memory symbol_
    ) ERC20(name_, symbol_) ERC20Permit(name_) {
        _symbol = symbol_;
        accessControl = IAccessControl(_manager);
    }

    /**
     * @notice Updates token symbol
     * @param newSymbol New token symbol name
     */
    function setSymbol(string memory newSymbol) external onlyAdmin {
        _symbol = newSymbol;
    }

    /**
     * @notice Returns token symbol name
     * @return Token symbol name
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @notice Returns access control address
     * @return Access control address
     */
    function getManager() external view returns (address) {
        return address(accessControl);
    }

    /**
     * @notice Sets access control address
     * @param _manager New access control address
     */
    function setManager(address _manager) external onlyAdmin {
        accessControl = IAccessControl(_manager);
    }

    /// @notice Pauses all token transfers
    function pause() public onlyPauser {
        _pause();
    }

    /// @notice Unpauses all token transfers
    function unpause() public onlyPauser {
        _unpause();
    }

    /**
     * @notice Destroys `amount` tokens from the caller
     * @param amount Amount of tokens to destroy
     */
    function burn(uint256 amount) public virtual whenNotPaused {
        _burn(_msgSender(), amount);
        emit Burning(msg.sender, amount);
    }

    /**
     * @notice Destroys `amount` tokens from `account`, deducting from the caller's
     * allowance
     * @notice Requirements:
     * - the caller must have allowance for `account`'s tokens of at least `amount`
     * @param account Address to burn tokens from
     * @param amount Amount of tokens to burn
     */
    function burnFrom(address account, uint256 amount) public virtual;

    /**
     * @notice Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override(ERC20, ERC20Pausable) {
        super._beforeTokenTransfer(from, to, amount);
    }

    /**
     * @notice Moves `amount` of tokens from `from` to `to`.
     *
     * This internal function is equivalent to `transfer`, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a `Transfer` event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual override whenNotPaused {
        super._transfer(sender, recipient, amount);
    }
}
