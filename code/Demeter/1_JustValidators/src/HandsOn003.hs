{-# LANGUAGE DataKinds           #-}  --Enable datatype promotions
{-# LANGUAGE NoImplicitPrelude   #-}  --Don't load native prelude to avoid conflict with PlutusTx.Prelude
{-# LANGUAGE TemplateHaskell     #-}  --Enable Template Haskell splice and quotation syntax
{-# LANGUAGE OverloadedStrings   #-}  --Enable passing strings as other character formats, like bytestring.

module AllOrNothing where

--PlutusTx
import                  PlutusTx                       (BuiltinData, compile,unstableMakeIsData, makeIsDataIndexed)
import                  PlutusTx.Prelude               (traceIfFalse, otherwise, (==), Bool (..), Integer, ($), (>), (*), (&&))
import                  Plutus.V1.Ledger.Value      as PlutusV1
import                  Plutus.V1.Ledger.Interval      (contains, to) 
import                  Plutus.V2.Ledger.Api        as PlutusV2
import                  Plutus.V2.Ledger.Contexts      (txSignedBy, valueSpent)
import                  Mappers                        (wrapValidator)
import                  Serialization                  (writeValidatorToFile, writeDataToFile)
import                  Prelude                        (IO)

--THE ON-CHAIN CODE
data ConditionsDatum = Conditions { owner :: PubKeyHash
                                  , timelimit :: POSIXTime
                                  , price :: Integer
                                  }
unstableMakeIsData ''ConditionsDatum

{-# INLINABLE allOrNothing #-}
allOrNothing :: ConditionsDatum -> BuiltinData -> ScriptContext -> Bool
allOrNothing datum _ context = traceIfFalse "Validations not passed!"  (allValidationsPassed)
    where
        allValidationsPassed :: Bool
        allValidationsPassed = signedByOwner && timeLimitNotReached && priceIsCovered

        signedByOwner :: Bool
        signedByOwner = txSignedBy info $ owner datum

        timeLimitNotReached :: Bool
        timeLimitNotReached = contains (to $ timelimit datum) $ txInfoValidRange info

        priceIsCovered :: Bool
        priceIsCovered =  assetClassValueOf (valueSpent info)  (AssetClass (adaSymbol,adaToken)) > 2 * (price datum)

        info :: TxInfo
        info = scriptContextTxInfo context

mappedAllOrNothing :: BuiltinData -> BuiltinData -> BuiltinData -> ()
mappedAllOrNothing = wrapValidator allOrNothing

allOrNothingValidator :: Validator
allOrNothingValidator = PlutusV2.mkValidatorScript $$(PlutusTx.compile [|| mappedAllOrNothing ||])

------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------

{- Serialised Scripts and Values -}

saveAllOrNothingValidator :: IO ()
saveAllOrNothingValidator = writeValidatorToFile "./validators/allOrNothing.plutus" allOrNothingValidator

saveUnit :: IO ()
saveUnit = writeDataToFile "./data/unit.json" ()

saveDatum :: IO ()
saveDatum  = writeDataToFile "./data/datumHandsOn0003.json" (Conditions "c4034310db8742a0c48539c26aa9890d10961925ffcde9de450581cc" 1687428450000 48)

saveAll :: IO ()
saveAll = do
            saveAllOrNothingValidator
            saveUnit
            saveDatum
