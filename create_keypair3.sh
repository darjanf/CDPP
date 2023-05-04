** 1) create a folder 'keys' and navigate into this folder
** 2) navigate into the keys folder
** 3) 
** a) create keypairs #3
cardano-cli address key-gen --verification-key-file payment3.vkey --signing-key-file payment3.skey
cardano-cli stake-address key-gen --verification-key-file stake3.vkey --signing-key-file stake3.skey

** b) build address #3
cardano-cli address build \
--payment-verification-key-file payment3.vkey \
--stake-verification-key-file stake3.vkey \
--out-file testnet3.addr \
--testnet-magic 2