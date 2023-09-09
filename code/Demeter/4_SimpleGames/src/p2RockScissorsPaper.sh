utxoin="746fbb47d40f3329526f76523b79d1fe11e46e3949485721a96e8b8353d2b116#0"
policyid=$(cat /workspace/code/Demeter/4_SimpleGames/validators/testNFT.policy)
tokenname="426f756e74794e4654" #tokenname base-16 (hexadecimal) encoded
tokenamount="1"
contractaddress=$(cat /workspace/code/Demeter/4_SimpleGames/validators/rockScissorsPaper.addr)
output="6000000"
collateral="e9dc0610eb4b5a205a7111ee47adae7f0574a475d94cf26d62a8a4779ea04b7f#1"
signerPKH=$(cat /workspace/keys/bob.pkh)
changeaddress=$(cat /workspace/keys/bob.addr)
PREVIEW="--testnet-magic 2"
signingkeyfile="/workspace/keys/bob.skey"
validatorfile="/workspace/code/Demeter/4_SimpleGames/validators/rockScissorsPaper.plutus"
datumfileplayer1="/workspace/code/Demeter/4_SimpleGames/data/gameDatumPlayer1.json"
datumfileplayer2="/workspace/code/Demeter/4_SimpleGames/data/gameDatumPlayer2.json"
redeemerfileplayer2="/workspace/code/Demeter/4_SimpleGames/data/gameRedeemerPlayer2.json"
paramsfile="/workspace/data/protocolparams.json"
txunsignedfile="/workspace/code/Demeter/4_SimpleGames/txoutputs/grabRockScissorsPaperTestNFT.unsigned"
txsignedfile="/workspace/code/Demeter/4_SimpleGames/txoutputs/grabRockScissorsPaperTestNFT.signed"

cardano-cli transaction build \
  --babbage-era \
  $PREVIEW \
  --tx-in $collateral \
  --tx-in $utxoin \
  --tx-in-script-file $validatorfile \
  --tx-in-datum-file $datumfileplayer1 \
  --tx-in-redeemer-file $redeemerfileplayer2 \
  --required-signer-hash $signerPKH \
  --tx-in-collateral $collateral \
  --tx-out $contractaddress+$output+"$tokenamount $policyid.$tokenname" \
  --tx-out-datum-embed-file $datumfileplayer2 \
  --change-address $changeaddress \
  --invalid-hereafter 23297425 \
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