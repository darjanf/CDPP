realtokenname="dUSD"
tokenname="64555344" #realtokenname "dUSD" base-16 (hexadecimal) encoded = 64555344
tokenamount="-2"
script="/workspace/code/Demeter/5_Stablecoin/validators/minting.plutus"
policyid=$(cat /workspace/code/Demeter/5_Stablecoin/validators/minting.policy)
pricefeedoraclereftxin="9054d054ae680ce85c6eaec3edc5b30fd080285f88ebb142d36223aae2ce99fe#0" #refutxo oracle pricefeed
utxoin="c42b184c2f2de60f44107948e79f1e9fa83b17b91d6e9dc6e4f4dc6e9c689ce3#0" #alice's utxo containing dUSD
collateralutxin="6cf3319a0a6247da5c76e03c85dbdf13766c983834bbc59c4149272623cfab75#1" #collateral utxo of bob
collateralscriptrefutxo="79e93a7d16f2f53ad91a1fa0be351c3d59b3442e529098d02cc2e1e8a2d43bb4#0" #collateral ref script
collateral="c42b184c2f2de60f44107948e79f1e9fa83b17b91d6e9dc6e4f4dc6e9c689ce3#2" #alices's utxo for collateral
output="2000000"
signerPKH1=$(cat /workspace/keys/alice.pkh)
collateralReceiver=$(cat /workspace/keys/alice.addr)
changeaddress=$(cat /workspace/keys/alice.addr)
PREVIEW="--testnet-magic 2"
signingkeyfile="/workspace/keys/alice.skey"
collateralRedeemerFile="/workspace/code/Demeter/5_Stablecoin/data/collateralLiquidate.json"
mintRedeemerFile="/workspace/code/Demeter/5_Stablecoin/data/liquidateRedeemer.json"
collateralDatumFile="/workspace/code/Demeter/5_Stablecoin/data/collateralDatumBob.json"
paramsfile="/workspace/data/protocolparams.json"
txunsignedfile="/workspace/code/Demeter/5_Stablecoin/txoutputs/liquidateStablecoin_dUSD.unsigned"
txsignedfile="/workspace/code/Demeter/5_Stablecoin/txoutputs/liquidateStablecoin_dUSD.signed"
era="--babbage-era"
validatorfile="/workspace/code/Demeter/5_Stablecoin/validators/collateral.plutus"

cardano-cli transaction build \
  --babbage-era \
  $PREVIEW \
  --tx-in $collateralutxin \
  --read-only-tx-in-reference $pricefeedoraclereftxin \
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