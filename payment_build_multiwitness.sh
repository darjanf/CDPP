cardano-cli query protocol-parameters --testnet-magic 2 --out-file ./protocolparams.json

cardano-cli query utxo --address $(cat testnet1.addr) $TESTNET
UTXO1=111661cd643344fb1f8bef6a3c6e6466c06cab99826d07fb8671076b5efbe89f#1

cardano-cli query utxo --address $(cat testnet2.addr) $TESTNET
UTXO2=111661cd643344fb1f8bef6a3c6e6466c06cab99826d07fb8671076b5efbe89f#0

cardano-cli transaction build \
--babbage-era \
--testnet-magic 2 \
--tx-in $UTXO1 \
--tx-in $UTXO2 \
--tx-out $(cat ../keys/testnet3.addr)+"5000000000" \
--change-address $(cat ../keys/testnet2.addr) \
--protocol-params-file ./protocolparams.json \
--out-file payment1_witness.unsigned

cardano-cli transaction sign \
--tx-body-file ./payment1_witness.unsigned \
--signing-key-file ../keys/payment1.skey \
--signing-key-file ../keys/payment2.skey \
--testnet-magic 2 \
--out-file payment1_witness.signed

cardano-cli transaction submit \
--testnet-magic 2 \
--tx-file payment1_witness.signed

cardano-cli transaction txid --tx-file payment1_witness.signed