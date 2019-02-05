pragma solidity ^0.4.21;

import "./depToken.sol";
import "./Ownable.sol";

contract tDeployer is Ownable {

	address private main;

	function cMain(address nM) public onlyOwner {
		main = nM;
	}

    function deployToken(string _tName, string _tSymbol, uint _mint, address _owner) public returns (address) {
		require(msg.sender == main);
		tokenContract newContract = new tokenContract(_tName, _tSymbol, _mint, _owner);
		return newContract;
	}


}