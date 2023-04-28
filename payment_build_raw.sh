cardano-cli query protocol-parameters --testnet-magic 2 --out-file ./protocolparams.json
#cardano-cli query utxo --address $(cat testnet1.addr) $TESTNET
UTXO1=4d3ed1010783353b03a95e09e3ff995ce1fd449b98bb9086ad0ed538692480c8#0

cardano-cli transaction build-raw \
--babbage-era \
--tx-in $UTXO1 \
--tx-out $(cat testnet2.addr)+2500000000 \
--tx-out $(cat testnet1.addr)+0 \
--invalid-hereafter 0 \
--fee 0 \
--out-file tx.draft

cardano-cli transaction calculate-min-fee \
--tx-body-file tx.draft \
--tx-in-count 1 \
--tx-out-count 2 \
--witness-count 1 \
$TESTNET \
--protocol-params-file protocolparams.json

FEE=176897

BALANCE=$(expr 10000000000 - 2500000000 - $FEE)

cardano-cli query tip $TESTNET
#lookup the slot number

VALIDTILL=$(expr 16029888 + 600) #set in the slot number + 600 slots

cardano-cli transaction build-raw \
--babbage-era \
--tx-in $UTXO1 \
--tx-out $(cat testnet2.addr)+2500000000 \
--tx-out $(cat testnet1.addr)+$BALANCE \
--invalid-hereafter $VALIDTILL \
--fee $FEE \
--out-file tx.raw

cardano-cli transaction sign \
--tx-body-file tx.raw \
--signing-key-file payment1.skey \
$TESTNET \
--out-file tx.signed

cardano-cli transaction submit \
--tx-file tx.signed \
$TESTNET

cardano-cli transaction txid --tx-file tx.signed