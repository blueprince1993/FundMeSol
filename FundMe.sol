// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;


import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";


/*
1.创建一个人收款函数:fund
2.记录投资人并可查看
3.在锁定期内，达到目标值，生产商可以提款
4.锁定期结束时，没有达到目标值，投资人可以退款
*/
contract FundMe {
    mapping (address=>uint256) public funders2Amount;

    uint256 MINIMUM_VALUE = 100*10**18;//wei

    AggregatorV3Interface internal dataFeed;

    uint256 constant TARGET = 1000*10**18;

    address public owner;

    //构造函数
    constructor() {
        owner = msg.sender;
        dataFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
    }

    //收款函数:fund
    function fund() external payable {
        require(convertETH2USD(msg.value)>MINIMUM_VALUE,"send more ETH");
        funders2Amount[msg.sender]=msg.value;
    }

    //转换
    function convertETH2USD(uint256 ethAmount) internal view returns(uint256) {
        uint256 ethPrice = uint256(getChainlinkDataFeedLatestAnswer());
        return ethPrice*ethAmount;
    }

    //在锁定期内，达到目标值，生产商可以提款
    function getFund() external {
        require(convertETH2USD(address(this).balance) >= TARGET, "Target is not reached");
        //转账
        //transfer: transfer ETH and revert if transction failed
        payable(msg.sender).transfer(address(this).balance);
        require(msg.sender == owner,"this function can only be called by owner");
        //send: transfer ETH and return false if transction failed
        //call在所有情况都可以使用call，call可以有参数
    }

    function transferOwnership(address newOwner) public {
        require(msg.sender == owner,"this function can only be called by owner");
        owner = newOwner;
    }

    
    function getChainlinkDataFeedLatestAnswer() public view returns (int) {
        // prettier-ignore
        (
            /* uint80 roundID */,
            int answer,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = dataFeed.latestRoundData();
        return answer;
    }
}

/*
链上合约无法获取链下的信息：预言机
需要第三方的机构或服务，来把链下信息，放到链上
区块链无法获取链下信息原因：共识机制
由于链下信息上链也是单点，面临攻击，服务暂停等问题，因此从多个节点取数据：DON：去中心化数据网络（chainlink）
*/