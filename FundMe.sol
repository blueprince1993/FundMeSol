// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
1.创建一个人收款函数:fund
2.记录投资人并可查看
3.在锁定期内，达到目标值，生产商可以提款
4.锁定期结束时，没有达到目标值，投资人可以退款
*/
contract FundMe {
    mapping (address=>uint256) public funders2Amount;

    uint256 MINIMUM_VALUE = 1*10**18;//wei

    function fund() external payable {
        require(msg.value>MINIMUM_VALUE,"send more ETH");
        funders2Amount[msg.sender]=msg.value;
    }
}