realtokenname="dUSD"
tokenname="64555344" #realtokenname "dUSD" base-16 (hexadecimal) encoded = 64555344
tokenamount="2"
script="/workspace/code/Demeter/5_Stablecoin/validators/minting.plutus"
policyid=$(cat /workspace/code/Demeter/5_Stablecoin/validators/minting.policy)
pricefeedoraclereftxin="c09ae024072151c9b29fa38ee469152a5f94c1b6db53f33339edd61035f2239f#0" #refutxo oracle pricefeed
utxoin="02f5cb276dd24af0977354fb3ac7ca95fa8805c48544ec070747fa49156af62d#2" #bob's utxo for tx payment
collateral="02f5cb276dd24af0977354fb3ac7ca95fa8805c48544ec070747fa49156af62d#2" #bob's utxo for collateral
collateralAddress=$(cat /workspace/code/Demeter/5_Stablecoin/validators/collateral.addr)
output="5000000"
outputcollateral="3000000"
signerPKH1=$(cat /workspace/keys/bob.pkh)
stablecoinReceiver=$(cat /workspace/keys/bob.addr)
changeaddress=$(cat /workspace/keys/bob.addr)
PREVIEW="--testnet-magic 2"
signingkeyfile="/workspace/keys/bob.skey"
redeemerfile="/workspace/code/Demeter/5_Stablecoin/data/mintRedeemer.json"
collateralDatumFile="/workspace/code/Demeter/5_Stablecoin/data/collateralDatumBob.json"
paramsfile="/workspace/data/protocolparams.json"
txunsignedfile="/workspace/code/Demeter/5_Stablecoin/txoutputs/mintStablecoin_dUSD.unsigned"
txsignedfile="/workspace/code/Demeter/5_Stablecoin/txoutputs/mintStablecoin_dUSD.signed"
era="--babbage-era"

cardano-cli transaction build \
  --babbage-era \
  $PREVIEW \
  --tx-in $utxoin \
  --read-only-tx-in-reference $pricefeedoraclereftxin \
  --tx-out $stablecoinReceiver+$output+"$tokenamount $policyid.$tokenname" \
  --tx-out $collateralAddress+$outputcollateral \
  --tx-out-inline-datum-file $collateralDatumFile \
  --change-address $changeaddress \
  --mint="$tokenamount $policyid.$tokenname" \
  --minting-script-file $script \
  --mint-redeemer-file $redeemerfile \
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