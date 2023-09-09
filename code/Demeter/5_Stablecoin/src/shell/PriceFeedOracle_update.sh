utxoin="c09ae024072151c9b29fa38ee469152a5f94c1b6db53f33339edd61035f2239f#0" #current pricefeed utxo (containing OracleNFT)
utxoinpayment="e56a6918e8e46ab412b00ba6d8feae5bfac3eb15f670e3474bb4f6c1c6d8a9c6#0" #bob's utxo for payment
collateral="e56a6918e8e46ab412b00ba6d8feae5bfac3eb15f670e3474bb4f6c1c6d8a9c6#0" #bob's utxo for collateral
policyid=$(cat /workspace/code/Demeter/5_Stablecoin/validators/oracleNFT.policy)
tokenname="4f7261636c654e4654" #tokenname "OracleNFT" base-16 (hexadecimal) encoded
tokenamount="1"
oracleaddress=$(cat /workspace/code/Demeter/5_Stablecoin/validators/priceFeedOracle.addr)
changeaddress=$(cat /workspace/keys/bob.addr)
datumfile="/workspace/code/Demeter/5_Stablecoin/data/priceFeedOracleDatum.json" #datum containing current price
redeemerfile=""/workspace/code/Demeter/5_Stablecoin/data/priceFeedOracleUpdateRedeemer.json""
paramsfile="/workspace/data/protocolparams.json"
output="3200000"
PREVIEW="--testnet-magic 2"
signerPKH1=$(cat /workspace/keys/bob.pkh)
signingkeyfile="/workspace/keys/bob.skey"
txunsignedfile="/workspace/code/Demeter/5_Stablecoin/txoutputs/updatePriceFeedOracle.unsigned"
txsignedfile="/workspace/code/Demeter/5_Stablecoin/txoutputs/updatePriceFeedOracle.signed"
script="/workspace/code/Demeter/5_Stablecoin/validators/PriceFeedOracle.plutus"

cardano-cli transaction build \
  --babbage-era \
  $PREVIEW \
  --tx-in $utxoinpayment \
  --tx-in $utxoin \
  --tx-in-inline-datum-present \
  --tx-in-redeemer-file $redeemerfile \
  --tx-in-script-file $script \
  --tx-out $oracleaddress+$output+"$tokenamount $policyid.$tokenname" \
  --tx-out-inline-datum-file $datumfile \
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