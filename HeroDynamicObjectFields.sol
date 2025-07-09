// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title Hero with “Dynamic Object Fields” (Sword, Shield, Hat)
/// @notice Simulates Sui’s dynamic_object_field in Solidity using mappings
contract HeroDynamicObjectFields {
    struct Hero   { uint256 id; }
    struct Sword  { uint256 id; uint256 strength; }
    struct Shield { uint256 id; uint256 strength; }
    struct Hat    { uint256 id; uint256 strength; }

    uint256 public nextId = 1;
    mapping(uint256 => Hero)   public heroes;
    mapping(uint256 => Sword)  public swords;
    mapping(uint256 => Shield) public shields;
    mapping(uint256 => Hat)    public hats;

    /// @notice Mint helpers (made public for testing)
    function _mintHero() public returns (uint256 id) {
        id = nextId++;
        heroes[id] = Hero(id);
    }

    function _mintSword() public returns (uint256) {
        return nextId++;
    }

    function _mintShield() public returns (uint256) {
        return nextId++;
    }

    function _mintHat() public returns (uint256) {
        return nextId++;
    }

    /// @notice Create one hero + attach three accessories
    function createSingleHeroDynamicObjectFields() public {
        uint256 h   = _mintHero();
        uint256 sId = _mintSword();
        swords[h]   = Sword(sId,  0);
        uint256 shId = _mintShield();
        shields[h]  = Shield(shId, 0);
        uint256 htId = _mintHat();
        hats[h]     = Hat(htId,    0);
    }

    /// @notice Create exactly 125 heroes
    function create125HeroesDynamicObjectFields() public {
        for (uint256 i = 0; i < 125; i++) {
            createSingleHeroDynamicObjectFields();
        }
    }

    // ----------------------------
    // Access (read) functions
    // ----------------------------
    function accessSword(uint256 h) public view returns (uint256) {
        return swords[h].strength;
    }

    function accessShield(uint256 h) public view returns (uint256) {
        return shields[h].strength;
    }

    function accessHat(uint256 h) public view returns (uint256) {
        return hats[h].strength;
    }

    function accessHeroDynamicObjectFields(uint256 h) public view {
        for (uint256 i = 0; i < 10_000; i++) {
            accessSword(h);
        }
    }

    function accessAllHeroDynamicObjectFields(uint256 h) public view {
        for (uint256 i = 0; i < 10_000; i++) {
            accessSword(h);
            accessShield(h);
            accessHat(h);
        }
    }

    function testAccessHeroDynamicObjectField(uint256 h) public view {
        accessSword(h);
    }

    // ----------------------------
    // Update (write) functions
    // ----------------------------
    function mutateSword(uint256 h) public {
        swords[h].strength += 1;
    }

    function mutateShield(uint256 h) public {
        shields[h].strength += 1;
    }

    function mutateHat(uint256 h) public {
        hats[h].strength += 1;
    }

    function updateHeroDynamicObjectFields(uint256 h) public {
        for (uint256 i = 0; i < 10_000; i++) {
            mutateSword(h);
        }
    }

    function updateAllHeroDynamicObjectFields(uint256 h) public {
        for (uint256 i = 0; i < 10_000; i++) {
            mutateSword(h);
            mutateShield(h);
            mutateHat(h);
        }
    }

    // ----------------------------
    // Delete functions
    // ----------------------------
    function deleteSword(uint256 h) public {
        delete swords[h];
    }

    function deleteShield(uint256 h) public {
        delete shields[h];
    }

    function deleteHat(uint256 h) public {
        delete hats[h];
    }

    function deleteHero(uint256 h) public {
        delete heroes[h];
    }

    function deleteHeroDetachAndDeleteChildren(uint256 h) public {
        deleteSword(h);
        deleteShield(h);
        deleteHat(h);
        deleteHero(h);
    }

    function detachButNotDeleteChildren(uint256 h) public {
        // simulate “transfer” by reading first
        Sword memory s  = swords[h];
        Shield memory sh = shields[h];
        Hat memory ht    = hats[h];
        deleteSword(h);
        deleteShield(h);
        deleteHat(h);
    }
}
