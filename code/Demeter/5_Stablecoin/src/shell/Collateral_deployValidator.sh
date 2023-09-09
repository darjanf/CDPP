PREVIEW="--testnet-magic 2"
utxoin="d8c55436b1bf13bf172d0e1ef7bc4f521d53db6917884e5e119513307237c629#1"
receiveraddress=$(cat /workspace/keys/validatoranchor.addr)
receiveramount="20000000"
changeaddress=$(cat /workspace/keys/bob.addr)
paramsfile="/workspace/data/protocolparams.json"
collateralscript="/workspace/code/Demeter/5_Stablecoin/validators/collateral.plutus"
txunsignedfile="/workspace/code/Demeter/5_Stablecoin/txoutputs/deployValidator.unsigned"
txsignedfile="/workspace/code/Demeter/5_Stablecoin/txoutputs/deployValidator.signed"
signingkeyfile="/workspace/keys/bob.skey"

cardano-cli transaction build \
  --babbage-era \
  $PREVIEW \
  --tx-in $utxoin \
  --tx-out $receiveraddress+$receiveramount \
  --tx-out-reference-script-file $collateralscript \
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
echo "Cardanoscan: https://preview.cardanoscan.io/transaction/$tid"