// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract SametaAvtarV1 is
    Initializable,
    UUPSUpgradeable,
    ERC721URIStorageUpgradeable,
    PausableUpgradeable,
    AccessControlUpgradeable
{
    bool public transferRestricted;
    uint256 private tokenIdCounter;
    bytes32 public constant ISSUER = keccak256("ISSUER");

    /**
    @dev modifier to restrict transfer of NFTs to only ISSUER.
    */
    modifier whenTransferNotRestricted() {
        if (transferRestricted) {
            require(
                hasRole(ISSUER, _msgSender()),
                "Sameta_Avtar: transfer restricted to ISSUER"
            );
        }
        _;
    }

    // prevents intialization of logic contract.
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /**
    @dev initializing Sameta_Avtar_V1 with default values.
    @param _name_ name of the NFT.
    @param _symbol_ symbol of the NFT.
    Note:initializer modifier is used to prevent initialize token twice.
    */
    function __SametaAvtarV1_init(
        string memory _name_,
        string memory _symbol_
    ) public initializer {
        __ERC721_init(_name_, _symbol_);
        __ERC721URIStorage_init();
        __Pausable_init();
        __AccessControl_init();
        __UUPSUpgradeable_init();
        __SametaAvtarV1_init_unchained();
    }

    /**
    @dev internal function to initialize "this" contract with default values.
    setting msg sender as DEFAULT_ADMIN_ROLE and ISSUER.
    transferRestricted is set to true.
    tokenIdCounter is set to 0.
    */
    function __SametaAvtarV1_init_unchained() internal onlyInitializing {
        _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _grantRole(ISSUER, _msgSender());
        transferRestricted = true;
        tokenIdCounter = 0;
    }

    /**
     * @dev Pauses the market contract.
     *
     * See {ERC20Pausable} and {Pausable-_pause}.
     *
     * Requirements:
         - the caller must have DEFAULT_ADMIN_ROLE.
     */
    function pause() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _pause();
    }

    /**
     * @dev Unpauses the market contract.
     *
     * See {ERC20Pausable} and {Pausable-_unpause}.
     *
     * Requirements:
         - the caller must have DEFAULT_ADMIN_ROLE.
     */
    function unpause() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _unpause();
    }

    /**
    @dev function to create new NFT by the ISSUER.
    @param _uri metadata URI of token. 
    @param __owner owner of the NFT.
    * Requirements:
        - caller must have ISSUER role.
        - contract must not be paused.
    * See {ERC721}.
    */
    function createItem(
        string calldata _uri,
        address __owner
    ) external whenNotPaused onlyRole(ISSUER) returns (uint256) {
        // incrimenting tokenIdCounter by 1
        ++tokenIdCounter;

        // register current counter value as tokenId
        uint256 tokenId = tokenIdCounter;

        require(
            _createItem(_uri, tokenId, __owner),
            "Sameta_Avtar: create new token failed"
        );
        return tokenId;
    }

    /**
    @dev function to burn NFT
    @param tokenId NFT id
    * See {ERC721}.
    *
    * Requirements:
        - the caller must have ISSUER role.
    */
    function burn(
        uint256 tokenId
    ) public virtual onlyRole(ISSUER) whenNotPaused returns (bool) {
        _burn(tokenId);
        return true;
    }

    /**
    @dev function to update transfer restriction.
    @param value bool value to set transfer restriction.
    When value is true, only ISSUER can transfer NFTs.
    This is an additional feature to restrict the change of ownership of avtar.
    However the OWNER can contact the ISSUER to change the ownership.
    */
    function updateTransferRestriction(
        bool value
    ) public onlyRole(ISSUER) returns (bool) {
        require(value != transferRestricted, "Sameta_Avtar: value already set");
        transferRestricted = value;
        return true;
    }

    /**
    @dev overriding supportsInterface to include ERC721URIStorageUpgradeable and AccessControlUpgradeable.
    */
    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        virtual
        override(ERC721URIStorageUpgradeable, AccessControlUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    /**
    @dev overriding _update and add whenTransferNotRestricted modifier.
    This will restrict the transfer of NFTs to only ISSUER when transferRestricted is true.
    */
    function _update(
        address to,
        uint256 tokenId,
        address auth
    ) internal virtual override whenTransferNotRestricted returns (address) {
        return super._update(to, tokenId, auth);
    }

    /**
    @dev overriding _authorizeUpgrade and restricting upgrade to only DEFAULT_ADMIN_ROLE.
    */
    function _authorizeUpgrade(
        address newImplementation
    ) internal virtual override onlyRole(DEFAULT_ADMIN_ROLE) {}

    /**
    @dev internal function to create new NFT.
    @param _uri metadata URI of token. 
    */
    function _createItem(
        string memory _uri,
        uint256 _tokenId,
        address __owner
    ) internal returns (bool) {
        // minting token to callers address.
        _safeMint(__owner, _tokenId);

        // setting tokenUri
        _setTokenURI(_tokenId, _uri);

        return true;
    }
}
