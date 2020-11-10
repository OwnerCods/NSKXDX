pragma solidity ^0.5.17;


        library SafeMath {

                function mul(uint256 _a, uint256 _b) internal pure returns (uint256) {
    
                if (_a == 0) {
                         return 0;
                    }

                    uint256 c = _a * _b;
                    require(c / _a == _b);

                    return c;
                    }


                function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
                require(_b > 0); // Solidity only automatically asserts when dividing by 0
                uint256 c = _a / _b;
                // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold

                return c;
                    }


            function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
                require(_b <= _a);
                uint256 c = _a - _b;

                return c;
                }
        
             function add(uint256 _a, uint256 _b) internal pure returns (uint256) {
                uint256 c = _a + _b;
                require(c >= _a);

                return c;
                }

            function mod(uint256 a, uint256 b) internal pure returns (uint256) {
                require(b != 0);
                return a % b;
                }
            }
            contract Owned{
    address payable public owner;
    address payable private newOwner;
    
    
     
      event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public {
        owner = msg.sender;
        
    }
     
      
    function transferOwnership(address payable _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }

    //this flow is to prevent transferring ownership to wrong wallet by mistake
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
    
    function CEO ()public view returns (address) {
        return owner;
    }
    
    modifier onlyOwner {
      require (msg.sender == owner, "No owner");
       _;
    }
}


contract TTT is Owned {
    using SafeMath for uint;
   
  
       string constant private _name = "TestTT";
       string constant private _simbol = "TTT";
       uint8 constant private  _decimals = 18;
     uint256 private _totalSupply;
    
    function name() public pure returns(string memory){
        return _name;
    }
    
    function symbol() public pure returns(string memory){
        return _simbol;
    }
    
    function decimals() public pure returns(uint8){
        return _decimals;
    }
  
  
    bool internal locker;
    
    modifier noReentrant() {
        require (!locker ,"no retrency");
        locker = true;
        _;
        locker = false;
    }   
  
    function totalSupply() public view  returns (uint256) {
        return _totalSupply/10**18;
    }
    
    mapping(address => uint ) balances;
    mapping(address => mapping(address => uint)) allowed;
   
  
    
    event Transfer(address indexed _from, address indexed  _to, uint _value); 
    event Approval(address indexed _from, address indexed _to, uint _value);
    event Sell(address indexed sender, uint indexed balance, uint amount);
     
   
    
       function allowance (address _owner, address _spender) public view returns (uint){       // показывает сколько можно снимать деньги с адреса отправителя
        return allowed [_owner][_spender];
    }
    
     function approve(address _spender, uint _value) public {             // отправитель даеет разрешение на снятие денег с адреса function transferFrom
            allowed [msg.sender][_spender] = _value;
        emit Approval (msg.sender, _spender, _value);
    }
    
   
    
     
    function mint(address account, uint256 _value)  public  onlyOwner {
        require(account != address(0), "ERC20: mint to the zero address");
        uint value = _value*(10**18);
        _beforeTokenTransfer(address(0), account, value);
        _totalSupply = _totalSupply.add(value);
        balances[account] = balances[account].add(value);
        emit Transfer(address(0), account, value);
    }
    
     
        function _beforeTokenTransfer(address from, address to, uint256 amount) internal pure { }

 function WithdrawTokens(uint256 tokenAmount) public onlyOwner noReentrant{
       
        // no need for overflow checking as that will be done in transfer function
        _transfer(address(this),msg.sender, tokenAmount);
    }


   function withdraw () public onlyOwner noReentrant {
       uint amount = balances[msg.sender];
        balances[msg.sender] = 0;
        msg.sender.transfer(amount);
             address(owner).transfer(address(this).balance);
    }
    
    
     function balanceOf(address sender) public view returns (uint) {         
        return balances[sender];
    }
    
    modifier validDestination( address to ) {
        require(to != address(0x0));
        require(to != address(this) );
        _;
    }
    
    function _transfer(address _from, address _to, uint _value) internal {
        require (_to != address(0));                      // Prevent transfer to 0x0 address. Use burn() instead
        // overflow and undeflow checked by SafeMath Library
       balances[_from] = balances[_from].sub(_value);    // Subtract from the sender
        balances[_to] = balances[_to].add(_value);        // Add the same to the recipient
        
        emit Transfer(_from, _to, _value);
    }
    
    function transfer(address _to, uint256 _value) public  returns (bool success) {
        
        //no need to check for input validations, as that is ruled by SafeMath
        _transfer(msg.sender, _to, _value);
        return true;
    }
    
     function transferFrom(address _from, address spender, uint256 _value) public returns (bool success) {
        //checking of allowance and token value is done by SafeMath
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
       
        _transfer(_from, spender, _value);
        return true;
    }
    
     function ETHcontrBalance () public view returns (uint) {
        return address(this).balance;
        }
        
        function() external { //fallback
    revert();
  }
  
  
}
