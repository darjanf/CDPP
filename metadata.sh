# https://github.com/mallapurbharat/cardano-tx-sample/blob/main/1_native_exercises/3_advanced/1_metadata/1_a_metadata.md

cardano-cli transaction build-raw \
--babbage-era \
--tx-in dddfec6950ff3b320140df6b6c5f6f7c0c726c0dc01279a7a61cfb3d2e29962e#1 \
--tx-out $(cat ./testnet2.addr)+0 \
--metadata-json-file ../data/metadata.json \
--fee 0 \
--out-file ./tx.draft

cardano-cli transaction calculate-min-fee \
--tx-body-file tx.draft \
--tx-in-count 1 \
--tx-out-count 1 \
--witness-count 1 \
--testnet-magic 2 \
--protocol-params-file protocolparams.json
# result = 174257

# 999664686 - 174257 = 999490429

cardano-cli transaction build-raw \
--babbage-era \
--tx-in dddfec6950ff3b320140df6b6c5f6f7c0c726c0dc01279a7a61cfb3d2e29962e#1 \
--tx-out $(cat testnet2.addr)+999490429 \
--metadata-json-file ../data/metadata.json \
--fee 174257 \
--out-file tx.draft

cardano-cli transaction sign --tx-body-file ./tx.draft --signing-key-file ./payment1.skey --testnet-magic 2 --out-file ./tx.signed

cardano-cli transaction submit \
--testnet-magic 2 \
--tx-file tx.signed

cardano-cli transaction txid --tx-file ./tx.signed