pragma solidity ^0.4.18;

import "github.com/OpenZeppelin/zeppelin-solidity/contracts/math/SafeMath.sol";
import "github.com/OpenZeppelin/zeppelin-solidity/contracts/ownership/Ownable.sol";
import "github.com/OpenZeppelin/zeppelin-solidity/contracts/lifecycle/Pausable.sol";

contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract BasicToken is ERC20Basic {
  using SafeMath for uint256;
    
  mapping (address => uint256) balances;
  uint256 totalSupply_;
  
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }
  
    /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of. 
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }
}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
}

contract BurnableToken is BasicToken {

  event Burn(address indexed burner, uint256 value);

  /**
   * @dev Burns a specific amount of tokens.
   * @param _value The amount of token to be burned.
   */
  function burn(uint256 _value) public {
    require(_value <= balances[msg.sender]);
    // no need to require value <= totalSupply, since that would imply the
    // sender's balance is greater than the totalSupply, which *should* be an assertion failure

    address burner = msg.sender;
    balances[burner] = balances[burner].sub(_value);
    totalSupply_ = totalSupply_.sub(_value);
    emit Burn(burner, _value);
    emit Transfer(burner, address(0), _value);
  }
}

contract StandardToken is ERC20, BurnableToken {

  mapping (address => mapping (address => uint256)) allowed;

  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    
    require(_to != address(0));
    require(_value <= balances[msg.sender]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_to] = balances[_to].add(_value);
    balances[_from] = balances[_from].sub(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);

    emit Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Aprove the passed address to spend the specified amount of tokens on behalf of msg.sender.
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifing the amount of tokens still avaible for the spender.
   */
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }
  
}

contract BittechToken is StandardToken {

  string constant public name = "Bittech Token";
  string constant public symbol = "BTECH";
  uint256 constant public decimals = 18;

  address constant public bountyWallet = 0x8E8d4cdADbc027b192DfF91c77382521B419E5A2;
  uint256 public bountyPart = uint256(1000000).mul(10 ** decimals);
  address constant public adviserWallet = 0x1B9D19Af310E8cB35D0d3B8977b65bD79C5bB299;
  uint256 public adviserPart = uint256(1500000).mul(10 ** decimals);
  address constant public reserveWallet = 0xa323DA182fDfC10861609C2c98894D9745ABAB91;
  uint256 public reservePart = uint256(10000000).mul(10 ** decimals);
  address constant public ICOWallet = 0x1ba99f4F5Aa56684423a122D72990A7851AaFD9e;
  uint256 public ICOPart = uint256(25000000).mul(10 ** decimals);
  uint256 public PreICOPart = uint256(5000000).mul(10 ** decimals);
  address constant public teamWallet = 0x69548B7740EAf1200312d803f8bDd04F77523e09;
  uint256 public teamPart = uint256(7500000).mul(10 ** decimals);

  uint256 constant public yearSeconds = 31536000; // 60*60*24*365 = 31536000
  uint256 constant public secsPerBlock = 14; // 1 block per 14 seconds
  uint256 public INITIAL_SUPPLY = uint256(50000000).mul(10 ** decimals); // 50 000 000 tokens

  uint256 public withdrawTokens = 0;
  uint256 public startTime;

  function BittechToken() public {
    totalSupply_ = INITIAL_SUPPLY;

    balances[bountyWallet] = bountyPart;
    emit Transfer(this, bountyWallet, bountyPart); // 1

    balances[adviserWallet] = adviserPart;
    emit Transfer(this, adviserWallet, adviserPart); // 1.5

    balances[reserveWallet] = reservePart;
    emit Transfer(this, reserveWallet, reservePart); // 10

    balances[ICOWallet] = ICOPart;
    emit Transfer(this, ICOWallet, ICOPart); // 25

    balances[msg.sender] = PreICOPart;
    emit Transfer(this, msg.sender, PreICOPart); // 5

    balances[this] = teamPart;
    emit Transfer(this, this, teamPart); // 7.5

    startTime = block.number;
  }

  modifier onlyTeam() {
    require(msg.sender == teamWallet);
    _;
  }

  function viewTeamTokens() public view returns (uint256) {

    if (block.number >= startTime.add(yearSeconds.div(secsPerBlock))) {
      return 2500000;
    }

    if (block.number >= startTime.add(yearSeconds.div(secsPerBlock).mul(2))) {
      return 5000000;
    }

    if (block.number >= startTime.add(yearSeconds.div(secsPerBlock).mul(3))) {
      return 7500000;
    }

  }

  function getTeamTokens(uint256 _tokens) public onlyTeam {
    uint256 tokens = _tokens.mul(10 ** decimals);
    require(withdrawTokens.add(tokens) <= viewTeamTokens().mul(10 ** decimals));
    transfer(teamWallet, tokens);
    emit Transfer(this, teamWallet, tokens);
    withdrawTokens = withdrawTokens.add(tokens);
  }
  
}

contract BittechPresale is Pausable {
    using SafeMath for uint256;

    BittechToken public tokenReward;
    mapping(address => uint256) public balanceOf;
    mapping(address => uint256) public balanceOfUSD;
    uint256 constant public USDSoftCap = 100000; // 100 000 $
    uint256 constant public tokenHardCap = 5000000000000000000000000; // 5 mln tokens
    uint256 constant public decimals = 1000000000000000000; // 10 ** 18
    uint256 public tokensRaised = 0;
    uint256 public USDRaised = 0;
    uint256 public minimalPriceUSD = 2000;
    uint256 public ETHUSD = 380;
    uint256 public tokenPricePerUSD = 100;
    bool public presaleFinished = false;
    bool public softCapRaised = false;
    
    modifier whenNotFinished() {
        require(!presaleFinished);
        _;
    }

    modifier whenFinished() {
        require(presaleFinished);
        _;
    }

    function BittechPresale(address _tokenReward) public {
        tokenReward = BittechToken(_tokenReward);
    }
    
    function () public payable {
        buy(msg.sender);
    }

    function getBonus(address investor) public view returns (uint256) {
        if (balanceOfUSD[investor] <= 10000) return 100;
        else if (balanceOfUSD[investor] <= 30000) return 110;
        else if (balanceOfUSD[investor] <= 50000) return 120;
        else if (balanceOfUSD[investor] <= 100000) return 130;
        else return 140;
    }

    function buy(address buyer) whenNotPaused whenNotFinished public payable {

        require(buyer != address(0));
        require(msg.value.mul(ETHUSD) >= minimalPriceUSD.mul(decimals));
        
        uint256 tokens = msg.value.mul(ETHUSD).mul(getBonus(buyer)).div(100).mul(tokenPricePerUSD).div(100);
        tokenReward.transfer(buyer, tokens);
        uint256 receivedDollars = msg.value.mul(ETHUSD).div(decimals);
        balanceOfUSD[buyer] = balanceOfUSD[buyer].add(receivedDollars);
        balanceOf[buyer] = balanceOf[buyer].add(msg.value);

        tokensRaised = tokensRaised.add(tokens);
        USDRaised = USDRaised.add(receivedDollars);

        if (softCapRaised) {
            owner.transfer(msg.value);
        }
        
        if (USDRaised >= USDSoftCap) { // check
            softCapRaised = true;
            owner.transfer(address(this).balance);
        }

        if (tokensRaised >= tokenHardCap) {
            presaleFinished = true;
        }

    }

    function safeWithdrawal() whenFinished public {
        if (!softCapRaised) {
            uint amount = balanceOf[msg.sender];
            msg.sender.transfer(amount);
            balanceOf[msg.sender] = 0;
        }

        if (softCapRaised && owner == msg.sender) {
            owner.transfer(address(this).balance);
        }
    }

    function tokenTransfer(address who, uint256 amount) whenNotFinished onlyOwner public {
        uint256 tokens = amount.mul(decimals);
        tokenReward.transfer(who, tokens);
    }

    function transferFunds() whenFinished onlyOwner public {
        require(softCapRaised);
        owner.transfer(address(this).balance);
    }

    function finishPresale() onlyOwner public {
        presaleFinished = true;
        if (USDRaised >= USDSoftCap) {
            softCapRaised = true;
            owner.transfer(address(this).balance);
        }
        uint256 tokenBalance = tokenReward.balanceOf(address(this));
        tokenReward.burn(tokenBalance);
    }

    function updatePrice(uint256 _ETHUSD) onlyOwner public {
        ETHUSD = _ETHUSD;
    }

    function updateMinimal(uint256 _minimalPriceUSD) onlyOwner public {
        minimalPriceUSD = _minimalPriceUSD;
    }

    function updateTokenPricePerUSD(uint256 _tokenPricePerUSD) onlyOwner public {
        tokenPricePerUSD = _tokenPricePerUSD;
    }

}