cardano-cli query protocol-parameters --testnet-magic 2 --out-file ./protocolparams.json

KEYHASH1=$(cardano-cli address key-hash --payment-verification-key-file payment1.vkey)
KEYHASH2=$(cardano-cli address key-hash --payment-verification-key-file payment2.vkey)
KEYHASH3=$(cardano-cli address key-hash --payment-verification-key-file payment3.vkey)

cardano-cli address build --payment-script-file ./multisigpolicy.script $TESTNET --out-file ./multisig.addr

cardano-cli transaction build \
--babbage-era \
--testnet-magic 2 \
--tx-in "cdc424a8402d740a4729f8078f5aacfb4505f5e6e1f6c6dabcce598a05339c1a#1" \
--tx-out $(cat ./multisig.addr)+"1000000000" \
--change-address $(cat ./testnet1.addr) \
--protocol-params-file ./protocolparams.json \
--out-file payment1.unsigned

cardano-cli transaction sign \
--tx-body-file ./payment1.unsigned \
--signing-key-file ./payment1.skey \
--testnet-magic 2 \
--out-file payment1.signed

cardano-cli transaction submit \
--testnet-magic 2 \
--tx-file payment1.signed

cardano-cli query utxo --address $(cat ./multisig.addr) $TESTNET
UTXO1=dddfec6950ff3b320140df6b6c5f6f7c0c726c0dc01279a7a61cfb3d2e29962e#0

cardano-cli transaction build \
--babbage-era \
--tx-in $UTXO1 \
--change-address $(cat testnet4.addr) \
--tx-in-script-file ./multisigpolicy.script \
--witness-override 3 \
--out-file txmultisig.raw $TESTNET

cardano-cli transaction view --tx-body-file txmultisig.raw

cardano-cli transaction witness --signing-key-file payment1.skey --tx-body-file txmultisig.raw  --out-file payment1.witness

cardano-cli transaction witness --signing-key-file payment2.skey --tx-body-file txmultisig.raw  --out-file payment2.witness

cardano-cli transaction witness --signing-key-file payment3.skey --tx-body-file txmultisig.raw  --out-file payment3.witness

cardano-cli transaction assemble --tx-body-file txmultisig.raw --witness-file payment1.witness --witness-file payment2.witness --witness-file payment3.witness --out-file txmultisig.signed

cardano-cli transaction submit --tx-file txmultisig.signed $TESTNET

cardano-cli query utxo --address $(cat testnet4.addr) $TESTNET