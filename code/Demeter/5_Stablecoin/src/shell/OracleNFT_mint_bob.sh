realtokenname="OracleNFT"
tokenname="4f7261636c654e4654" #realtokenname "OracleNFT" base-16 (hexadecimal) encoded = 4f7261636c654e4654
tokenamount="1"
policyid=$(cat /workspace/code/Demeter/5_Stablecoin/validators/oracleNFT.policy)
utxoin="b19c9fd8998093ed036e61ad8b8234c9c2cd6a657e73cbb42d3d69a0c6b193fd#2"
address=$(cat /workspace/keys/bob.addr)
output="2800000"
collateral="b19c9fd8998093ed036e61ad8b8234c9c2cd6a657e73cbb42d3d69a0c6b193fd#2"
signerPKH1=$(cat /workspace/keys/bob.pkh)
changeaddress=$(cat /workspace/keys/bob.addr)
PREVIEW="--testnet-magic 2"
signingkeyfile="/workspace/keys/bob.skey"
nftmetadatafile="/workspace/code/Demeter/5_Stablecoin/data/oracleNFTMetadata.json"
redeemerfile="/workspace/code/Demeter/5_Stablecoin/data/unit.json"
paramsfile="/workspace/data/protocolparams.json"
txunsignedfile="/workspace/code/Demeter/5_Stablecoin/txoutputs/mintOracleNFT.unsigned"
txsignedfile="/workspace/code/Demeter/5_Stablecoin/txoutputs/mintOracleNFT.signed"
era="--babbage-era"
script="/workspace/code/Demeter/5_Stablecoin/validators/oracleNFT.plutus"

cardano-cli transaction build \
  --babbage-era \
  $PREVIEW \
  --tx-in $utxoin \
  --tx-out $address+$output+"$tokenamount $policyid.$tokenname" \
  --change-address $address \
  --mint="$tokenamount $policyid.$tokenname" \
  --minting-script-file $script \
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