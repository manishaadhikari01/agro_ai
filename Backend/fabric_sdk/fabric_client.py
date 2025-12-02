# backend_fastapi/fabric_sdk/fabric_client.py

import os
import json
import time
from hfc.fabric import Client

# Use os.path.join for cross-platform compatibility
NETWORK_CONFIG = os.path.join(
    os.path.dirname(__file__), "gateway.json"
)

# Initialize Fabric client
cli = Client(net_profile=NETWORK_CONFIG)

# Assume channel and chaincode already created in your Fabric network
CHANNEL_NAME = "agrichat"
CHAINCODE_NAME = "agrichaincode"

def log_to_fabric(user_id: str, query: str, reply: str):
    """
    Records a chatbot interaction on the Fabric ledger.
    Stores timestamp, user ID, query, and reply.
    """
    try:
        # Get admin user from connection profile
        admin = cli.get_user('org1.example.com', 'Admin')

        # Prepare transaction payload
        payload = {
            "user_id": user_id,
            "query": query,
            "reply": reply,
            "timestamp": int(time.time())
        }

        args = [json.dumps(payload)]

        response = cli.chaincode_invoke(
            requestor=admin,
            channel_name=CHANNEL_NAME,
            peers=['peer0.org1.example.com'],
            args=args,
            cc_name=CHAINCODE_NAME,
            fcn='recordInteraction',
            wait_for_event=True,
        )
        print("Fabric tx response:", response)
        return response  # Return response for further handling
    except Exception as e:
        print("Error logging to Fabric:", e)
        return None

