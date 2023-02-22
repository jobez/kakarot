pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import {PlainOpcodes} from "./PlainOpcodes.sol";
import {Parent} from "./Parent.sol";
import {Counter} from "./Counter.sol";

contract PlainOpcodesTest is Test {
    PlainOpcodes plainOpcodes;
    Counter counter;

    function setUp() public {
        counter = new Counter();
        plainOpcodes = new PlainOpcodes(address(counter));
    }

    function testOpcodeExtCodeCopyReturnsCounterCode(
        uint256 offset,
        uint256 size
    ) public {
        address target = address(counter);
        uint256 counterSize;
        assembly {
            counterSize := extcodesize(target)
        }
        vm.assume(size < counterSize + 1);
        vm.assume(offset < counterSize);
        bytes memory expectedResult;
        // see https://docs.soliditylang.org/en/v0.8.17/assembly.html#example
        assembly {
            counterSize := extcodesize(target)
            // get a free memory location to write result into
            expectedResult := mload(0x40)
            // update free memory pointer: write at 0x40 an empty memory address
            mstore(
                0x40,
                add(
                    expectedResult,
                    and(add(add(counterSize, 0x20), 0x1f), not(0x1f))
                )
            )
            // store the size of the result at expectedResult
            // a bytes array stores its size in the first word
            mstore(expectedResult, counterSize)
            // actually copy the counter code from offset expectedResult + 0x20 (size location)
            extcodecopy(target, add(expectedResult, 0x20), 0, counterSize)
        }

        bytes memory bytecode = plainOpcodes.opcodeExtCodeCopy(0, counterSize);
        assertEq0(bytecode, expectedResult);
    }

    // TODO camel case
    function test_revert_deletes_created_contract() public {
        Parent parent = new Parent();

        try parent.triggerRevert() {
            // The `doSomething` function is expected to revert.
            assert(false);
        } catch {
            // Ensure that the created `TestContract` is deleted.
            // 
            assert(address(parent).balance == 0);
        }
    }

    function testAddNumbers() public pure returns (uint256) {
        uint256 a = 2^256-1;
        uint256 result = a + 1;
        require(result > a, "Addition overflow");
        return result;
    }

    function run() external returns (address address_, bool triggerRevert ) {
        Parent parent = new Parent();
        // child contract is created in the same execution context as a revert
        
        
        (bool success2, bytes memory data) = address(parent).call(abi.encodeWithSignature("triggerRevert()"));

        require(!success2, "trigger revert... should revert");        
         
        /* (bool success, bytes memory data_) = address(parent.child()).call(abi.encodeWithSignature("doSomething()")); */

        assert(address(parent.child()) == address(0));        
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

    function testCallingContextPropogatesRevertFromSubContext() public {
        Parent parent = new Parent();
        parent.triggerRevert();

    }    
    
    
    function testAlwaysRevert() public {
        revert("This always reverts");
    }        
}
