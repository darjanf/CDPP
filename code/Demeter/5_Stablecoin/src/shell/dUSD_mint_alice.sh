realtokenname="dUSD"
tokenname="64555344" #realtokenname "dUSD" base-16 (hexadecimal) encoded = 64555344
tokenamount="2"
script="/workspace/code/Demeter/5_Stablecoin/validators/minting.plutus"
refscript="/workspace/code/Demeter/5_Stablecoin/validators/collateral.plutus"
policyid=$(cat /workspace/code/Demeter/5_Stablecoin/validators/minting.policy)
pricefeedoraclereftxin="c09ae024072151c9b29fa38ee469152a5f94c1b6db53f33339edd61035f2239f#0" #refutxo oracle pricefeed
utxoin="62a0daa80d3413068c50e5efeecb518a36bc6dd7c17748f45b303233c8e27f65#2" #alice's utxo for tx payment
collateral="62a0daa80d3413068c50e5efeecb518a36bc6dd7c17748f45b303233c8e27f65#2" #alice's utxo for collateral
collateralAddress=$(cat /workspace/code/Demeter/5_Stablecoin/validators/collateral.addr)
output="5000000"
outputcollateral="30000000"
signerPKH1=$(cat /workspace/keys/alice.pkh)
stablecoinReceiver=$(cat /workspace/keys/alice.addr)
changeaddress=$(cat /workspace/keys/alice.addr)
PREVIEW="--testnet-magic 2"
signingkeyfile="/workspace/keys/alice.skey"
redeemerfile="/workspace/code/Demeter/5_Stablecoin/data/mintRedeemer.json"
collateralDatumFile="/workspace/code/Demeter/5_Stablecoin/data/collateralDatumAlice.json"
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
  --tx-out-reference-script-file $refscript \
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