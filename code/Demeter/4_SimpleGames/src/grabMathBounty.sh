utxoin="2468200e234dab20f4610aa468b82fd04c581f53189d2d650ebeeee93fe6eccc#0"
address=$(cat /workspace/keys/alice.addr)
output="48000000"
collateral="0740c956c3a74ae1975e2a7bfd6a840785a5a029ba3477087af410f4272fd1d2#1"
signerPKH1=$(cat /workspace/keys/alice.pkh)
changeaddress=$(cat /workspace/keys/alice.addr)
PREVIEW="--testnet-magic 2"
signingkeyfile="/workspace/keys/alice.skey"
validatorfile="/workspace/code/Demeter/4_SimpleGames/validators/mathBounty.plutus"
datumfile="/workspace/code/Demeter/4_SimpleGames/data/bountyConditions.json"
redeemerfile="/workspace/code/Demeter/4_SimpleGames/data/unit.json"
paramsfile="/workspace/data/protocolparams.json"
txunsignedfile="/workspace/code/Demeter/4_SimpleGames/txoutputs/grabMathBounty.unsigned"
txsignedfile="/workspace/code/Demeter/4_SimpleGames/txoutputs/grabMathBounty.signed"

cardano-cli transaction build \
  --babbage-era \
  $PREVIEW \
  --tx-in $utxoin \
  --tx-in-script-file $validatorfile \
  --tx-in-datum-file $datumfile \
  --tx-in-redeemer-file $redeemerfile \
  --required-signer-hash $signerPKH1 \
  --tx-in-collateral $collateral \
  --tx-out $address+$output \
  --change-address $changeaddress \
  --invalid-hereafter 21916545 \
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