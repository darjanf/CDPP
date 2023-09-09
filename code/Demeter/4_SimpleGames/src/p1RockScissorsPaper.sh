utxoin="b37638182df8ad1ac7a046529fa9be42734a11f0d21670b90a152c83acf6ba9d#1"
policyid=$(cat /workspace/code/Demeter/4_SimpleGames/validators/testNFT.policy)
tokenname="426f756e74794e4654" #tokenname base-16 (hexadecimal) encoded
tokenamount="1"
deltaamount="7"
contractaddress=$(cat /workspace/code/Demeter/4_SimpleGames/validators/rockScissorsPaper.addr)
changeaddress=$(cat /workspace/keys/alice.addr)
datumfileplayer1="/workspace/code/Demeter/4_SimpleGames/data/gameDatumPlayer1.json"
paramsfile="/workspace/data/protocolparams.json"
output="3000000"
output2="20000000"
PREVIEW="--testnet-magic 2"
signingkeyfile="/workspace/keys/alice.skey"
txunsignedfile="/workspace/code/Demeter/4_SimpleGames/txoutputs/giveRockScissorsPaperTestNFT.unsigned"
txsignedfile="/workspace/code/Demeter/4_SimpleGames/txoutputs/giveRockScissorsPaperTestNFT.signed"

#  --tx-out $contractaddress+$output+"$tokenamount $policyid.$tokenname" \

cardano-cli transaction build \
  --babbage-era \
  $PREVIEW \
  --tx-in $utxoin \
  --tx-out $contractaddress+$output+"$tokenamount $policyid.$tokenname" \
  --tx-out-datum-hash-file $datumfileplayer1 \
  --tx-out $changeaddress+$output2+"$deltaamount $policyid.$tokenname" \
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
echo "Cexplorer: https://preview.cardanoscan.io/transaction/$tid"