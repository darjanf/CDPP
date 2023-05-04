** 1) navigate to docs.cardano.org/cardano-testnet/tools/faucet and send 10000 ADA to testnet1.addr
** 2) query testnet1.addr after sending ADA coins using faucet

cardano-cli query utxo --address "$(cat ./testnet1.addr)" --testnet-magic 2

** result output
                           TxHash                                 TxIx        Amount
--------------------------------------------------------------------------------------
453160329e3d5095e2de2848201902bf71ac46a5e62a9f3609895ed8ea804405     0        10000000000 lovelace + TxOutDatumNone

**query testnet2.addr without ADA coins

cardano-cli query utxo --address "$(cat ./testnet2.addr)" --testnet-magic 2

** result output
                           TxHash                                 TxIx        Amount
--------------------------------------------------------------------------------------