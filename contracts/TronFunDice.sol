pragma solidity ^0.4.23;

import "./Player.sol";

/// @title Contract of TronFun Dice (https://tronfun.io/dice)
/// @author DApp Explorer Studio (https://github.com/DAppExplorerStudio)
/// @dev See the TronFun Dice documentation to understand everything
contract TronFunDice is Player {

  constructor ()
    public 
  {
    owner_ = msg.sender;
    administrators_[owner_] = true;

    _determinePID(owner_);
  }

  function bet (uint8 _betNumber, address _inviterPAddr)
    isActivated
    public
    payable 
  {
    require (_betNumber > 0 && _betNumber < 96);
    
    address _pAddr = msg.sender;
    uint256 _betValue = msg.value;
    uint256 _betBlockNumber = block.number;

    require (_betValue >= 100 trx && _betValue <= jackPot_.div(50));

    // pid and inviter
    _determinePID(_pAddr);
    _determineInviter(_pAddr, _inviterPAddr);

    // jack pot (98% + 1.5% * 0.3)
    _distributeJackPot(_betValue.mul(9845).div(10000));
    // prize pot (1.5% * 0.2)
    _distributePrizePot(_betValue.mul(30).div(10000));
    // profits pot (1.5% * 0.5)
    _distributeProfitsPot(_betValue.mul(75).div(10000));
    // invite rewards （0.5%）
    _distributeInviteRewards(_pAddr, _betValue.mul(50).div(10000));

    bIDIndex_ = bIDIndex_.add(1);
    bID_bet_[bIDIndex_].bID = bIDIndex_;
    bID_bet_[bIDIndex_].pAddr = _pAddr;
    bID_bet_[bIDIndex_].betBlockNumber = _betBlockNumber;
    bID_bet_[bIDIndex_].betNumber = _betNumber;
    bID_bet_[bIDIndex_].betValue = _betValue;
    addr_bIDs_[_pAddr].push(bIDIndex_);

    _mintTokens(_pAddr, _betValue);

    pAddr_totalIn_[_pAddr] = pAddr_totalIn_[_pAddr].add(_betValue);
    totalIn_ = totalIn_.add(_betValue);

    emit Events.onBet
    (
      bIDIndex_,
      _pAddr,

      _betBlockNumber,
      _betNumber,
      _betValue
    );
  }
  
  function lottery (uint256 _bID, uint8 _lotteryNumber)
    onlyAdministrator 
    public
  {
    Datasets.Bet memory _bet = bID_bet_[_bID];

    require (_bet.bID != 0);
    require (!_bet.drawn);
    require (block.number.sub(_bet.betBlockNumber) > 1);

    bID_bet_[_bID].drawn = true;
    bID_bet_[_bID].lotteryNumber = _lotteryNumber;

    uint256 _bouns;
    if (_lotteryNumber < _bet.betNumber) {
      _bouns = _bet.betValue.mul(98).div(_bet.betNumber);
      bID_bet_[_bID].bonus = _bouns;
      jackPot_ = jackPot_.sub(_bouns);
      _bet.pAddr.transfer(_bouns);
    }
  
    emit Events.onLottery
    (
      _bID,
      _bet.pAddr,

      _bet.betBlockNumber,
      _bet.betNumber,
      _bet.betValue,

      _lotteryNumber,
      _bouns
    );
  }

}