** 1) create a folder 'keys' and navigate into this folder
** 2) navigate into the keys folder
** 3) 
** a) create keypairs #1
cardano-cli address key-gen --verification-key-file payment1.vkey --signing-key-file payment1.skey
cardano-cli stake-address key-gen --verification-key-file stake1.vkey --signing-key-file stake1.skey

** b) build address #1
cardano-cli address build \ 
--payment-verification-key-file payment1.vkey \
--stake-verification-key-file stake1.vkey \
--out-file testnet1.addr \
--testnet-magic 2