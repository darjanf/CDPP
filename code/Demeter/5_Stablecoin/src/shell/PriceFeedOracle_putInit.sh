utxoin="d8c55436b1bf13bf172d0e1ef7bc4f521d53db6917884e5e119513307237c629#0" #utxo with OracleNFT
utxoin2="62eeab23805376a3c4efaa33eb523ea7839c9ea0a0a167347679109a8eec5ff3#1" #utxo for tx payment
policyid=$(cat /workspace/code/Demeter/5_Stablecoin/validators/oracleNFT.policy)
tokenname="4f7261636c654e4654" #tokenname "OracleNFT" base-16 (hexadecimal) encoded
tokenamount="1"
contractaddress=$(cat /workspace/code/Demeter/5_Stablecoin/validators/priceFeedOracle.addr)
changeaddress=$(cat /workspace/keys/bob.addr)
datumfile="/workspace/code/Demeter/5_Stablecoin/data/priceFeedOracleDatum.json"
paramsfile="/workspace/data/protocolparams.json"
output="3200000"
PREVIEW="--testnet-magic 2"
signingkeyfile="/workspace/keys/bob.skey"
txunsignedfile="/workspace/code/Demeter/5_Stablecoin/txoutputs/putInitPriceFeedOracle.unsigned"
txsignedfile="/workspace/code/Demeter/5_Stablecoin/txoutputs/putInitPriceFeedOracle.signed"

cardano-cli transaction build \
  --babbage-era \
  $PREVIEW \
  --tx-in $utxoin \
  --tx-in $utxoin2 \
  --tx-out $contractaddress+$output+"$tokenamount $policyid.$tokenname" \
  --tx-out-inline-datum-file $datumfile \
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