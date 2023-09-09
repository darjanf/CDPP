PREVIEW="--testnet-magic 2"
utxoin="0b40630af3a5fefec0af5951553902697f9e81f915e80013b6fa6d9db51be3f3#2"
utxoin2="410dd1ae60af499c9e4dafbe8bb9d7a0f2eed09eb0a876c85c7d4c627fb8496e#2"
utxoin3="4d8b1638c84272263fdf73ef008aef0ece93bab52bd1281dd21b2530321096a8#2"
utxoin4="746fbb47d40f3329526f76523b79d1fe11e46e3949485721a96e8b8353d2b116#2"
utxoin5="78894548c7124624688caf016306734aac48efa9e9a66fa8b6c70488ea51725e#2"
utxoin6="895874e731d48d8ca659fe88651ecd73b8c8bc6716964dbbfa248d3d34061525#2"
utxoin7="9d320342280a09c8e25882f28c4f657f40bf3bbefdee36c43592af875bee570d#2"
utxoin8="9febc566f88211b7b5ffd638acfe7964a6942f1a27633a4b51e4996db8e7063a#2"
utxoin9="afad6d9ceb3afffaba92a48726709c4699bfea5a4947ff58f8a64eeae7b686d3#2"
utxoin10="b37638182df8ad1ac7a046529fa9be42734a11f0d21670b90a152c83acf6ba9d#2"
utxoin11="ba40219f00cedc38b7306f1d71202d81c6e6a9484556fc6385f5ec8cd0f6718d#2"
utxoin12="d4d6607a43f3599909f2b80e688818ebe3c3d8cd6fab78f38515b9bb51848570#0"
utxoin13="d4d6607a43f3599909f2b80e688818ebe3c3d8cd6fab78f38515b9bb51848570#1"
utxoin14="dd5b9d719fc0e64cd3d6053900a2f968a091f129c4a2324bdb7ab2f5511575b4#2"
utxoin15="e2264522b582e863489a7a79265a9bf22609673d54f4a5e83e8980d52a456c30#2"
utxoin16="e8a72ee65f97cd51335bd0fededa19b0313d2163ad1987442ca36339b32f7a8a#2"
utxoin17="ef8f69a3f08a08540c2f4d46b132f33677831ca3a690f65dcf4c59b6c7b211f0#2"
utxoin18="f0bafbce34559a1d0c09315d2493f74d23d8e2aba002ae213dc331e1c640583c#2"
receiveraddress=$(cat /workspace/keys/alice.addr)
changeaddress=$(cat /workspace/keys/alice.addr)
output="9820000000"
paramsfile="/workspace/data/protocolparams.json"
txunsignedfile="/workspace/code/Demeter/5_Stablecoin/txoutputs/consolidateUtxosAlice.unsigned"
txsignedfile="/workspace/code/Demeter/5_Stablecoin/txoutputs/consolidateUtxosAlice.signed"
signingkeyfile="/workspace/keys/alice.skey"

cardano-cli transaction build \
  --babbage-era \
  $PREVIEW \
  --tx-in $utxoin \
  --tx-in $utxoin2 \
  --tx-in $utxoin3 \
  --tx-in $utxoin4 \
  --tx-in $utxoin5 \
  --tx-in $utxoin6 \
  --tx-in $utxoin7 \
  --tx-in $utxoin8 \
  --tx-in $utxoin9 \
  --tx-in $utxoin10 \
  --tx-in $utxoin11 \
  --tx-in $utxoin12 \
  --tx-in $utxoin13 \
  --tx-in $utxoin14 \
  --tx-in $utxoin15 \
  --tx-in $utxoin16 \
  --tx-in $utxoin17 \
  --tx-in $utxoin18 \
  --tx-out $receiveraddress+$output \
  --change-address $changeaddress \
  --protocol-params-file $paramsfile \
  --out-file $txunsignedfile

cardano-cli transaction sign \
    --tx-body-file $txunsignedfile \
    --signing-key-file $signingkeyfile \
    $PREVIEW \
    --out-file $txsignedfile

cardano-cli transaction submit \
    $PREVIEW \
    --tx-file $txsignedfile

tid=$(cardano-cli transaction txid --tx-file $txsignedfile)
echo "transaction id: $tid"
echo "Cardanoscan: https://preview.cardanoscan.io/transaction/$tid"