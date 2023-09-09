realtokenname="BountyNFT"
tokenname="426f756e74794e4654" #tokenname base-16 (hexadecimal) encoded
tokenamount="50"
policyid=$(cat /workspace/code/Demeter/4_SimpleGames/validators/testNFT.policy)
utxoin="6d75e477259a6179977c0ebd601540c7a7f083c2f934c885ffabb141c39dfccb#0"
address=$(cat /workspace/keys/alice.addr)
output="250000000"
collateral="6d75e477259a6179977c0ebd601540c7a7f083c2f934c885ffabb141c39dfccb#0"
signerPKH1=$(cat /workspace/keys/alice.pkh)
changeaddress=$(cat /workspace/keys/alice.addr)
PREVIEW="--testnet-magic 2"
signingkeyfile="/workspace/keys/alice.skey"
validatorfile="/workspace/code/Demeter/4_SimpleGames/validators/testNFT.plutus"
nftmetadatafile="/workspace/code/Demeter/4_SimpleGames/data/testNFTMetadata.json"
redeemerfile="/workspace/code/Demeter/4_SimpleGames/data/unit.json"
paramsfile="/workspace/data/protocolparams.json"
txunsignedfile="/workspace/code/Demeter/4_SimpleGames/txoutputs/testNFT.unsigned"
txsignedfile="/workspace/code/Demeter/4_SimpleGames/txoutputs/testNFT.signed"
era="--babbage-era"

cardano-cli transaction build \
  --babbage-era \
  $PREVIEW \
  --tx-in $utxoin \
  --tx-out $address+$output+"$tokenamount $policyid.$tokenname" \
  --change-address $address \
  --mint="$tokenamount $policyid.$tokenname" \
  --minting-script-file $validatorfile \
  --mint-redeemer-file $redeemerfile \
  --metadata-json-file $nftmetadatafile  \
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