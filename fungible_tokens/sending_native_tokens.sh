# Sending tokens to a wallet
address=$(cat ./testnet4.addr)
tokenname1=$(echo -n "DF-Token" | xxd -ps | tr -d '\n')
policyid=$(cat ../policy/policyID)
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