cardano-cli query protocol-parameters --testnet-magic 2 --out-file ./protocolparams.json

cardano-cli query utxo --address $(cat testnet1.addr) $TESTNET
#testnet1 is now the recipient

cardano-cli query utxo --address $(cat testnet2.addr) $TESTNET
UTXO2=41e69f6780a6a0ddadc5bfca860aac11c0bf8f06e75d3e4b061dbcc25c8ce922#1

cardano-cli query utxo --address $(cat testnet3.addr) $TESTNET
UTXO3=41e69f6780a6a0ddadc5bfca860aac11c0bf8f06e75d3e4b061dbcc25c8ce922#0

cardano-cli transaction build-raw \
--babbage-era \
--tx-in $UTXO2 \
--tx-in $UTXO3 \
--tx-out $(cat testnet1.addr)+7000000000 \
--tx-out $(cat testnet3.addr)+0 \
--invalid-hereafter 0 \
--fee 0 \
--out-file tx_witness.draft

cardano-cli transaction calculate-min-fee \
--tx-body-file tx_witness.draft \
--tx-in-count 2 \
--tx-out-count 2 \
--witness-count 2 \
$TESTNET \
--protocol-params-file protocolparams.json

FEE=186621

BALANCE=$(expr 4999648714 + 5000000000 - 7000000000 - $FEE)

cardano-cli query tip $TESTNET
#lookup the slot number

VALIDTILL=$(expr 16032269 + 600) #set in the slot number + 600 slots

cardano-cli transaction build-raw \
--babbage-era \
--tx-in $UTXO2 \
--tx-in $UTXO3 \
--tx-out $(cat testnet1.addr)+7000000000 \
--tx-out $(cat testnet3.addr)+$BALANCE \
--invalid-hereafter $VALIDTILL \
--fee $FEE \
--out-file txmultutxo.raw

cardano-cli transaction view --tx-body-file txmultutxo.raw

cardano-cli transaction witness --signing-key-file payment2.skey --tx-body-file txmultutxo.raw --out-file user2.witness $TESTNET

cardano-cli transaction witness --signing-key-file payment3.skey --tx-body-file txmultutxo.raw --out-file user3.witness $TESTNET

cardano-cli transaction assemble --tx-body-file txmultutxo.raw --witness-file user2.witness --witness-file user3.witness --out-file txmultutxo.signed

cardano-cli transaction submit --tx-file txmultutxo.signed $TESTNET