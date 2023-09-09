utxoin="62eeab23805376a3c4efaa33eb523ea7839c9ea0a0a167347679109a8eec5ff3#0" #utxo with OracleNFT
utxoin2="e90de4e2a38e6ae2752e2106d15db88815c178ef03ba7af17f665aafc37c1b11#1"
collateral="e90de4e2a38e6ae2752e2106d15db88815c178ef03ba7af17f665aafc37c1b11#1"
policyid=$(cat /workspace/code/Demeter/5_Stablecoin/validators/oracleNFT.policy)
tokenname="4f7261636c654e4654" #tokenname "OracleNFT" base-16 (hexadecimal) encoded
tokenamount="1"
receiveraddress=$(cat /workspace/keys/bob.addr)
changeaddress=$(cat /workspace/keys/bob.addr)
datumfile="/workspace/code/Demeter/5_Stablecoin/data/priceFeedOracleDatum.json"
redeemerfile=""/workspace/code/Demeter/5_Stablecoin/data/priceFeedOracleDeleteRedeemer.json""
paramsfile="/workspace/data/protocolparams.json"
output="3200000"
PREVIEW="--testnet-magic 2"
signerPKH1=$(cat /workspace/keys/bob.pkh)
signingkeyfile="/workspace/keys/bob.skey"
txunsignedfile="/workspace/code/Demeter/5_Stablecoin/txoutputs/deletePriceFeedOracle.unsigned"
txsignedfile="/workspace/code/Demeter/5_Stablecoin/txoutputs/deletePriceFeedOracle.signed"
script="/workspace/code/Demeter/5_Stablecoin/validators/PriceFeedOracle.plutus"

cardano-cli transaction build \
  --babbage-era \
  $PREVIEW \
  --tx-in $utxoin2 \
  --tx-in $utxoin \
  --tx-in-inline-datum-present \
  --tx-in-redeemer-file $redeemerfile \
  --tx-in-script-file $script \
  --tx-out $receiveraddress+$output+"$tokenamount $policyid.$tokenname" \
  --change-address $changeaddress \
  --required-signer-hash $signerPKH1 \
  --tx-in-collateral $collateral \
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