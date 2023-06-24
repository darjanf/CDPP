utxoin="f83e294ba16c647195e85837ab97dcb7086c1873264922af6e93af142a0d7309#0"
address=$(cat /workspace/keys/alice.addr)
output="226000000"
collateral="528bb9bcbaf1f52abe4d45718f2fde3d494eeb71c724b63eff8c3dd92b3c5fd9#0"
signerPKH1=$(cat /workspace/keys/alice.pkh)
signerPKH2=$(cat /workspace/keys/bob.pkh)
changeaddress=$(cat /workspace/keys/alice.addr)
PREVIEW="--testnet-magic 2"
signingkeyfile_alice="/workspace/keys/alice.skey"
signingkeyfile_bob="/workspace/keys/bob.skey"
validatorfile="/workspace/code/Demeter/1_JustValidators/validators/handson0004.plutus"
datumfile="/workspace/code/Demeter/1_JustValidators/data/datumHandsOn0004.json"
redeemerfile="/workspace/code/Demeter/1_JustValidators/data/unit.json"
paramsfile="/workspace/data/protocolparams.json"
txunsignedfile="/workspace/code/Demeter/1_JustValidators/txoutputs/grabHandsOn0004.unsigned"
txsignedfile="/workspace/code/Demeter/1_JustValidators/txoutputs/grabHandsOn0004.signed"
txwitnessfile_alice="/workspace/code/Demeter/1_JustValidators/txoutputs/grabHandsOn0004_alice.witness"
txwitnessfile_bob="/workspace/code/Demeter/1_JustValidators/txoutputs/grabHandsOn0004_bob.witness"
txwitnesscount=2

cardano-cli transaction build \
  --babbage-era \
  $PREVIEW \
  --tx-in $utxoin \
  --tx-in-script-file $validatorfile \
  --tx-in-datum-file $datumfile \
  --tx-in-redeemer-file $redeemerfile \
  --required-signer-hash $signerPKH1 \
  --required-signer-hash $signerPKH2 \
  --tx-in-collateral $collateral \
  --tx-out $address+$output \
  --change-address $changeaddress \
  --protocol-params-file $paramsfile \
  --witness-override $txwitnesscount \
  --out-file $txunsignedfile

cardano-cli transaction witness \
  --signing-key-file $signingkeyfile_alice \
  --tx-body-file $txunsignedfile  \
  --out-file $txwitnessfile_alice

cardano-cli transaction witness \
  --signing-key-file $signingkeyfile_bob \
  --tx-body-file $txunsignedfile  \
  --out-file $txwitnessfile_bob

cardano-cli transaction assemble \
  --tx-body-file $txunsignedfile \
  --witness-file $txwitnessfile_alice \
  --witness-file $txwitnessfile_bob \
  --out-file $txsignedfile

cardano-cli transaction submit \
    $PREVIEW \
    --tx-file $txsignedfile

tid=$(cardano-cli transaction txid --tx-file $txsignedfile)
echo "transaction id: $tid"
echo "Cardanoscan: https://preview.cardanoscan.io/transaction/$tid"