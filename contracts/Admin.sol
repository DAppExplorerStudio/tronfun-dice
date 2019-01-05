pragma solidity ^0.4.23;

import "./SafeMath.sol";

contract Admin {

  using SafeMath for *;
  
  /** administrator begin **/
  address public owner_;
  mapping (address => bool) public administrators_;
    
  modifier onlyOwner ()
  {
    require (msg.sender == owner_);
    _;
  }
  
  modifier onlyAdministrator ()
  {
    require (administrators_[msg.sender]);
    _;
  }
  
  function setAdministrator (address _address, bool _state)
    onlyOwner
    public
  {
    administrators_[_address] = _state;
  }
  /** administrator end **/


  /** active begin **/
  bool public activated_ = true;

  modifier isActivated () {
    require (activated_ == true); 
    _;
  }

  function activate ()
    onlyAdministrator
    public
  {
    activated_ = true;
  }

  function pause ()
    onlyAdministrator
    public
  {
    activated_ = false;
  }
  /** active end **/
  
}