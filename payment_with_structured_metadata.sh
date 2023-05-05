#https://github.com/mallapurbharat/cardano-tx-sample/blob/main/1_native_exercises/3_advanced/1_metadata/1_b_metadata_exercise.md

cardano-cli query protocol-parameters --testnet-magic 2 --out-file ./protocolparams.json

cardano-cli query utxo --address $(cat testnet2.addr) $TESTNET

cardano-cli transaction build-raw \
--babbage-era \
--tx-in cdc424a8402d740a4729f8078f5aacfb4505f5e6e1f6c6dabcce598a05339c1a#0 \
--tx-out $(cat ./testnet1.addr)+0 \
--metadata-json-file ../data/structured_metadata.json \
--fee 0 \
--out-file ./tx.draft

cardano-cli transaction calculate-min-fee \
--tx-body-file tx.draft \
--tx-in-count 1 \
--tx-out-count 1 \
--witness-count 1 \
--testnet-magic 2 \
--protocol-params-file ./protocolparams.json
# result = 177425

# 5000000000 - 177425 = 4999822575

cardano-cli transaction build-raw \
--babbage-era \
--tx-in cdc424a8402d740a4729f8078f5aacfb4505f5e6e1f6c6dabcce598a05339c1a#0 \
--tx-out $(cat testnet1.addr)+4999822575 \
--metadata-json-file ../data/structured_metadata.json \
--fee 177425 \
--out-file tx.draft

cardano-cli transaction sign \
--tx-body-file ./tx.draft \
--signing-key-file ./payment2.skey \
--testnet-magic 2 \
--out-file ./tx.signed

cardano-cli transaction submit \
--testnet-magic 2 \
--tx-file tx.signed

cardano-cli transaction txid --tx-file ./tx.signed

# transaction # 05394ea47fb8ce4027ce4564f45d3d044845219e1a46a683dd3cf4ba7c594ab9
# https://preview.cexplorer.io/tx/05394ea47fb8ce4027ce4564f45d3d044845219e1a46a683dd3cf4ba7c594ab9/metadata#data

