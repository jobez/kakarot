// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;
import "./Parent.sol";

interface ICounter {
    function count() external view returns (uint256);

    function inc() external;

    function dec() external;

    function reset() external;
}

/// @notice Contract for integration testing of EVM opcodes.
/// @author Kakarot9000
/// @dev Add functions and storage variables for opcodes accordingly.
contract PlainOpcodes {
    /*//////////////////////////////////////////////////////////////
                            METADATA STORAGE
    //////////////////////////////////////////////////////////////*/
    ICounter counter;
    event Log0() anonymous;
    event Log0Value(uint256 value) anonymous;
    event Log1(uint256 value);
    event Log2(address indexed owner, uint256 value);
    event Log3(address indexed owner, address indexed spender, uint256 value);
    event Log4(
        address indexed owner,
        address indexed spender,
        uint256 indexed value
    );

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/
    constructor(address counterAddress) {
        counter = ICounter(counterAddress);
    }

    /*//////////////////////////////////////////////////////////////
                            FUNCTIONS FOR OPCODES
    //////////////////////////////////////////////////////////////*/
    function opcodeBlockHash(
        uint256 blockNumber
    ) public view returns (bytes32 _blockhash) {
        return (blockhash(blockNumber));
    }

    function opcodeAddress() public view returns (address selfAddress) {
        return (address(this));
    }

    function opcodeStaticCall() public view returns (uint256) {
        return counter.count();
    }

    function opcodeStaticCall2() public view returns (bool, bytes memory) {
        bytes memory data = abi.encodeWithSelector(bytes4(keccak256("inc()")));
        return address(counter).staticcall(data);
    }

    function opcodeCall() public {
        counter.inc();
    }

    function opcodeLog0() public {
        emit Log0();
    }

    function opcodeLog0Value() public {
        emit Log0Value(10);
    }

    function opcodeLog1() public {
        emit Log1(10);
    }

    function opcodeLog2() public {
        emit Log2(address(0xa), 10);
    }

    function opcodeLog3() public {
        emit Log3(address(0xa), address(0xb), 10);
    }

    function opcodeLog4() public {
        emit Log4(address(0xa), address(0xb), 10);
    }

    function create2(
        bytes memory bytecode,
        uint256 salt
    ) public returns (address _address) {
        assembly {
            _address := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
    }

    function requireNotZero(address _address) external pure {
        require(_address != address(0), "ZERO_ADDRESS");
    }

    function originAndSender()
        external
        view
        returns (address origin, address sender)
    {
        return (tx.origin, msg.sender);
    }

    function opcodeExtCodeCopy(
        uint256 offset,
        uint256 size
    ) external view returns (bytes memory extcode) {
        // see https://docs.soliditylang.org/en/v0.8.17/assembly.html#example
        address target = address(counter);
        assembly {
            // Get a free memory location
            extcode := mload(0x40)
            // Update free memory pointer (pointer += size including padding)
            mstore(
                0x40,
                add(extcode, and(add(add(size, 0x20), 0x1f), not(0x1f)))
            )
            // Copy counter code to this location + size
            mstore(extcode, size)
            extcodecopy(target, add(extcode, 0x20), offset, size)
        }
    }

    function testRevertDeletesChildContract() external returns (bool success, bytes memory returnData) {
        Parent parent = new Parent();
        // parent.triggerRevert();

        return address(parent.child()).call(abi.encodeWithSignature("doSomething()"));
    }

    function testRevertViaCall() external returns (address address_, bool triggerRevert ) {
        Parent parent = new Parent();
        // child contract is created in the same execution context as a revert
        
        
        (bool success2, bytes memory data) = address(parent).call(abi.encodeWithSignature("triggerRevert()"));

        require(!success2, "trigger revert... should revert");        
         
        /* (bool success, bytes memory data_) = address(parent.child()).call(abi.encodeWithSignature("doSomething()")); */

        /* require(!success, "should be no child contract to do something"); */
        return (address(parent.child()), success2);
    }

    function testCallingContextCanCatchRevertsFromSubContext() public {
        Parent parent = new Parent();
        
        try parent.triggerRevert() { 
            // The `doSomething` function is expected to revert. 
            revert("always revert"); 
        } catch { 
            // Ensure that the created child contract in parent is deleted. 
            //  
            require(address(parent.child()) == address(0), "Parent is deleted"); 
        } 
    }

    function testCallingContextCanCatchRevertsFromSubContextAndPropogateRevertMessage() public {
        Parent parent = new Parent();
    

    
        try parent.triggerRevert() { 
            // The `triggerRevert` function is expected to revert. 
                revert("always revert"); 
        } catch Error(string memory errorMessage) { 
            // Ensure that the created child contract in parent is deleted. 
                  require(address(parent.child()) == address(0), "Parent is deleted"); 
        
            // Revert with the error message from the subcontext.
            revert(errorMessage);
        } 
    }
    
    function testCallingContextPropogatesRevertFromSubContext() public {
        Parent parent = new Parent();
        parent.triggerRevert();

    }    

    function addNumbers() public pure returns (uint256) {
        uint256 a = 2^256-1;
        uint256 result = a + 1;
        // "Addition overflow"
        require(1 > a, "bob");
        return result;
    }

    function testAlwaysRevert() public {
        revert("This always reverts");
    }    
}
