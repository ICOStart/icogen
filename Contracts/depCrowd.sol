pragma solidity ^0.4.21;

import "./SafeMath.sol";
import "./Pausable.sol";
import "./ERC20.sol";

contract crowdsaleContract is Pausable {
  using SafeMath for uint256;

  struct Period {
    uint256 startTimestamp;
    uint256 endTimestamp;
    uint256 rate;
  }

  Period[] private periods;

  ERC20 public token;
  address public wallet;
  address public tokenWallet;
  uint256 public weiRaised;

  /**
   * @dev A purchase was made.
   * @param _purchaser Who paid for the tokens.
   * @param _value Total purchase price in weis.
   * @param _amount Amount of tokens purchased.
   */
  event TokensPurchased(address indexed _purchaser, uint256 _value, uint256 _amount);

  /**
   * @dev Constructor, takes initial parameters.
   * @param _wallet Address where collected funds will be forwarded to.
   * @param _token Address of the token being sold.
   * @param _tokenWallet Address holding the tokens, which has approved allowance to this contract.
   */
  function crowdsaleContract (address _wallet, address _token, address _tokenWallet, uint maxToken, address realOwner) public {
    require(_wallet != address(0));
    require(_token != address(0));
    require(_tokenWallet != address(0));
    transferOwnership(realOwner);
    wallet = _wallet;
    token = ERC20(_token);
    tokenWallet = _tokenWallet;
    require(token.setCrowdsale(_tokenWallet, maxToken));
  }

  /**
   * @dev Send weis, get tokens.
   */
  function () external payable {
    // Preconditions.
    require(msg.sender != address(0));
    require(isOpen());
    uint256 tokenAmount = getTokenAmount(msg.value);
    if(tokenAmount > remainingTokens()){
      revert();
    }
    weiRaised = weiRaised.add(msg.value);

    token.transferFrom(tokenWallet, msg.sender, tokenAmount);
    emit TokensPurchased(msg.sender, msg.value, tokenAmount);

    wallet.transfer(msg.value);
  }

  /**
   * @dev Add a sale period with its default rate.
   * @param _startTimestamp Beginning of this sale period.
   * @param _endTimestamp End of this sale period.
   * @param _rate Rate at which tokens are sold during this sale period.
   */
  function addPeriod(uint256 _startTimestamp, uint256 _endTimestamp, uint256 _rate) onlyOwner public {
    require(_startTimestamp != 0);
    require(_endTimestamp > _startTimestamp);
    require(_rate != 0);
    Period memory period = Period(_startTimestamp, _endTimestamp, _rate);
    periods.push(period);
  }

  /**
   * @dev Emergency function to clear all sale periods (for example in case the sale is delayed).
   */
  function clearPeriods() onlyOwner public {
    delete periods;
  }

  /**
   * @dev True while the sale is open (i.e. accepting contributions). False otherwise.
   */
  function isOpen() view public returns (bool) {
    return ((!paused) && (_getCurrentPeriod().rate != 0));
  }

  /**
   * @dev Current rate for the specified purchaser.
   * @return Custom rate for the purchaser, or current standard rate if no custom rate was whitelisted.
   */
  function getCurrentRate() public view returns (uint256 rate) {
    Period memory currentPeriod = _getCurrentPeriod();
    require(currentPeriod.rate != 0);
    rate = currentPeriod.rate;
  }

  /**
   * @dev Number of tokens that a specified address would get by sending right now
   * the specified amount.
   * @param _weiAmount Value in wei to be converted into tokens.
   * @return Number of tokens that can be purchased with the specified _weiAmount.
   */
  function getTokenAmount(uint256 _weiAmount) public view returns (uint256) {
    return _weiAmount.mul(getCurrentRate());
  }

  /**
   * @dev Checks the amount of tokens left in the allowance.
   * @return Amount of tokens remaining for sale.
   */
  function remainingTokens() public view returns (uint256) {
    return token.allowance(tokenWallet, this);
  }

  /*
   * Internal functions
   */

  /**
   * @dev Returns the current period, or null.
   */
  function _getCurrentPeriod() view internal returns (Period memory _period) {
    _period = Period(0, 0, 0);
    uint256 len = periods.length;
    for (uint256 i = 0; i < len; i++) {
      if ((periods[i].startTimestamp <= block.timestamp) && (periods[i].endTimestamp >= block.timestamp)) {
        _period = periods[i];
        break;
      }
    }
  }

}
