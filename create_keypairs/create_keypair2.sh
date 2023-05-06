# 1) create a folder 'keys' and navigate into this folder
# 2) navigate into the keys folder
# 3) 
# a) create keypairs #2
cardano-cli address key-gen --verification-key-file payment2.vkey --signing-key-file payment2.skey
cardano-cli stake-address key-gen --verification-key-file stake2.vkey --signing-key-file stake2.skey

# b) build address #2
cardano-cli address build \
--payment-verification-key-file payment2.vkey \
--stake-verification-key-file stake2.vkey \
--out-file testnet2.addr \
--testnet-magic 2