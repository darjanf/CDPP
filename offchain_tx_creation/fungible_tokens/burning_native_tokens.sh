# Bruning native tokens
address=$(cat ./testnet4.addr)
tokenname1=$(echo -n "DF-Token" | xxd -ps | tr -d '\n')
policyid=$(cat ../policy/policyID)
fee="0"
utxoin="3576af8ca02fbabbba877e5decaf246e7fd24a7003d98897f9eb21f7463a67a8#1"
funds="989457473"
burnfee="0"
burnoutput="0"

cardano-cli transaction build-raw \
 --fee $burnfee \
 --tx-in $utxoin \
 --tx-out $address+$burnoutput+"9994998 $policyid.$tokenname1"  \
 --mint="-5000 $policyid.$tokenname1" \
 --minting-script-file ../policy/policy.script \
 --out-file burning.raw

 burnfee=$(cardano-cli transaction calculate-min-fee --tx-body-file burning.raw --tx-in-count 1 --tx-out-count 1 --witness-count 2 $TESTNET --protocol-params-file protocol.json | cut -d " " -f1)

 burnoutput=$(expr $funds - $burnfee)

cardano-cli transaction build-raw \
 --fee $burnfee \
 --tx-in $utxoin \
 --tx-out $address+$burnoutput+"9994998 $policyid.$tokenname1"  \
 --mint="-5000 $policyid.$tokenname1" \
 --minting-script-file ../policy/policy.script \
 --out-file burning.raw

cardano-cli transaction sign  \
--signing-key-file payment4.skey  \
--signing-key-file ../policy/policy.skey  \
$TESTNET  \
--tx-body-file burning.raw  \
--out-file burning.signed

cardano-cli transaction submit --tx-file burning.signed $TESTNET

cardano-cli query utxo --address $(cat testnet4.addr) $TESTNET