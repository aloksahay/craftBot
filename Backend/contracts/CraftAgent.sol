// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CraftAgent is Ownable {
    // Subscription fee in ETH
    uint256 public constant MONTHLY_FEE = 0.01 ether;
    
    // Creator struct to track their content and earnings
    struct Creator {
        address payable walletAddress;
        uint256 totalViews;
        uint256 totalEarnings;
        bool isActive;
    }
    
    // Content struct to store video metadata
    struct Content {
        string videoCID;
        string modelCID;
        string title;
        string[] tags;
        address creator;
        uint256 views;
        uint256 timestamp;
    }
    
    // Mapping of content IDs to Content
    mapping(uint256 => Content) public contents;
    uint256 public contentCount;
    
    // Mapping of CIDs to content IDs
    mapping(string => uint256) public cidToContentId;
    
    // Mapping of addresses to subscription end time
    mapping(address => uint256) public subscriptionEndTime;
    
    // Mapping of creator addresses to Creator structs
    mapping(address => Creator) public creators;
    
    // Events
    event ContentUploaded(uint256 indexed contentId, address indexed creator, string videoCID);
    event NewSubscription(address indexed subscriber, uint256 endTime);
    event CreatorPaid(address indexed creator, uint256 amount);
    
    constructor() Ownable(msg.sender) {}
    
    // Upload new content
    function uploadContent(
        string memory _videoCID,
        string memory _modelCID,
        string memory _title,
        string[] memory _tags
    ) external {
        require(bytes(_videoCID).length > 0, "Invalid video CID");
        require(bytes(_modelCID).length > 0, "Invalid model CID");
        
        // Store CID mapping
        cidToContentId[_videoCID] = contentCount;
        
        // Create or update creator
        if (!creators[msg.sender].isActive) {
            creators[msg.sender] = Creator({
                walletAddress: payable(msg.sender),
                totalViews: 0,
                totalEarnings: 0,
                isActive: true
            });
        }
        
        // Store content
        contents[contentCount] = Content({
            videoCID: _videoCID,
            modelCID: _modelCID,
            title: _title,
            tags: _tags,
            creator: msg.sender,
            views: 0,
            timestamp: block.timestamp
        });
        
        emit ContentUploaded(contentCount, msg.sender, _videoCID);
        contentCount++;
    }
    
    // Subscribe to premium service
    function subscribe() external payable {
        require(msg.value == MONTHLY_FEE, "Incorrect subscription fee");
        
        uint256 newEndTime;
        if (subscriptionEndTime[msg.sender] > block.timestamp) {
            // Extend existing subscription
            newEndTime = subscriptionEndTime[msg.sender] + 30 days;
        } else {
            // New subscription
            newEndTime = block.timestamp + 30 days;
        }
        
        subscriptionEndTime[msg.sender] = newEndTime;
        emit NewSubscription(msg.sender, newEndTime);
    }
    
    // Check if an address has an active subscription
    function hasActiveSubscription(address user) public view returns (bool) {
        return subscriptionEndTime[user] > block.timestamp;
    }
    
    // Record a view and update creator stats
    function recordView(uint256 contentId) external {
        require(contentId < contentCount, "Content does not exist");
        require(hasActiveSubscription(msg.sender), "No active subscription");
        
        Content storage content = contents[contentId];
        content.views++;
        creators[content.creator].totalViews++;
    }
    
    // Distribute earnings to creators (called periodically)
    function distributeEarnings() external onlyOwner {
        uint256 totalBalance = address(this).balance;
        require(totalBalance > 0, "No earnings to distribute");
        
        uint256 totalViews = 0;
        for (uint256 i = 0; i < contentCount; i++) {
            totalViews += contents[i].views;
        }
        
        require(totalViews > 0, "No views recorded");
        
        for (uint256 i = 0; i < contentCount; i++) {
            Content storage content = contents[i];
            if (content.views > 0) {
                uint256 creatorShare = (totalBalance * content.views) / totalViews;
                creators[content.creator].totalEarnings += creatorShare;
                creators[content.creator].walletAddress.transfer(creatorShare);
                emit CreatorPaid(content.creator, creatorShare);
            }
        }
    }
} 