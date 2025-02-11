%lang starknet

from utils.eth_transaction import EthTransaction
from starkware.cairo.common.cairo_builtins import HashBuiltin, BitwiseBuiltin
from starkware.cairo.common.uint256 import Uint256

@view
func test__decode{
    syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, bitwise_ptr: BitwiseBuiltin*, range_check_ptr
}(tx_data_len: felt, tx_data: felt*) -> (
    msg_hash: Uint256,
    nonce: felt,
    gas_price: felt,
    gas_limit: felt,
    destination: felt,
    amount: felt,
    chain_id: felt,
    payload_len: felt,
    payload: felt*,
) {
    return EthTransaction.decode(tx_data_len, tx_data);
}

@view
func test__validate{
    syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, bitwise_ptr: BitwiseBuiltin*, range_check_ptr
}(address: felt, nonce: felt, r: Uint256, s: Uint256, v: felt, tx_data_len: felt, tx_data: felt*) {
    return EthTransaction.validate(address, nonce, r, s, v, tx_data_len, tx_data);
}
