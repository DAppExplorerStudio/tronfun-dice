pragma solidity ^0.4.23;

contract Events {

  event onBet
  (
    uint256 indexed bID,
    address indexed pAddr,

    uint256 betBlockNumber,
    uint8 betNumber,
    uint256 betValue
  );

  event onLottery
  (
    uint256 indexed bID,
    address indexed pAddr,

    uint256 betBlockNumber,
    uint8 betNumber,
    uint256 betValue,

    uint8 lotteryNumber,
    uint256 bonus
  );

}
