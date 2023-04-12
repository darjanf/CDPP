cardano-cli query protocol-parameters --testnet-magic 2 --out-file ./protocol.params

cardano-cli transaction build \
--babbage-era \
--testnet-magic 2 \
--tx-in "453160329e3d5095e2de2848201902bf71ac46a5e62a9f3609895ed8ea804405#0" \
--tx-out $(cat ../keys/testnet2.addr)+"5000000000" \
--change-address $(cat ../keys/testnet1.addr) \
--protocol-params-file ./protocol.params \
--out-file payment1.unsigned

cardano-cli transaction sign \
--tx-body-file ./payment1.unsigned \
--signing-key-file ../keys/payment1.skey \
--testnet-magic 2 \
--out-file payment1.signed

cardano-cli transaction submit \
--testnet-magic 2 \
--tx-file payment1.signed