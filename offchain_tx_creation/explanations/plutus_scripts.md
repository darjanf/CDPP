## Plutus Script explanation

There are 2 sided of an Smart Contract, the Onchain and the Offchain part.
The Onchain part is about validation. It allowes nodes to validate a transaction and decide whether it is allowed to consume the UTXO.
The Offchain part lives in the users wallet and constructs and submits transactions.

The Type used in the simple UTXO model are the so called public key addresses. The consuming transaction can can consume the UTXO if the signature belonging to the public ky is included in the transaction.

The EUTxO model extends this model by adding a new type of addresses, so-called script addresses that can run arbitrary logic. When a transaction, that wants to consume a UTXO sitting at a script address is validated by a node, the node will run the script and then depending on the result of the script decide whether the transaction is valid or not.

Instead of public-key and signatures, we have so-called redeemers (arbitrary pieces of data) and on the UTXO side we have an additional arbitrary pece of data, the so called Datum, which you can think of as a little piece of state that sits at the UTXO. 

## There are 3 pieces of Data that the script gets
1. The Datum sitting at the UTXO
2. The Redeemer coming from the consuming Transaction
3. The Context consisting of the transaction being validated and its inputs and outputs
These 3 data values are represented as concrete data types in Haskell. The choise was made to use the same data type for all of these data-values.