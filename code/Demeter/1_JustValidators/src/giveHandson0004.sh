utxoin1="21abd9f03022d8f8cbd62ae7c7a473e4cfb8f8b2990af7465725988575a792d4#1"
utxoin2="2289b315c8b1691074167856d142721b2da5100b0877d1fd6db5a9c68d0eeb8e#1"
utxoin3="528bb9bcbaf1f52abe4d45718f2fde3d494eeb71c724b63eff8c3dd92b3c5fd9#1"
utxoin4="6b17dccd843007ad18a8486827e47ab5568b81f633684dd5b82e2691b34c5f2e#1"
utxoin5="7ad4e800be2282f89d8c673adc7cdb4ac97e93e82be4ebb9daeb222f1be6dead#1"
utxoin6="e5ce170eb5c1ec6999e0119231d13f35a5728f34858ed9c4b1986876bbe51fbe#1"
contractaddress=$(cat /workspace/code/Demeter/1_JustValidators/validators/handson0004.addr)
changeaddress=$(cat /workspace/keys/alice.addr)
datumfile="/workspace/code/Demeter/1_JustValidators/data/datumHandsOn0004.json"
paramsfile="/workspace/data/protocolparams.json"
output="227500000"
PREVIEW="--testnet-magic 2"
signingkeyfile="/workspace/keys/alice.skey"
txunsignedfile="/workspace/code/Demeter/1_JustValidators/txoutputs/giveHandsOn0004.unsigned"
txsignedfile="/workspace/code/Demeter/1_JustValidators/txoutputs/giveHandsOn0004.signed"


cardano-cli transaction build \
  --babbage-era \
  $PREVIEW \
  --tx-in $utxoin1 \
  --tx-in $utxoin2 \
  --tx-in $utxoin3 \
  --tx-in $utxoin4 \
  --tx-in $utxoin5 \
  --tx-in $utxoin6 \
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