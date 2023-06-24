utxoin="3efc54e82642c3affc354f85e733188ade31c2b3bfe724ecc5d9cbed0a311474#0"
contractaddress=$(cat /workspace/code/Demeter/1_JustValidators/validators/allOrNothing.addr)
changeaddress=$(cat /workspace/keys/alice.addr)
datumfile="/workspace/code/Demeter/1_JustValidators/data/datumHandsOn0003.json"
paramsfile="/workspace/data/protocolparams.json"
output="480000000"
PREVIEW="--testnet-magic 2"
signingkeyfile="/workspace/keys/alice.skey"
txunsignedfile="/workspace/code/Demeter/1_JustValidators/txoutputs/giveHandsOn0003.unsigned"
txsignedfile="/workspace/code/Demeter/1_JustValidators/txoutputs/giveHandsOn0003.signed"


cardano-cli transaction build \
  --babbage-era \
  $PREVIEW \
  --tx-in $utxoin \
  --tx-out $contractaddress+$output \
  --tx-out-datum-hash-file $datumfile \
  --change-address $changeaddress \
  --protocol-params-file $paramsfile \
  --out-file $txunsignedfile

cardano-cli transaction sign \
    --tx-body-file $txunsignedfile \
    --signing-key-file $signingkeyfile \
    $PREVIEW \
    --out-file $txsignedfile

cardano-cli transaction submit \
    $PREVIEW \
    --tx-file $txsignedfile

tid=$(cardano-cli transaction txid --tx-file $txsignedfile)
echo "transaction id: $tid"
echo "Cexplorer: https://preview.cardanoscan.io/transaction/$tid"