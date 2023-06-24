utxoin="e99ab519026f43ec1c2f4d697784d8fbd9e565f2f0c60cbd3d688f3eb7445317#0"
address="addr_test1qpc6mrwu9cucrq4w6y69qchflvypq76a47ylvjvm2wph4szeq579yu2z8s4m4tn0a9g4gfce50p25afc24knsf6pj96sz35wnt"
output="450000000"
collateral="3efc54e82642c3affc354f85e733188ade31c2b3bfe724ecc5d9cbed0a311474#0"
signerPKH=$(cat /workspace/keys/alice.pkh)
changeaddress=$(cat /workspace/keys/alice.addr)
PREVIEW="--testnet-magic 2"

cardano-cli transaction build \
  --babbage-era \
  $PREVIEW \
  --tx-in $utxoin \
  --tx-in-script-file /workspace/code/Demeter/1_JustValidators/testnet/handson0001.plutus \
  --tx-in-datum-file /workspace/code/Demeter/1_JustValidators/testnet/unit.json \
  --tx-in-redeemer-file /workspace/code/Demeter/1_JustValidators/testnet/unit.json \
  --required-signer-hash $signerPKH \
  --tx-in-collateral $collateral \
  --tx-out $address+$output \
  --change-address $changeaddress \
  --protocol-params-file /workspace/code/Demeter/1_JustValidators/data/protocol.params \
  --out-file /workspace/code/Demeter/1_JustValidators/output/grab.unsigned

cardano-cli transaction sign \
    --tx-body-file /workspace/code/Demeter/1_JustValidators/output/grab.unsigned \
    --signing-key-file /workspace/keys/alice.skey \
    $PREVIEW \
    --out-file /workspace/code/Demeter/1_JustValidators/output/grab.signed

cardano-cli transaction submit \
    $PREVIEW \
    --tx-file /workspace/code/Demeter/1_JustValidators/output/grab.signed

tid=$(cardano-cli transaction txid --tx-file /workspace/code/Demeter/1_JustValidators/output/grab.signed)
echo "transaction id: $tid"
echo "Cardanoscan: https://preview.cardanoscan.io/transaction/$tid"