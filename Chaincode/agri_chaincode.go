// chaincode_fabric/agri_chaincode.go

package main

import (
	"encoding/json"
	"fmt"
	"time"

	"github.com/hyperledger/fabric-contract-api-go/contractapi"
)

// AgriChaincode structure
type AgriChaincode struct {
	contractapi.Contract
}

// Interaction struct stored on ledger
type Interaction struct {
	UserID    string `json:"user_id"`
	Query     string `json:"query"`
	Reply     string `json:"reply"`
	Timestamp int64  `json:"timestamp"`
}

// recordInteraction stores a new chatbot interaction
func (cc *AgriChaincode) RecordInteraction(ctx contractapi.TransactionContextInterface, interactionJSON string) error {
	var data Interaction
	err := json.Unmarshal([]byte(interactionJSON), &data)
	if err != nil {
		return fmt.Errorf("failed to unmarshal input: %v", err)
	}

	// Use timestamp as key for simplicity
	key := fmt.Sprintf("%s_%d", data.UserID, time.Now().UnixNano())

	return ctx.GetStub().PutState(key, []byte(interactionJSON))
}

// QueryAll returns everything recorded
func (cc *AgriChaincode) QueryAll(ctx contractapi.TransactionContextInterface) ([]*Interaction, error) {
	iterator, err := ctx.GetStub().GetStateByRange("", "")
	if err != nil {
		return nil, err
	}
	defer iterator.Close()

	var results []*Interaction
	for iterator.HasNext() {
		r, _ := iterator.Next()
		var i Interaction
		_ = json.Unmarshal(r.Value, &i)
		results = append(results, &i)
	}
	return results, nil
}

func main() {
	chaincode, err := contractapi.NewChaincode(new(AgriChaincode))
	if err != nil {
		fmt.Printf("Error create agri chaincode: %s", err.Error())
		return
	}

	if err := chaincode.Start(); err != nil {
		fmt.Printf("Error starting chaincode: %s", err.Error())
	}
}
