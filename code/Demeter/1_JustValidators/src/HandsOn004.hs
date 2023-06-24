{-# LANGUAGE DataKinds           #-}  --Enable datatype promotions
{-# LANGUAGE NoImplicitPrelude   #-}  --Don't load native prelude to avoid conflict with PlutusTx.Prelude
{-# LANGUAGE TemplateHaskell     #-}  --Enable Template Haskell splice and quotation syntax
{-# LANGUAGE OverloadedStrings   #-}  --Enable passing strings as other character formats, like bytestring.

module MultiSig where

--PlutusTx
import                  PlutusTx                       (BuiltinData, compile,unstableMakeIsData, makeIsDataIndexed)
import                  PlutusTx.Foldable              (any)
import                  PlutusTx.Prelude               (traceIfFalse, otherwise, (==), Bool (..), Integer, ($), (>), (*), (&&))
import                  Plutus.V1.Ledger.Value      as PlutusV1
import                  Plutus.V1.Ledger.Interval      (contains, to) 
import                  Plutus.V2.Ledger.Api        as PlutusV2
import                  Plutus.V2.Ledger.Contexts      (txSignedBy, valueSpent)
import                  Mappers                        (wrapValidator)
import                  Serialization                  (writeValidatorToFile, writeDataToFile)
import                  Prelude                        (IO)

--THE ON-CHAIN CODE
data ConditionsDatum = Conditions { pkhlist :: [PubKeyHash] }
unstableMakeIsData ''ConditionsDatum

{-# INLINABLE multiSig #-}
multiSig :: ConditionsDatum -> BuiltinData -> ScriptContext -> Bool
multiSig datum _ context    = traceIfFalse "Incorrect Signatures!"  (any (\x -> txSignedBy info x) $ (pkhlist datum))
    where
        info :: TxInfo
        info = scriptContextTxInfo context

mappedMultiSig :: BuiltinData -> BuiltinData -> BuiltinData -> ()
mappedMultiSig = wrapValidator multiSig

multiSigValidator :: Validator
multiSigValidator = PlutusV2.mkValidatorScript $$(PlutusTx.compile [|| mappedMultiSig ||])

------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------

{- Serialised Scripts and Values -}

saveMultiSigValidator :: IO ()
saveMultiSigValidator = writeValidatorToFile "./validators/handson0004.plutus" multiSigValidator

saveUnit :: IO ()
saveUnit = writeDataToFile "./data/unit.json" ()

-- using alice.pkh and bob.pkh
saveDatum :: IO ()
saveDatum  = writeDataToFile "./data/datumHandsOn0004.json" (Conditions ["c4034310db8742a0c48539c26aa9890d10961925ffcde9de450581cc", "d70540296a8155451197472f28ab6c5c4e9830d5c2f1b615307ed10b"])

saveAll :: IO ()
saveAll = do
            saveMultiSigValidator
            saveUnit
            saveDatum
