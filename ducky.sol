// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Ducky {
    struct User {
        address userAddress;
        string username;
        string bio;
        uint256[] posts;
        mapping(address => bool) following;
    }

    struct Post {
        uint256 id;
        address author;
        string content;
        uint256 timestamp;
        uint256 likes;
    }

    mapping(address => User) public users;
    mapping(uint256 => Post) public posts;
    uint256 public postCount;

    event UserRegistered(address indexed userAddress, string username);
    event PostCreated(uint256 indexed postId, address indexed author, string content, uint256 timestamp);
    event PostLiked(uint256 indexed postId, address indexed user);

    modifier userExists(address userAddress) {
        require(bytes(users[userAddress].username).length > 0, "User does not exist.");
        _;
    }

    function registerUser(string memory _username, string memory _bio) public {
        require(bytes(_username).length > 0, "Username is required.");
        require(bytes(users[msg.sender].username).length == 0, "User already registered.");

        User storage user = users[msg.sender];
        user.userAddress = msg.sender;
        user.username = _username;
        user.bio = _bio;

        emit UserRegistered(msg.sender, _username);
    }

    function createPost(string memory _content) public userExists(msg.sender) {
        require(bytes(_content).length > 0, "Content cannot be empty.");

        postCount++;
        Post storage newPost = posts[postCount];
        newPost.id = postCount;
        newPost.author = msg.sender;
        newPost.content = _content;
        newPost.timestamp = block.timestamp;
        newPost.likes = 0;

        users[msg.sender].posts.push(postCount);

        emit PostCreated(postCount, msg.sender, _content, block.timestamp);
    }

    function likePost(uint256 _postId) public userExists(msg.sender) {
        require(_postId > 0 && _postId <= postCount, "Post does not exist.");

        Post storage post = posts[_postId];
        post.likes++;

        emit PostLiked(_postId, msg.sender);
    }

    function followUser(address _userAddress) public userExists(msg.sender) userExists(_userAddress) {
        require(_userAddress != msg.sender, "You cannot follow yourself.");
        users[msg.sender].following[_userAddress] = true;
    }

    function unfollowUser(address _userAddress) public userExists(msg.sender) userExists(_userAddress) {
        require(users[msg.sender].following[_userAddress], "You are not following this user.");
        users[msg.sender].following[_userAddress] = false;
    }

    function getUserPosts(address _userAddress) public view userExists(_userAddress) returns (uint256[] memory) {
        return users[_userAddress].posts;
    }

    function isFollowing(address _userAddress) public view userExists(msg.sender) userExists(_userAddress) returns (bool) {
        return users[msg.sender].following[_userAddress];
    }
}
