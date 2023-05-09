# sending non fungible tokens to daedalus wallet

cardano-cli query utxo --address $(cat testnet3.addr) $TESTNET

sender_address=$(cat ./testnet3.addr)
realtokenname="NFT1"
nft_name=$(echo -n $realtokenname | xxd -ps | tr -d '\n')
policyid=$(cat ../policy/nft_policyID)
fee="0"
utxoin="dcd9b373eb498cacec9da7510667692b9294897bd6d7d14e872263bcd0296821#0"
receiver="addr_test1qq5fad0de627gv3688mzk7sr6ve87a3q7nj423jjs7kpgz2sxmksqph8dna8l7vqm25jpua2azft546x3eah8xz97rvssm4qtq"
receiver_output="1400000"

cardano-cli transaction build-raw \
--fee $fee \
--tx-in $utxoin \
--tx-out $receiver+$receiver_output+"1 $policyid.$nft_name" \
--out-file sending_nft_tx.raw

fee=$(cardano-cli transaction calculate-min-fee --tx-body-file sending_nft_tx.raw --tx-in-count 1 --tx-out-count 1 --witness-count 1 $TESTNET --protocol-params-file protocol.json | cut -d " " -f1)

receiver_output=$(expr 1400000 - $fee)

cardano-cli transaction build-raw \
--fee $fee \
--tx-in $utxoin \
--tx-out $receiver+$receiver_output+"1 $policyid.$nft_name" \
--out-file sending_nft_tx.raw

cardano-cli transaction sign \
--signing-key-file ./payment3.skey \
$TESTNET \
--tx-body-file sending_nft_tx.raw \
--out-file sending_nft_tx.signed

cardano-cli transaction submit --tx-file sending_nft_tx.signed $TESTNET

cardano-cli query utxo --address $(cat testnet3.addr) $TESTNET