pragma solidity ^0.4.23;

library Datasets {

  struct Bet {
    uint256 bID;
    address pAddr;

    uint256 betBlockNumber;
    uint8 betNumber;
    uint256 betValue;

    bool drawn;
    uint8 lotteryNumber;
    uint256 bonus;
  }

}