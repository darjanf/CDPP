cardano-cli query protocol-parameters --testnet-magic 2 --out-file ./protocolparams.json

cardano-cli transaction build \
--babbage-era \
--testnet-magic 2 \
--tx-in "cdc424a8402d740a4729f8078f5aacfb4505f5e6e1f6c6dabcce598a05339c1a#0" \
--tx-out $(cat ../keys/testnet2.addr)+"1000000000" \
--change-address $(cat ../keys/testnet1.addr) \
--protocol-params-file ./protocolparams.json \
--out-file payment1.unsigned

cardano-cli transaction sign \
--tx-body-file ./payment1.unsigned \
--signing-key-file ../keys/payment1.skey \
--testnet-magic 2 \
--out-file payment1.signed

cardano-cli transaction submit \
--testnet-magic 2 \
--tx-file payment1.signed