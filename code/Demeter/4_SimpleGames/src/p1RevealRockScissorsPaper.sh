utxoin="e9dc0610eb4b5a205a7111ee47adae7f0574a475d94cf26d62a8a4779ea04b7f#0"
policyid=$(cat /workspace/code/Demeter/4_SimpleGames/validators/testNFT.policy)
tokenname="426f756e74794e4654" #tokenname base-16 (hexadecimal) encoded
tokenamount="1"
address=$(cat /workspace/keys/alice.addr)
output="6000000"
collateral="238d2fe94ac6af5e999ce96471b6cd556db76f9d46be8a94464c406cb67df7bf#1"
signerPKH=$(cat /workspace/keys/alice.pkh)
changeaddress=$(cat /workspace/keys/alice.addr)
PREVIEW="--testnet-magic 2"
signingkeyfile="/workspace/keys/alice.skey"
validatorfile="/workspace/code/Demeter/4_SimpleGames/validators/rockScissorsPaper.plutus"
datumfileplayer2="/workspace/code/Demeter/4_SimpleGames/data/gameDatumPlayer2.json"
redeemerfileplayer1="/workspace/code/Demeter/4_SimpleGames/data/gameRedeemerPlayer1Reveal.json"
paramsfile="/workspace/data/protocolparams.json"
txunsignedfile="/workspace/code/Demeter/4_SimpleGames/txoutputs/grabRockScissorsPaperTestNFT.unsigned"
txsignedfile="/workspace/code/Demeter/4_SimpleGames/txoutputs/grabRockScissorsPaperTestNFT.signed"

cardano-cli transaction build \
  --babbage-era \
  $PREVIEW \
  --tx-in $collateral \
  --tx-in $utxoin \
  --tx-in-script-file $validatorfile \
  --tx-in-datum-file $datumfileplayer2 \
  --tx-in-redeemer-file $redeemerfileplayer1 \
  --required-signer-hash $signerPKH \
  --tx-in-collateral $collateral \
  --tx-out $address+$output+"$tokenamount $policyid.$tokenname" \
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