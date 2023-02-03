
from eth_utils import decode_hex, keccak, to_bytes, to_checksum_address

import pytest_asyncio
from starkware.starknet.testing.starknet import Starknet


@pytest_asyncio.fixture(scope="session")
async def account_proxy(starknet: Starknet):
    return await starknet.declare(
        source="src/kakarot/accounts/proxy/proxy.cairo",
        cairo_path=["src"],
        disable_hint_validation=True,
    )

@pytest_asyncio.fixture(scope="package")
async def counter(deploy_solidity_contract, owner):
    return await deploy_solidity_contract(
        "PlainOpcodes", "Counter", caller_address=owner.starknet_address
    )

@pytest_asyncio.fixture(scope="package")
async def default_tx(counter) -> dict:
    return {
        "nonce": 1,
        "chainId": 1263227476,
        "maxFeePerGas": 1000,
        "maxPriorityFeePerGas": 667667,
        "gas": 999999999,
        "to": to_bytes(int(counter.evm_contract_address, 16)),
        "value": 10000000000000000,
        "data": b"",
    }
