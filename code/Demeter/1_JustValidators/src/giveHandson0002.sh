utxoin="f90e739206316d74a6f697c76450e01fdded14dba95baa8cd77aa1679c020119#0"
contractaddress=$(cat /workspace/code/Demeter/1_JustValidators/testnet/handson0002.addr)
changeaddress=$(cat /workspace/keys/alice.addr) 
output="500000000"
PREVIEW="--testnet-magic 2"
#nami="<provide a wallet to see the tx in blockchain explorers>" 


cardano-cli transaction build \
  --babbage-era \
  $PREVIEW \
  --tx-in $utxoin \
  --tx-out $contractaddress+$output \
  --tx-out-datum-hash-file /workspace/code/Demeter/1_JustValidators/testnet/goodOWD.json \
  --change-address $changeaddress \
  --protocol-params-file /workspace/data/protocolparams.json \
  --out-file /workspace/code/Demeter/1_JustValidators/output/give.unsigned

cardano-cli transaction sign \
    --tx-body-file /workspace/code/Demeter/1_JustValidators/output/give.unsigned \
    --signing-key-file /workspace/keys/alice.skey \
    $PREVIEW \
    --out-file /workspace/code/Demeter/1_JustValidators/output/give.signed

cardano-cli transaction submit \
    $PREVIEW \
    --tx-file /workspace/code/Demeter/1_JustValidators/output/give.signed

tid=$(cardano-cli transaction txid --tx-file /workspace/code/Demeter/1_JustValidators/output/give.signed)
echo "transaction id: $tid"
echo "Cexplorer: https://preview.cardanoscan.io/tx/$tid"