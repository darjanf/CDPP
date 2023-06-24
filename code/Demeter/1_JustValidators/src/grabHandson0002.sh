utxoin="f552001c49d8b5a08f8502d4467b5494ad5c696ab23db4c50f50c57b7cba0e08#0"
address="addr_test1qpc6mrwu9cucrq4w6y69qchflvypq76a47ylvjvm2wph4szeq579yu2z8s4m4tn0a9g4gfce50p25afc24knsf6pj96sz35wnt"
output="450000000"
collateral="21abd9f03022d8f8cbd62ae7c7a473e4cfb8f8b2990af7465725988575a792d4#0"
signerPKH=$(cat /workspace/keys/alice.pkh)
changeaddress=$(cat /workspace/keys/alice.addr)
PREVIEW="--testnet-magic 2"

cardano-cli transaction build \
  --babbage-era \
  $PREVIEW \
  --tx-in $utxoin \
  --tx-in-script-file /workspace/code/Demeter/1_JustValidators/testnet/handson0002.plutus \
  --tx-in-datum-file /workspace/code/Demeter/1_JustValidators/testnet/goodOWD.json \
  --tx-in-redeemer-file /workspace/code/Demeter/1_JustValidators/testnet/goodOWR.json \
  --required-signer-hash $signerPKH \
  --tx-in-collateral $collateral \
  --tx-out $address+$output \
  --change-address $changeaddress \
  --protocol-params-file /workspace/code/Demeter/1_JustValidators/data/protocol.params \
  --out-file /workspace/code/Demeter/1_JustValidators/output/grabHandson0002.unsigned

cardano-cli transaction sign \
    --tx-body-file /workspace/code/Demeter/1_JustValidators/output/grabHandson0002.unsigned \
    --signing-key-file /workspace/keys/alice.skey \
    $PREVIEW \
    --out-file /workspace/code/Demeter/1_JustValidators/output/grabHandson0002.signed

cardano-cli transaction submit \
    $PREVIEW \
    --tx-file /workspace/code/Demeter/1_JustValidators/output/grabHandson0002.signed

tid=$(cardano-cli transaction txid --tx-file /workspace/code/Demeter/1_JustValidators/output/grabHandson0002.signed)
echo "transaction id: $tid"
echo "Cardanoscan: https://preview.cardanoscan.io/transaction/$tid"