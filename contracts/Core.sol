pragma solidity ^0.4.23;

import "./Admin.sol";
import "./Datasets.sol";
import "./Events.sol";

contract Core is Admin, Events {

  uint256 public bIDIndex_;
  mapping (address => uint256[]) public addr_bIDs_;
  mapping (uint256 => Datasets.Bet) public bID_bet_;

  function getBet (uint256 _bID) 
    public
    view
    returns (uint256, address, uint256, uint8, uint256, bool, uint8, uint256) 
  {
    Datasets.Bet memory _bet = bID_bet_[_bID];
    
    return
    (
      _bet.bID,
      _bet.pAddr,

      _bet.betBlockNumber,
      _bet.betNumber,
      _bet.betValue,

      _bet.drawn,
      _bet.lotteryNumber,
      _bet.bonus
    );
  }

  function getAllBIDsLength ()
    public
    view 
    returns (uint256) 
  {
    return addr_bIDs_[msg.sender].length;
  }

  function getAllBIDs ()
    public
    view 
    returns (uint256[]) 
  {
    return addr_bIDs_[msg.sender];
  }

  function getBIDsByIndex (uint256 _startIndex, uint256 _endIndex)
    public
    view 
    returns (uint256[]) 
  {
    uint256[] memory _bIDs = new uint256[](_endIndex.add(1).sub(_startIndex));
    for (uint256 i = _startIndex; i <= _endIndex; i++) {
      _bIDs[i.sub(_startIndex)] = addr_bIDs_[msg.sender][i];
    }
    return _bIDs;
  }

  /** jack pot begin **/
  uint256 public jackPot_;

  function depositJackPot () 
    public
    payable 
  {    
    jackPot_ = jackPot_.add(msg.value);
  }

  function withdrawJackPot (uint256 _value)
    onlyAdministrator
    public
  {
    jackPot_ = jackPot_.sub(_value);
    msg.sender.transfer(_value);
  }

  function _distributeJackPot (uint256 _value) 
    internal
  {
    jackPot_ = jackPot_.add(_value);
  }
  /** jack pot end **/

}