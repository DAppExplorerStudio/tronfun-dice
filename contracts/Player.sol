pragma solidity ^0.4.23;

import "./Core.sol";
import "./ITRC20.sol";

contract Player is Core {

  /** player begin **/
  uint256 public pIDIndex_;
  mapping (address => uint256) public pAddr_pID;
  mapping (uint256 => address) public pID_pAddr_;

  function _determinePID (address _pAddr)
    internal
    returns (uint256)
  {
    uint256 _pID = pAddr_pID[_pAddr];
    if (_pID != 0) {
      return _pID;
    }

    pIDIndex_ = pIDIndex_.add(1);
    pID_pAddr_[pIDIndex_] = _pAddr;
    pAddr_pID[_pAddr] = pIDIndex_;

    return pIDIndex_;
  }

  function getPIDByPAddr(address _pAddr)
    view
    public
    returns (uint256)
  {
    return pAddr_pID[_pAddr];
  }

  function getPAddrByPID(uint256 _pID)
    view
    public
    returns (address)
  {
    return pID_pAddr_[_pID];
  }
  /** player end **/


  /** mint tokens begin **/
  ITRC20 constant public Token = ITRC20(0x419fc6e2d070d01e73474d473b32e418c7cd9d5d5b);

  uint256 constant public TOKENS_MINTED_LEVEL_1 = 1950000000000000;
  uint256 constant public TOKENS_MINTED_LEVEL_2 = 3900000000000000;

  uint256 public tokensMintedTotal_;
  bool public mintTokensEnable_ = true;

  function enableMintTokens ()
    onlyAdministrator
    public
  {
    mintTokensEnable_ = true;
  }

  function disableMintTokens ()
    onlyAdministrator
    public
  {
    mintTokensEnable_ = false;
  }

  function transferTokens (address _pAddr, uint256 _tokens) 
    onlyAdministrator 
    public 
  {
     Token.transfer(_pAddr, _tokens);
  }

  function setTokensMintedTotal (uint256 _tokensMintedTotal) 
    onlyAdministrator 
    public
  {
    tokensMintedTotal_ = _tokensMintedTotal;
  }
  
  function _mintTokens (address _pAddr, uint256 _value)
    internal
  {
    if (!mintTokensEnable_) {
      return;
    }

    uint256 _tokensMinted;
    if (tokensMintedTotal_ <= TOKENS_MINTED_LEVEL_1) {
      _tokensMinted = _value;
    } else if (tokensMintedTotal_ <= TOKENS_MINTED_LEVEL_2) {
      _tokensMinted = _value.mul(3).div(4);
    } else {
      _tokensMinted = _value.div(2);
    }

    tokensMintedTotal_ = tokensMintedTotal_.add(_tokensMinted);

    Token.transfer(_pAddr, _tokensMinted);
  }
  /** mint tokens end **/


  /** prize pot begin **/
  uint256 public prizePot_;

  function withdrawPrizePot (uint256 _value)
    onlyAdministrator
    public
  {
    prizePot_ = prizePot_.sub(_value);
    msg.sender.transfer(_value);
  }

  function _distributePrizePot (uint256 _value) 
    internal
  {
    prizePot_ = prizePot_.add(_value);
  }
  /** prize pot end **/


  /** profits pot begin **/
  uint256 public profitsPot_;

  function withdrawProfitsPot (uint256 _value)
    onlyAdministrator
    public
  {
    profitsPot_ = profitsPot_.sub(_value);
    msg.sender.transfer(_value);
  }

  function _distributeProfitsPot (uint256 _value) 
    internal
  {
    profitsPot_ = profitsPot_.add(_value);
  }
  /** profits pot end **/


  /** invite begin **/
  mapping (address => address) public pAddr_inviterPAddr_;
  mapping (address => uint256) public pAddr_inviteRewards_;
  mapping (address => uint256) public pAddr_inviteRewardsTotal_;

  function getInviterPAddrByPAddr (address _pAddr)
    view
    public 
    returns (address)
  {
    return pAddr_inviterPAddr_[_pAddr];
  }

  function getInviterRewardsByPAddr (address _pAddr)
    view
    public 
    returns (uint256)
  {
    return pAddr_inviteRewards_[_pAddr];
  }

  function withdrawInviteRewards ()
    isActivated
    public 
  {
    address _pAddr = msg.sender;
    uint256 _inviteRewards = pAddr_inviteRewards_[_pAddr];

    require (_inviteRewards > 0);
    
    pAddr_inviteRewards_[_pAddr] = 0;

    _pAddr.transfer(_inviteRewards);
  }

  function _determineInviter (address _pAddr, address _inviterPAddr) 
    internal
  {
    if (pAddr_totalIn_[_pAddr] > 0) {
      return;
    }

    pAddr_inviterPAddr_[_pAddr] = _inviterPAddr;
  }

  function _distributeInviteRewards (address _pAddr, uint256 _value) 
    internal
  {
    address _inviterPAddr = pAddr_inviterPAddr_[_pAddr];
    if (_inviterPAddr != address(0)) {
      pAddr_inviteRewards_[_inviterPAddr] = pAddr_inviteRewards_[_inviterPAddr].add(_value);
      pAddr_inviteRewardsTotal_[_inviterPAddr] = pAddr_inviteRewardsTotal_[_inviterPAddr].add(_value);
    } else {
      _distributeJackPot(_value);
    }
  }
  /** invite end **/


  /** total in begin **/
  mapping (address => uint256) public pAddr_totalIn_;
  uint256 public totalIn_;

  function totalInOfByPAddr(address _pAddr)
    view
    public
    returns (uint256)
  {
    return pAddr_totalIn_[_pAddr];
  }

  function totalInOfByPID(uint256 _pID)
    view
    public
    returns (uint256)
  {
    return pAddr_totalIn_[pID_pAddr_[_pID]];
  }
  /** total in end **/

}