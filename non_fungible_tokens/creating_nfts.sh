# Native non fungible tokens

cardano-cli query utxo --address $(cat testnet3.addr) $TESTNET

realtokenname="NFT2"
tokenname=$(echo -n $realtokenname | xxd -ps | tr -d '\n')
tokenamount="1"
fee="0"
output="0"
ipfs_hash="ipfs://QmRhTTbUrPYEw3mJGGhQqQST9k86v1DPBiTTWJGKDJsVFw"
address=$(cat ./testnet3.addr)

cardano-cli address key-gen \
--verification-key-file ../policy/nft_policy.vkey \
--signing-key-file ../policy/nft_policy.skey

cardano-cli address key-hash --payment-verification-key-file ../policy/nft_policy.vkey
cardano-cli query tip $TESTNET
slotnumber=$(expr 16967353 + 10000)

touch ../policy/nft_policy.script
# insert following json in nft_policy.script
# {
#   "type": "all",
#   "scripts":
#   [
#     {
#       "type": "before",
#       "slot": 16906924
#     },
#     {
#       "type": "sig",
#       "keyHash": "f1b9332a44159ff79ce4ba63d9a7b21aae7781c02c3e98bf294f79f4"
#     }
#   ]
# }

cardano-cli transaction policyid --script-file ../policy/nft_policy.script > ../policy/nft_policyID

#create nft_metadata.json
# {
#     "721": {
#         "950fe5235a62693e41813c3f1e1363578e77c6a6e3a7bb86e0cbcd99": {
#           "NFT1": {
#             "description": "This is my first NFT thanks to EMURGO Academy",
#             "name": "EMURGO NFT guide token",
#             "id": 1,
#             "image": "ipfs://QmRhTTbUrPYEw3mJGGhQqQST9k86v1DPBiTTWJGKDJsVFw"
#           }
#         }
#     }
# }

era="--babbage-era"
utxoin="e1dffa7cacb5835b912440bc95af042d0278cb2ffa8bd3fb68b840a2077fcf58#0"
utxoin2="e1dffa7cacb5835b912440bc95af042d0278cb2ffa8bd3fb68b840a2077fcf58#1"
policyid=$(cat ../policy/nft_policyID)
output=1400000
script="../policy/nft_policy.script"

cardano-cli transaction build \
$era \
--tx-in $utxoin \
--tx-in $utxoin2 \
--tx-out $address+$output+"$tokenamount $policyid.$tokenname" \
--change-address $address \
--mint="$tokenamount $policyid.$tokenname" \
--minting-script-file $script \
--metadata-json-file ../data/nft_metadata.json  \
--witness-override 2 \
--out-file matx.raw $TESTNET
#--invalid-hereafter $slotnumber \


cardano-cli transaction sign  \
--signing-key-file payment3.skey  \
--signing-key-file ../policy/nft_policy.skey  \
$TESTNET --tx-body-file matx.raw  \
--out-file matx.signed

cardano-cli transaction submit --tx-file matx.signed $TESTNET

cardano-cli query utxo --address $address $TESTNET

cardano-cli transaction txid --tx-file matx.signed

cardano-cli query utxo --address $(cat testnet3.addr) $TESTNET