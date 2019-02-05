pragma solidity ^0.4.24;

import "./depCrowd.sol";
import "./Ownable.sol";

contract cDeployer is Ownable {
	
	address private main;

	function cMain(address nM) public onlyOwner {
		main = nM;
	}

	function deployCrowdsale(address _eWallet, address _token, address _tWallet, uint _maxToken, address reqBy) public returns (address) {
		require(msg.sender == main);
		crowdsaleContract newContract = new crowdsaleContract(_eWallet, _token, _tWallet, _maxToken, reqBy);
		return newContract;
	}

}