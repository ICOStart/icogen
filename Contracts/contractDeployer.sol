pragma solidity ^0.4.21;

import "./Ownable.sol";
import "./ERC20.sol";

contract cDeployer {
	function deployCrowdsale(address _tWallet, address _token, address _eWallet, uint _maxETH, address reqBy) public returns (address);
}

contract tDeployer {
	function deployToken(string _tName, string _tSymbol, uint _mint, address _owner) public returns (address);
}

contract customTkn {
    function multiTransfer(address[] _to, uint256[] _values) public;
    function transferFrom(address from, address to, uint256 value) public returns (bool);
}

contract contractDeployer is Ownable {
	
	event ContractCreated(address newAddress);
	
    address public tokenAddr;
	uint public tokenFee;
	uint public crowdsaleFee;
	uint public multisendFee;

	ERC20 token;
	cDeployer cdep;
	tDeployer tdep;

	function setUp(address _token, address _cdep, address _tdep) public onlyOwner {
		tokenAddr = _token;
		token = ERC20(tokenAddr);
		cdep = cDeployer(_cdep);
		tdep = tDeployer(_tdep);
	}
	function changeTokenFee(uint _amount) public onlyOwner {
		tokenFee = _amount;
	}
	function changeCrowdsaleFee(uint _amount) public onlyOwner {
		crowdsaleFee = _amount;
	}
	function changeMultisendFee(uint _amount) public onlyOwner {
		multisendFee = _amount;
	}

	function deployToken(string _tName, string _tSymbol, uint _mint, address _owner) public returns (address) {
		require(token.transferFrom(msg.sender, owner, tokenFee));
		emit ContractCreated(tdep.deployToken(_tName, _tSymbol, _mint, _owner));
	}
	
	function deployCrowdsale(address _tWallet, address _token, address _eWallet, uint _maxETH) public returns (address) {
		require(token.transferFrom(msg.sender, owner, crowdsaleFee));
		emit ContractCreated(cdep.deployCrowdsale(_eWallet, _token, _tWallet, _maxETH, msg.sender));
	}


	function multiSender(address _token, uint _total, address[] _to, uint[] _amount) public {
		require(token.transferFrom(msg.sender, owner, multisendFee));
		customTkn er2 = customTkn(_token);
		require(er2.transferFrom(msg.sender, this, _total));
		er2.multiTransfer(_to, _amount);
	}

}