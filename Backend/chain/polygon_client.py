import os, json, hashlib
from web3 import Web3
from dotenv import load_dotenv

load_dotenv()
RPC = os.getenv("POLYGON_RPC_URL")
CHAIN_ID = int(os.getenv("POLYGON_CHAIN_ID", "80002"))
PRIVATE_KEY = os.getenv("POLYGON_PRIVATE_KEY")

w3 = Web3(Web3.HTTPProvider(RPC))
ACCOUNT = w3.eth.account.from_key(PRIVATE_KEY)

def keccak256_hex(data: bytes) -> str:
    return "0x" + hashlib.sha3_256(data).hexdigest()

def publish_hash_on_polygon(message_id: str, record_hash: str) -> str:
    """
    Minimal pattern: send a bare tx with hash in 'data' field to self,
    or to an optional logging contract.
    """
    nonce = w3.eth.get_transaction_count(ACCOUNT.address)
    tx = {
        "to": ACCOUNT.address,              # self-transfer; data carries the hash
        "value": 0,
        "data": Web3.to_bytes(hexstr=record_hash),
        "gas": 60_000,
        "maxFeePerGas": w3.to_wei("50", "gwei"),
        "maxPriorityFeePerGas": w3.to_wei("2", "gwei"),
        "nonce": nonce,
        "chainId": CHAIN_ID,
        "type": 2,
    }
    signed = ACCOUNT.sign_transaction(tx)
    tx_hash = w3.eth.send_raw_transaction(signed.rawTransaction).hex()
    return tx_hash
