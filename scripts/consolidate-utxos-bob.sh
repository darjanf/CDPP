PREVIEW="--testnet-magic 2"
utxoin="70304e6117d9129148504ccefe798f03921d1926451885592826da3b2f4a5582#1"
utxoin2="79e93a7d16f2f53ad91a1fa0be351c3d59b3442e529098d02cc2e1e8a2d43bb4#1"
utxoin3="7af7c97fe606c47fa96661939c81a2ab47bc79bc92f80910978f60276c149e31#1"
utxoin4="b0658a1c0b8be88b2aff59a28dcda98fef8059a261e00dc6af5971470ef8c004#0"
utxoin5="b0658a1c0b8be88b2aff59a28dcda98fef8059a261e00dc6af5971470ef8c004#1"
utxoin6="c5f3a167bd92d9473277dbad845c838b91bd34e5e3bde259303b586ee21e9567#2"
receiveraddress=$(cat /workspace/keys/bob.addr)
changeaddress=$(cat /workspace/keys/bob.addr)
output="9865000000"
paramsfile="/workspace/data/protocolparams.json"
txunsignedfile="/workspace/code/Demeter/5_Stablecoin/txoutputs/consolidateUtxosBob.unsigned"
txsignedfile="/workspace/code/Demeter/5_Stablecoin/txoutputs/consolidateUtxosBob.signed"
signingkeyfile="/workspace/keys/bob.skey"

cardano-cli transaction build \
  --babbage-era \
  $PREVIEW \
  --tx-in $utxoin \
  --tx-in $utxoin2 \
  --tx-in $utxoin3 \
  --tx-in $utxoin4 \
  --tx-in $utxoin5 \
  --tx-in $utxoin6 \
  --tx-out $receiveraddress+$output \
  --change-address $changeaddress \
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