utxoin="528bb9bcbaf1f52abe4d45718f2fde3d494eeb71c724b63eff8c3dd92b3c5fd9#0"
collateral="6d75e477259a6179977c0ebd601540c7a7f083c2f934c885ffabb141c39dfccb#0"
address=$(cat /workspace/keys/alice.addr)
output="429000000"
tokenamount="10"
policyid=$(cat /workspace/code/Demeter/3_NativeTokens/validators/handson0007.policy)
tokenname="4461726A616E436F696E"
changeaddress=$(cat /workspace/keys/alice.addr)
validatorfile="/workspace/code/Demeter/3_NativeTokens/validators/handson0007.plutus"
PREVIEW="--testnet-magic 2"
txunsignedfile="/workspace/code/Demeter/3_NativeTokens/txoutputs/mintHandsOn0007.unsigned"
txsignedfile="/workspace/code/Demeter/3_NativeTokens/txoutputs/mintHandsOn0007.signed"
txwitnesscount=2
signingkeyfile_alice="/workspace/keys/alice.skey"
signingkeyfile_bob="/workspace/keys/bob.skey"
redeemerfile="/workspace/code/Demeter/3_NativeTokens/data/unit.json"
paramsfile="/workspace/data/protocolparams.json"
txwitnessfile_alice="/workspace/code/Demeter/3_NativeTokens/txoutputs/mintHandsOn0007_alice.witness"
txwitnessfile_bob="/workspace/code/Demeter/3_NativeTokens/txoutputs/mintHandsOn0007_bob.witness"
signerPKH1=$(cat /workspace/keys/alice.pkh)
signerPKH2=$(cat /workspace/keys/bob.pkh)

cardano-cli transaction build \
  --babbage-era \
  $PREVIEW \
  --tx-in $utxoin \
  --minting-script-file $validatorfile \
  --mint-redeemer-file $redeemerfile \
  --required-signer-hash $signerPKH1 \
  --required-signer-hash $signerPKH2 \
  --tx-in-collateral $collateral \
  --tx-out "$address+$output+$tokenamount $policyid.$tokenname" \
  --change-address $changeaddress \
  --protocol-params-file $paramsfile \
  --mint="$tokenamount $policyid.$tokenname" \
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
  --tx-file $txsignedfile \
  $PREVIEW