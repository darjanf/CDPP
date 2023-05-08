# Native tokens
# From Mary/Allegra fork onwards, Cardano has a "Multi-Asset ledger"
# We now have the ability to mint native tokens
# Token: Digital representation of a real world asset

# Tokenname; must be base16 encoded
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

# create script that defines the policy verification key as a witness to sign the minting transaction
touch ../policy/policy.script
echo "" > ../policy/policy.script
echo "{" >> ../policy/policy.script 
echo "  \"keyHash\": \"$(cardano-cli address key-hash --payment-verification-key-file ../policy/policy.vkey)\"," >> ../policy/policy.script 
echo "  \"type\": \"sig\"" >> ../policy/policy.script 
echo "}" >> ../policy/policy.script

#To mint the native assets, we need to generate the policy ID from the script file we created.
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

#sending token to a wallet
fee="0"
receiver="addr_test1qq9hgw0wa42yr57n83v8873eg5m0x4rykrcv4m38f4ajnr6sxmksqph8dna8l7vqm25jpua2azft546x3eah8xz97rvsqta2gx"
receiver_output="10000000"
utxoin="711cd2eb7cc05b77637150fbb32ae68adebc42c02367956714e3dd2753527474#0"
funds="999638418"
output="999638418"

cardano-cli transaction build-raw \
--fee $fee \
--tx-in $utxoin \
--tx-out $receiver+$receiver_output+"2 $policyid.$tokenname1" \
--tx-out $address+$output+"9999998 $policyid.$tokenname1" \
--out-file rec_matx.raw

fee=$(cardano-cli transaction calculate-min-fee --tx-body-file rec_matx.raw --tx-in-count 1 --tx-out-count 2 --witness-count 1 $TESTNET --protocol-params-file protocol.json | cut -d " " -f1)

output=$(expr $funds - $fee - 10000000)

cardano-cli transaction build-raw  \
--fee $fee  \
--tx-in $utxoin  \
--tx-out $receiver+$receiver_output+"2 $policyid.$tokenname1"  \
--tx-out $address+$output+"9999998 $policyid.$tokenname1"  \
--out-file rec_matx.raw

cardano-cli transaction sign \
--signing-key-file payment4.skey \
$TESTNET \
--tx-body-file rec_matx.raw \
--out-file rec_matx.signed

cardano-cli transaction submit --tx-file rec_matx.signed $TESTNET