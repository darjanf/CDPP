# query utxo of specific address

cardano-cli query utxo --address $(cat testnet1.addr) $TESTNET

# result should look like this:
#                            TxHash                                 TxIx        Amount
# --------------------------------------------------------------------------------------
# ab8bfa1dd46e4ef8497a16d5237898200e5d5a44c75cb9b446e4c4fd5faaa187     1        2999462093 lovelace + TxOutDatumNone
#