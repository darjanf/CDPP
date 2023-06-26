utxoin="e972760e5300f9f25ce5016a93b521c6c54bfe1a1aa060d05e3db098d1d6998c#1"
collateral="e972760e5300f9f25ce5016a93b521c6c54bfe1a1aa060d05e3db098d1d6998c#1"
address=$(cat /workspace/keys/alice.addr)
output="10000000"
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
signingkeyfile_claire="/workspace/keys/claire.skey"
redeemerfile="/workspace/code/Demeter/3_NativeTokens/data/unit.json"
paramsfile="/workspace/data/protocolparams.json"
txwitnessfile_alice="/workspace/code/Demeter/3_NativeTokens/txoutputs/mintHandsOn0007_alice.witness"
txwitnessfile_bob="/workspace/code/Demeter/3_NativeTokens/txoutputs/mintHandsOn0007_bob.witness"
txwitnessfile_claire="/workspace/code/Demeter/3_NativeTokens/txoutputs/mintHandsOn0007_claire.witness"
signerPKHCollateral_alice=$(cat /workspace/keys/alice.pkh)
signerPKHCollateral_bob=$(cat /workspace/keys/bob.pkh)
signerPKHCollateral_claire=$(cat /workspace/keys/claire.pkh)

# deleted lines
#   

cardano-cli transaction build \
  --babbage-era \
  $PREVIEW \
  --tx-in $utxoin \
  --minting-script-file $validatorfile \
  --mint-redeemer-file $redeemerfile \
  --required-signer-hash $signerPKHCollateral_alice \
  --required-signer-hash $signerPKHCollateral_claire \
  --tx-in-collateral $collateral \
  --tx-out "$address+$output+$tokenamount $policyid.$tokenname" \
  --change-address $changeaddress \
  --protocol-params-file $paramsfile \
  --mint="$tokenamount $policyid.$tokenname" \
  --witness-override $txwitnesscount \
  --out-file $txunsignedfile

: <<'END'
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

cardano-cli transaction sign \
    --tx-body-file $txunsignedfile \
    --signing-key-file $signingkeyfile_alice \
    $PREVIEW \
    --out-file $txsignedfile

cardano-cli transaction submit \
  --tx-file $txsignedfile \
  $PREVIEW

END