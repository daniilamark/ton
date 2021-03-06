
/**
 * This file was generated by TONDev.
 * TONDev is a part of TON OS (see http://ton.dev).
 */
pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

// This is class that describes you smart contract.
contract bookToken {

    struct Token{
        string title;
        string author;
        uint numPages;
        uint price;
    }

    Token[] tokensArr;
    mapping (uint => uint) tokenToOwner;

    constructor() public {
        require(tvm.pubkey() != 0, 101);
        require(msg.pubkey() == tvm.pubkey(), 102);
        tvm.accept();
    }

    modifier checkOwnerAndAccept {
        require(msg.pubkey() == tvm.pubkey(), 100);
		tvm.accept();
		_;
	}

    // name match check
    modifier checkTitleMatches(string title) {
        for (uint256 index = 0; index < tokensArr.length; index++) {
            require(tokensArr[index].title != title, 101);
        }
		tvm.accept();
		_;
	}

    // function to create a token
    function createToken(string _title, string author, uint numPages, uint price) public checkTitleMatches(_title){
        tokensArr.push(Token(_title, author, numPages, price));
        uint keyAsLastNum = tokensArr.length - 1;
        tokenToOwner[keyAsLastNum] = msg.pubkey();
    }
    
    // function to get the owner of the token
    function getTokenOwner(uint tokenId) public view returns(uint){
        tvm.accept();
        return tokenToOwner[tokenId];
    } 

    // function to change the owner of a token
    function changeOwner(uint tokenId, uint pubKeyOfNewOwner) public checkOwnerAndAccept{
        tokenToOwner[tokenId] = pubKeyOfNewOwner;
    }
    
    // function to get all information about a token
    function getTokenInfo(uint tokenId) public view returns (string tokenTitle, string tokenAuthor, uint tokenNumPages, uint tokenPrice){
        // tvm.accept();
        tokenTitle = tokensArr[tokenId].title;
        tokenAuthor = tokensArr[tokenId].author;
        tokenNumPages = tokensArr[tokenId].numPages;
        tokenPrice = tokensArr[tokenId].price;
    }

    // function to get the price of a token
    function getTokenPrice(uint tokenId) public view returns(uint tokenPrice) {
        // tvm.accept();
        tokenPrice = tokensArr[tokenId].price;
    }

    // function for changing the token price
    function setTokenPrice(uint tokenId, uint newTokenPrice) public checkOwnerAndAccept{
        tokensArr[tokenId].price = newTokenPrice;
    }

}
