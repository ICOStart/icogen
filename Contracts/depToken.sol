pragma solidity ^0.4.24;

import "./BurnableToken.sol";
import "./MintableToken.sol";
import "./DetailedERC20.sol";

contract tokenContract is BurnableToken, MintableToken, DetailedERC20 {

  uint256 constant internal DECIMALS = 18;

constructor (string _name, string _symbol, uint256 _initialSupply, address realOwner) public
    DetailedERC20(_name, _symbol, uint8(DECIMALS))
   {
    require(_initialSupply > 0);
    totalSupply_ = _initialSupply;
    balances[realOwner] = _initialSupply;
    emit Mint(realOwner, _initialSupply);
    emit Transfer(address(0), realOwner, _initialSupply);
    transferOwnership(realOwner);
  }

  function setCrowdsale(address tokenWallet, uint maxToken) public returns (bool) {
    if(tx.origin == owner && balances[tokenWallet] >= maxToken){
      allowed[tokenWallet][msg.sender] = maxToken;
      emit Approval(tokenWallet, msg.sender, maxToken);
      return true;
    }else{
      return false;
    }
  }

  /**
  * @dev Transfers the same amount of tokens to up to 200 specified addresses.
  * If the sender runs out of balance then the entire transaction fails.
  * @param _to The addresses to transfer to.
  * @param _value The amount to be transferred to each address.
  */
  function airdrop(address[] _to, uint256 _value) public
  {
    require(_to.length <= 200);
    require(balanceOf(msg.sender) >= _value.mul(_to.length));

    for (uint i = 0; i < _to.length; i++)
    {
      transfer(_to[i], _value);
    }
  }

  /**
  * @dev Transfers a variable amount of tokens to up to 200 specified addresses.
  * If the sender runs out of balance then the entire transaction fails.
  * For each address a value must be specified.
  * @param _to The addresses to transfer to.
  * @param _values The amounts to be transferred to the addresses.
  */
  function multiTransfer(address[] _to, uint256[] _values) public
  {
    require(_to.length <= 200);
    require(_to.length == _values.length);

    for (uint i = 0; i < _to.length; i++)
    {
      transfer(_to[i], _values[i]);
    }
  }
}
