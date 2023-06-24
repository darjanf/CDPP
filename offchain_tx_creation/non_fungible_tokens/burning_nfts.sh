# Burning non fungible tokens
cardano-cli query utxo --address $(cat ./testnet3.addr) $TESTNET

era="--babbage-era"
utxoin1="37690861846c5899a10acd42a2cb73dead7ae1d08ac722efbb0da0d1e28a6357#0"
utxoin2="a98ac5da447f8fc1e00d7c40e31bfcbfc38aaa6ee375e60f2864385d3a34c56f#1"
address=$(cat ./testnet3.addr)
burnfee="0"
burnoutput="1400000"
policyid=$(cat ../policy/nft_policyID)
realtokenname="NFT1"
tokenname=$(echo -n $realtokenname | xxd -ps | tr -d '\n')
script="../policy/nft_policy.script"

cardano-cli transaction build \
$era \
--tx-in $utxoin1 \
--tx-in $utxoin2 \
--tx-out $address+$burnoutput --mint="-1 $policyid.$tokenname" \
--minting-script-file $script \
--change-address $address \
--witness-override 2 \
--out-file burning.raw $TESTNET

cardano-cli transaction sign  \
--signing-key-file payment3.skey  \
--signing-key-file ../policy/nft_policy.skey \
$TESTNET \
--tx-body-file burning.raw \
--out-file burning.signed

cardano-cli transaction submit --tx-file burning.signed $TESTNET