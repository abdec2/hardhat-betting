// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

// Pancakeswap
interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    )
        external
        payable
        returns (uint amountToken, uint amountETH, uint liquidity);

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint amountToken, uint amountETH);

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactETHForTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable returns (uint[] memory amounts);

    function swapTokensForExactETH(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactTokensForETH(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapETHForExactTokens(
        uint amountOut,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable returns (uint[] memory amounts);

    function quote(
        uint amountA,
        uint reserveA,
        uint reserveB
    ) external pure returns (uint amountB);

    function getAmountOut(
        uint amountIn,
        uint reserveIn,
        uint reserveOut
    ) external pure returns (uint amountOut);

    function getAmountIn(
        uint amountOut,
        uint reserveIn,
        uint reserveOut
    ) external pure returns (uint amountIn);

    function getAmountsOut(
        uint amountIn,
        address[] calldata path
    ) external view returns (uint[] memory amounts);

    function getAmountsIn(
        uint amountOut,
        address[] calldata path
    ) external view returns (uint[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function swapExactETHForTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable returns (uint[] memory amounts);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

contract Depositor is Initializable, OwnableUpgradeable, UUPSUpgradeable {
    using SafeERC20 for IERC20;

    // **************************
    // variables
    // **************************
    IUniswapV2Router02 public uniswapV2Router;
    mapping(address => bool) public whitelist;
    address public usdToken; //BUSD
    uint256[49] __gap;

    // **************************
    // modifiers
    // **************************
    modifier onlyCreatorOrOwner() {
        require(
            msg.sender == owner() || whitelist[msg.sender] == true,
            "You are not the creator or whitelisted address for this contract"
        );
        _;
    }

    // **************************
    // event
    // **************************
    event Deposit(
        address indexed tokenAddress,
        uint256 amount,
        uint256 amountReceived,
        address indexed sender
    );

    // /////////////////////////////////////////
    //    UPGRADABLE _UUPS
    // /////////////////////////////////////////

    // **************************
    // constructor
    // **************************
    // /// @custom:oz-upgrades-unsafe-allow constructor
    // constructor() {
    //     _disableInitializers();
    // }

    // **************************
    // used in place of constructor
    // **************************

    function initialize(
        address uniswapRouter,
        address _usdToken
    ) public initializer {
        __Ownable_init(0x5baA0f14D09864929c5fC8AbDfDc466dcb72be9d);
        __UUPSUpgradeable_init();
        uniswapV2Router = IUniswapV2Router02(uniswapRouter);
        usdToken = _usdToken;
    }

    // **************************
    // mandatory function
    // **************************

    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyOwner {}

    // /////////////////////////////////////////
    //    UPGRADABLE _UUPS
    // /////////////////////////////////////////

    receive() external payable {
        uint256 amountReceived = convertBnbToToken(
            usdToken,
            msg.value,
            address(this)
        );
        emit Deposit(usdToken, msg.value, amountReceived, msg.sender);
    }

    // **************************
    // Deposit BNB
    // **************************
    function DepositBNB() public payable {
        uint256 amountReceived = convertBnbToToken(
            usdToken,
            msg.value,
            address(this)
        );
        emit Deposit(usdToken, msg.value, amountReceived, msg.sender);
    }

    // **************************
    // withdraw BUSD
    // **************************
    function WithdrawTokens(
        address tokenAddress,
        uint256 amount
    ) public onlyCreatorOrOwner {
        require(
            IERC20(tokenAddress).balanceOf(address(this)) >= amount,
            "Not enough balance"
        );
        IERC20(tokenAddress).safeTransfer(owner(), amount);
    }

    // **************************
    // withdraw BNB
    // **************************
    function WithdrawBNB(uint256 amount) public onlyCreatorOrOwner {
        require(address(this).balance >= amount, "Not enough balance");
        payable(owner()).transfer(amount);
    }

    // **************************
    // Fuctions for owner
    // **************************

    function WithdrawBulkEthToWallets(
        uint256[] memory amounts,
        address[] memory wallets
    ) public onlyCreatorOrOwner {
        for (uint256 i = 0; i < amounts.length; i++) {
            payable(wallets[i]).transfer(amounts[i]);
        }
    }

    // withdraw bulk BUSD tokens to wallets
    function WithdrawBulkTokensToWallets(
        address tokenAddress,
        uint256[] memory amounts,
        address[] memory wallets
    ) public onlyCreatorOrOwner {
        for (uint256 i = 0; i < amounts.length; i++) {
            IERC20(tokenAddress).safeTransfer(wallets[i], amounts[i]);
        }
    }

    // **************************
    // Helper Fuctions
    // **************************
    // convert BNB to busd tokens
    function convertBnbToToken(
        address tokenAddress,
        uint256 amount,
        address wallet
    ) private returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = tokenAddress;
        // get balance currently of BUSD
        uint256 balanceBefore = IERC20(tokenAddress).balanceOf(address(this));
        uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{
            value: amount
        }(0, path, wallet, block.timestamp + 3600);
        // get balance after
        uint256 balanceAfter = IERC20(tokenAddress).balanceOf(address(this));
        // get the difference
        uint256 balanceDiff = balanceAfter - balanceBefore;
        // send the difference to the wallet
        return balanceDiff;
    }

    // **************************
    // Setter Fuctions
    // **************************
    // add whitelisted address
    function editWhitelistAddress(
        address _address,
        bool valid
    ) public onlyOwner {
        whitelist[_address] = valid;
    }

    function changeUsdToken(address _usdToken) public onlyCreatorOrOwner {
        usdToken = _usdToken;
    }

    // **************************
    // testing Fuctions
    // **************************
    function changeRouter(address uniswapRouter) public onlyCreatorOrOwner {
        uniswapV2Router = IUniswapV2Router02(uniswapRouter);
    }
}
