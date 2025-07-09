// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract HeroDynamicFields {
    // --- Types ---
    struct Hero {
        uint256 id;
        address owner;
    }
    struct Accessory {
        uint256 strength;
        bool exists;
    }

    // --- State ---
    uint256 public nextHeroId;
    mapping(uint256 => Hero) public heroes;
    mapping(address => uint256[]) public ownerHeroes;
    // heroId => (fieldName => Accessory)
    mapping(uint256 => mapping(bytes32 => Accessory)) private _fields;

    // Pre-computed keys for “dynamic” field names
    bytes32 private constant SWORD  = keccak256("sword");
    bytes32 private constant SHIELD = keccak256("shield");
    bytes32 private constant HAT    = keccak256("hat");

    // --- Creation ---

    /// @notice Create one Hero with sword, shield, hat all at strength=0
    function createSingleHeroDynamicFields() external {
        uint256 id = nextHeroId++;
        heroes[id] = Hero(id, msg.sender);
        ownerHeroes[msg.sender].push(id);

        _fields[id][SWORD]  = Accessory({ strength: 0, exists: true });
        _fields[id][SHIELD] = Accessory({ strength: 0, exists: true });
        _fields[id][HAT]    = Accessory({ strength: 0, exists: true });
    }

    /// @notice Create 125 heroes, each with sword/shield/hat
    function createHeroesDynamicBatch() external {
        for (uint256 i = 0; i < 125; i++) {
            uint256 id = nextHeroId++;
            heroes[id] = Hero(id, msg.sender);
            ownerHeroes[msg.sender].push(id);

            _fields[id][SWORD]  = Accessory(0, true);
            _fields[id][SHIELD] = Accessory(0, true);
            _fields[id][HAT]    = Accessory(0, true);
        }
    }

    // --- Updates (hardcoded 5,000 iterations) ---

    /// @notice Increment only sword.strength 5,000×
    function updateHeroSword(uint256 heroId) external {
        require(heroes[heroId].owner == msg.sender, "Not owner");
        Accessory storage a = _fields[heroId][SWORD];
        require(a.exists, "Sword missing");
        for (uint256 i = 0; i < 5000; i++) {
            a.strength++;
        }
    }

    /// @notice Increment sword/shield/hat each 5,000×
    function updateHeroAll(uint256 heroId) external {
        require(heroes[heroId].owner == msg.sender, "Not owner");
        Accessory storage s = _fields[heroId][SWORD];
        Accessory storage h = _fields[heroId][SHIELD];
        Accessory storage t = _fields[heroId][HAT];
        require(s.exists && h.exists && t.exists, "Missing field");
        for (uint256 i = 0; i < 500; i++) {
            s.strength++;
            h.strength++;
            t.strength++;
        }
    }

    // --- Access (view) loops (hardcoded 5,000 iterations) ---

    /// @notice Read sword.strength 5,000× and return last
    function accessHeroSword(uint256 heroId) external view returns (uint256) {
        require(heroes[heroId].owner == msg.sender, "Not owner");
        Accessory storage a = _fields[heroId][SWORD];
        require(a.exists, "Sword missing");
        uint256 tmp;
        for (uint256 i = 0; i < 5000; i++) {
            tmp = a.strength;
        }
        return tmp;
    }

    /// @notice Read sword/shield/hat 5,000× and return last
    function accessHeroAll(uint256 heroId) external view returns (uint256) {
        require(heroes[heroId].owner == msg.sender, "Not owner");
        Accessory storage s = _fields[heroId][SWORD];
        Accessory storage h = _fields[heroId][SHIELD];
        Accessory storage t = _fields[heroId][HAT];
        require(s.exists && h.exists && t.exists, "Missing field");
        uint256 tmp;
        for (uint256 i = 0; i < 5000; i++) {
            tmp = s.strength;
            tmp = h.strength;
            tmp = t.strength;
        }
        return tmp;
    }

    // --- Deletion & Detach Semantics ---

    function deleteSword(uint256 heroId) external {
        require(heroes[heroId].owner == msg.sender, "Not owner");
        delete _fields[heroId][SWORD];
    }
    function deleteShield(uint256 heroId) external {
        require(heroes[heroId].owner == msg.sender, "Not owner");
        delete _fields[heroId][SHIELD];
    }
    function deleteHat(uint256 heroId) external {
        require(heroes[heroId].owner == msg.sender, "Not owner");
        delete _fields[heroId][HAT];
    }
    function deleteHeroWithAccessories(uint256 heroId) external {
        require(heroes[heroId].owner == msg.sender, "Not owner");
        delete heroes[heroId];
        delete _fields[heroId][SWORD];
        delete _fields[heroId][SHIELD];
        delete _fields[heroId][HAT];
    }

    event AccessoryDetached(
        uint256 indexed heroId,
        bytes32 indexed fieldName,
        uint256 strength,
        address owner
    );

    /// @notice Detach fields (emit event) but don’t delete them on‐chain, then delete hero
    function detachButNotDeleteChildren(uint256 heroId) external {
        require(heroes[heroId].owner == msg.sender, "Not owner");
        _detachField(heroId, SWORD);
        _detachField(heroId, SHIELD);
        _detachField(heroId, HAT);
        delete heroes[heroId];
    }

    function _detachField(uint256 heroId, bytes32 name) private {
        Accessory storage a = _fields[heroId][name];
        if (a.exists) {
            emit AccessoryDetached(heroId, name, a.strength, msg.sender);
            delete _fields[heroId][name];
        }
    }
}
