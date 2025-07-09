// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract HeroWrappedSolidity {
    // Child resource analogues
    struct Sword { uint256 strength; }
    struct Shield { uint256 strength; }
    struct Hat    { uint256 strength; }

    // Hero “wraps” the three child structs
    struct Hero {
        uint256 id;
        Sword  sword;
        Shield shield;
        Hat    hat;
    }

    // Store each user’s heroes in an array
    mapping(address => Hero[]) public heroes;
    uint256 public nextId;

    /// @notice Create 125 wrapped heroes in one tx
    function createHeroesBatch() external {
        for (uint256 i = 0; i < 125; i++) {
            heroes[msg.sender].push(
                Hero({
                    id: nextId++,
                    sword: Sword(0),
                    shield: Shield(0),
                    hat:    Hat(0)
                })
            );
        }
    }

    /// @notice Create a single wrapped hero
    function createSingleHero() external {
        heroes[msg.sender].push(
            Hero({
                id: nextId++,
                sword: Sword(0),
                shield: Shield(0),
                hat:    Hat(0)
            })
        );
    }

    /// @notice Increment only sword.strength 10 000 times
    function updateWrappedHero(uint256 idx) external {
        Hero storage h = heroes[msg.sender][idx];
        for (uint256 i = 0; i < 5_000; i++) {
            h.sword.strength++;
        }
    }

    /// @notice Increment all three fields 5 000 times
    function updateAllWrappedHero(uint256 idx) external {
        Hero storage h = heroes[msg.sender][idx];
        for (uint256 i = 0; i < 5_000; i++) {
            h.sword.strength++;
            h.shield.strength++;
            h.hat.strength++;
        }
    }

    /// @notice Read sword.strength 5 000 times (returns last read)
    function accessWrappedHero(uint256 idx) external view returns (uint256) {
        Hero storage h = heroes[msg.sender][idx];
        uint256 temp;
        for (uint256 i = 0; i < 5_000; i++) {
            temp = h.sword.strength;
        }
        return temp;
    }

    /// @notice Read all three fields 5 000 times
    function accessAllWrappedHero(uint256 idx) external view returns (uint256) {
        Hero storage h = heroes[msg.sender][idx];
        uint256 temp;
   
for (uint256 i = 0; i < 5_000; i++) {
    temp = h.sword.strength;
    temp = h.shield.strength;
    temp = h.hat.strength;
}
        return temp;
    }

    /// @notice Delete a single hero (clears storage at that index)
    function deleteWrappedHero(uint256 idx) external {
        delete heroes[msg.sender][idx];
    }

/// @notice Delete all wrapped heroes for a given user (clears storage)
    function deleteAllWrappedHeroes(address addr) external {
        uint256 len = heroes[addr].length;
         // This loop iterates over the array but does not access its elements. It
          // iterates only over the number of elements, ie. length (which is 10),
           for(uint256 i = 0; i < len; ++i) {
            delete heroes[addr][i];
        }
    }
}
