# Native Tokens
# From Mary/Allegra fork onwards, Cardano has a "Multi-Asset ledger"
# We now have the ability to mint native tokens
# Token: Digital representation of a real world asset

tokenname1=$(echo -n "DF-Token" | xxd -ps | tr -d '\n')
tokenamount="10000000"
output="0"

cardano-cli query utxo --address $(cat testnet4.addr) $TESTNET
address=$(cat ./testnet4.addr)
utxoin="d3f3fd398b69279256d59c82dc6456ab9f8f074e23ec6d973f9c2a62a1884875#0"
funds="999821431"
policyid=$(cat ../policy/policyID)
fee="300000"

mkdir policy

cardano-cli address key-gen --verification-key-file ../policy/policy.vkey --signing-key-file ../policy/policy.skey
cardano-cli stake-address key-gen --verification-key-file ../policy/policystake.vkey --signing-key-file ../policy/policystake.skey

cardano-cli address build \
--payment-verification-key-file ../policy/policy.vkey \
--stake-verification-key-file ../policy/policystake.vkey \
--out-file policy.addr \
--testnet-magic 2

touch ../policy/policy.script
echo "" > ../policy/policy.script
echo "{" >> ../policy/policy.script 
echo "  \"keyHash\": \"$(cardano-cli address key-hash --payment-verification-key-file ../policy/policy.vkey)\"," >> ../policy/policy.script 
echo "  \"type\": \"sig\"" >> ../policy/policy.script 
echo "}" >> ../policy/policy.script

cardano-cli transaction policyid --script-file ../policy/policy.script > ../policy/policyID

cardano-cli transaction build-raw \
--fee $fee \
--tx-in $utxoin \
--tx-out $address+$output+"$tokenamount $policyid.$tokenname1" \
--mint "$tokenamount $policyid.$tokenname1" \
--minting-script-file ../policy/policy.script \
--out-file matx.raw

cardano-cli query protocol-parameters $TESTNET --out-file protocolparams.json
fee=$(cardano-cli transaction calculate-min-fee --tx-body-file matx.raw --tx-in-count 1 --tx-out-count 1 --witness-count 2 $TESTNET --protocol-params-file protocolparams.json | cut -d " " -f1)

output=$(expr $funds - $fee)

cardano-cli transaction build-raw \
--fee $fee  \
--tx-in $utxoin  \
--tx-out $address+$output+"$tokenamount $policyid.$tokenname1" \
--mint "$tokenamount $policyid.$tokenname1" \
--minting-script-file ../policy/policy.script \
--out-file matx.raw

cardano-cli transaction sign \
--signing-key-file payment4.skey \
--signing-key-file ../policy/policy.skey \
--testnet-magic 2 \
--tx-body-file matx.raw \
--out-file matx.signed

cardano-cli transaction submit --tx-file matx.signed --testnet-magic 2

cardano-cli query utxo --address $address $TESTNET