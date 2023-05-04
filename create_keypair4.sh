** 1) create a folder 'keys' and navigate into this folder
** 2) navigate into the keys folder
** 3) 
** a) create keypairs #4
cardano-cli address key-gen --verification-key-file payment4.vkey --signing-key-file payment4.skey
cardano-cli stake-address key-gen --verification-key-file stake4.vkey --signing-key-file stake4.skey

** b) build address #4
cardano-cli address build \
--payment-verification-key-file payment4.vkey \
--stake-verification-key-file stake4.vkey \
--out-file testnet4.addr \
--testnet-magic 2