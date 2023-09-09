realtokenname="dUSD"
tokenname="64555344" #realtokenname "dUSD" base-16 (hexadecimal) encoded = 64555344
tokenamount="-2"
script="/workspace/code/Demeter/5_Stablecoin/validators/minting.plutus"
policyid=$(cat /workspace/code/Demeter/5_Stablecoin/validators/minting.policy)
collateralutxin="02f5cb276dd24af0977354fb3ac7ca95fa8805c48544ec070747fa49156af62d#1" #utxo stored in collateral
collateralscriptrefutxo="79e93a7d16f2f53ad91a1fa0be351c3d59b3442e529098d02cc2e1e8a2d43bb4#0" #utxo with oracle ref-script, stored at validatoranchor address
utxoin="02f5cb276dd24af0977354fb3ac7ca95fa8805c48544ec070747fa49156af62d#0" #utxo containing dUSD
collateral="02f5cb276dd24af0977354fb3ac7ca95fa8805c48544ec070747fa49156af62d#2"
output="3000000"
signerPKH1=$(cat /workspace/keys/bob.pkh)
collateralReceiver=$(cat /workspace/keys/bob.addr)
changeaddress=$(cat /workspace/keys/bob.addr)
PREVIEW="--testnet-magic 2"
signingkeyfile="/workspace/keys/bob.skey"
collateralRedeemerFile="/workspace/code/Demeter/5_Stablecoin/data/collateralRedeem.json"
mintRedeemerFile="/workspace/code/Demeter/5_Stablecoin/data/burnRedeemer.json"
collateralDatumFile="/workspace/code/Demeter/5_Stablecoin/data/collateralDatum.json"
paramsfile="/workspace/data/protocolparams.json"
txunsignedfile="/workspace/code/Demeter/5_Stablecoin/txoutputs/burnStablecoin_dUSD.unsigned"
txsignedfile="/workspace/code/Demeter/5_Stablecoin/txoutputs/burnStablecoin_dUSD.signed"
era="--babbage-era"
validatorfile="/workspace/code/Demeter/5_Stablecoin/validators/collateral.plutus"

cardano-cli transaction build \
  --babbage-era \
  $PREVIEW \
  --tx-in $collateralutxin \
  --spending-tx-in-reference $collateralscriptrefutxo \
  --spending-plutus-script-v2 \
  --spending-reference-tx-in-inline-datum-present \
  --spending-reference-tx-in-redeemer-file $collateralRedeemerFile \
  --tx-in $utxoin \
  --tx-out $collateralReceiver+$output \
  --change-address $changeaddress \
  --mint="$tokenamount $policyid.$tokenname" \
  --minting-script-file $script \
  --mint-redeemer-file $mintRedeemerFile \
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
echo "Cardanoscan: https://preview.cardanoscan.io/transaction/$tid"