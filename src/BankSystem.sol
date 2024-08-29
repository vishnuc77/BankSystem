pragma solidity ^0.8.26;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BankSystem is Ownable {
    mapping(address account => uint256) private _balances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    struct Transaction {
        address sender;
        address recipient;
        uint amount;
    }

    
    uint public toBeApproved;
    mapping(uint => Transaction) public requests;

    error ERC20InsufficientBalance(address sender, uint256 balance, uint256 needed);

    event Deposited(address recipient, uint amount);
    event Transferred(address sender, address recipient, uint amount);

    constructor(string memory name, string memory symbol, address initialOwner) Ownable(initialOwner) {
        _name = name;
        _symbol = symbol;
        _balances[initialOwner] = 1000000000;
        _totalSupply = 1000000000;
    }

    function balanceOf(address account) public view virtual returns (uint256) {
        return _balances[account];
    }

    function deposit(address toAddress, uint amount) public {
        requests[toBeApproved] = Transaction(address(0), toAddress, amount);
        toBeApproved += 1;
    }

    function transferFrom(address fromAddress, address toAddress, uint amount) public {
        requests[toBeApproved] = Transaction(fromAddress, toAddress, amount);
        toBeApproved += 1;
    }

    function approve(uint requestId) public onlyOwner {
        Transaction memory transaction = requests[requestId];
        if (transaction.sender == address(0)) {
            _balances[transaction.recipient] += transaction.amount;
            _totalSupply += transaction.amount;
            emit Deposited(transaction.recipient, transaction.amount);
        } else {
            _transfer(transaction.sender, transaction.recipient, transaction.amount);
            emit Transferred(transaction.sender, transaction.recipient, transaction.amount);
        }
    }

    function _transfer(address from, address to, uint256 value) internal {
        if (from == address(0)) {
            _totalSupply += value;
        } else {
            uint256 fromBalance = _balances[from];
            if (fromBalance < value) {
                revert ERC20InsufficientBalance(from, fromBalance, value);
            }
            unchecked {
                _balances[from] = fromBalance - value;
            }
        }

        if (to == address(0)) {
            unchecked {
                _totalSupply -= value;
            }
        } else {
            unchecked {
                _balances[to] += value;
            }
        }
    }
}