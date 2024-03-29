// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "hardhat/console.sol";

import "./libraries/Base64.sol";

contract MyEpicGame is ERC721 {
	struct CharacterAttributes {
		uint characterIndex;
		string name;
		string imageURI;        
		uint hp;
		uint maxHp;
		uint attackDamage;
	}
	CharacterAttributes[] defaultCharacters;

	struct BigBoss {
		string name;
		string imageURI;
		uint hp;
		uint maxHp;
		uint attackDamage;
	}
	BigBoss public bigBoss;

	using Counters for Counters.Counter;
	Counters.Counter private _tokenIds;

	mapping(uint256 => CharacterAttributes) public nftHolderAttributes;
	mapping(address => uint256) public nftHolders;

	event CharacterNFTMinted(address sender, uint256 tokenId, uint256 characterIndex);
	event AttackComplete(uint newBossHp, uint newPlayerHp);

	constructor(
		string[] memory characterNames,
		string[] memory characterImageURIs,
		uint[] memory characterHp,
		uint[] memory characterAttackDmg,
		string memory bossName,
		string memory bossImageURI,
		uint bossHp,
		uint bossAttackDamage
	)
	ERC721("Spyros", "SPY")
	{
		// Create boss
		bigBoss = BigBoss({
			name: bossName,
			imageURI: bossImageURI,
			hp: bossHp,
			maxHp: bossHp,
			attackDamage: bossAttackDamage
		});

		console.log("Done initializing boss %s w/ HP %s, img %s", bigBoss.name, bigBoss.hp, bigBoss.imageURI);

		// Create NFTs
		for(uint i = 0; i < characterNames.length; i += 1) {
		defaultCharacters.push(CharacterAttributes({
			characterIndex: i,
			name: characterNames[i],
			imageURI: characterImageURIs[i],
			hp: characterHp[i],
			maxHp: characterHp[i],
			attackDamage: characterAttackDmg[i]
		}));

		CharacterAttributes memory c = defaultCharacters[i];
		
		console.log("Done initializing %s w/ HP %s, img %s", c.name, c.hp, c.imageURI);
		}

		_tokenIds.increment();
	}

	function mintCharacterNFT(uint _characterIndex) external {
		require(nftHolders[msg.sender] == 0, "Error: sender already owns an NFT");

		uint256 newItemId = _tokenIds.current();
		_safeMint(msg.sender, newItemId);
		nftHolderAttributes[newItemId] = CharacterAttributes({
			characterIndex: _characterIndex,
			name: defaultCharacters[_characterIndex].name,
			imageURI: defaultCharacters[_characterIndex].imageURI,
			hp: defaultCharacters[_characterIndex].hp,
			maxHp: defaultCharacters[_characterIndex].maxHp,
			attackDamage: defaultCharacters[_characterIndex].attackDamage
		});
		console.log("Minted NFT w/ tokenId %s and characterIndex %s", newItemId, _characterIndex);
		nftHolders[msg.sender] = newItemId;
		_tokenIds.increment();
		emit CharacterNFTMinted(msg.sender, newItemId, _characterIndex);
	}

	function tokenURI(uint256 _tokenId) public view override returns (string memory) {
		CharacterAttributes memory charAttributes = nftHolderAttributes[_tokenId];

		string memory strHp = Strings.toString(charAttributes.hp);
		string memory strMaxHp = Strings.toString(charAttributes.maxHp);
		string memory strAttackDamage = Strings.toString(charAttributes.attackDamage);

		string memory json = Base64.encode(
			bytes(
			string(
				abi.encodePacked(
				'{"name": "',
				charAttributes.name,
				' -- NFT #: ',
				Strings.toString(_tokenId),
				'", "description": "This is an NFT that lets people play in the game Metaverse Slayer!", "image": "',
				charAttributes.imageURI,
				'", "attributes": [ { "trait_type": "Health Points", "value": ',strHp,', "max_value":',strMaxHp,'}, { "trait_type": "Attack Damage", "value": ',
				strAttackDamage,'} ]}'
				)
			)
			)
		);

		string memory output = string(
			abi.encodePacked("data:application/json;base64,", json)
		);
		
		return output;
	}

	function attackBoss() public {
		// Get the state of the player's NFT.
		uint256 nftTokenIdOfPlayer = nftHolders[msg.sender];
		CharacterAttributes storage player = nftHolderAttributes[nftTokenIdOfPlayer];
		// Make sure the player has more than 0 HP.
		require (player.hp > 0, "Error: character must have HP to attack boss.");
		// Make sure the boss has more than 0 HP.
		require (bigBoss.hp > 0, "Error: boss must have HP to attack boss.");
		// Allow player to attack boss.
		if (bigBoss.hp < player.attackDamage) {
			bigBoss.hp = 0;
		} else {
			bigBoss.hp = bigBoss.hp - player.attackDamage;
		}
		// Allow boss to attack player.
		if (player.hp < bigBoss.attackDamage) {
			player.hp = 0;
		} else {
			player.hp = player.hp - bigBoss.attackDamage;
		}
		emit AttackComplete(bigBoss.hp, player.hp);
	}

	// Get the tokenId of the user's character NFT
	// Else, return an empty character.
	function checkIfUserHasNFT() public view returns (CharacterAttributes memory) {
		uint256 userNftTokenId = nftHolders[msg.sender];
		if (userNftTokenId != 0) {
			return nftHolderAttributes[userNftTokenId];
		} else {
			CharacterAttributes memory emptyStruct;
			return emptyStruct;
		}
	}

	function getDefaultCharacters() public view returns (CharacterAttributes[] memory) {
		return defaultCharacters;
	}
	
	function getBigBoss() public view returns (BigBoss memory) {
		return bigBoss;
	}
}
