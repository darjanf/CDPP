utxoin="e5ce170eb5c1ec6999e0119231d13f35a5728f34858ed9c4b1986876bbe51fbe#0"
address=$(cat /workspace/keys/alice.addr)
output="430000000"
collateral="21abd9f03022d8f8cbd62ae7c7a473e4cfb8f8b2990af7465725988575a792d4#1"
signerPKH=$(cat /workspace/keys/alice.pkh)
changeaddress=$(cat /workspace/keys/alice.addr)
PREVIEW="--testnet-magic 2"
signingkeyfile="/workspace/keys/alice.skey"
validatorfile="/workspace/code/Demeter/1_JustValidators/validators/allOrNothing.plutus"
datumfile="/workspace/code/Demeter/1_JustValidators/data/datumHandsOn0003.json"
redeemerfile="/workspace/code/Demeter/1_JustValidators/data/unit.json"
paramsfile="/workspace/data/protocolparams.json"
txunsignedfile="/workspace/code/Demeter/1_JustValidators/txoutputs/grabHandsOn0003.unsigned"
txsignedfile="/workspace/code/Demeter/1_JustValidators/txoutputs/grabHandsOn0003.signed"

cardano-cli transaction build \
  --babbage-era \
  $PREVIEW \
  --tx-in $utxoin \
  --tx-in-script-file $validatorfile \
  --tx-in-datum-file $datumfile \
  --tx-in-redeemer-file $redeemerfile \
  --required-signer-hash $signerPKH \
  --tx-in-collateral $collateral \
  --tx-out $address+$output \
  --change-address $changeaddress \
  --invalid-hereafter 20815607 \
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
echo "Cardanoscan: https://preview.cardanoscan.io/transaction/$tid"