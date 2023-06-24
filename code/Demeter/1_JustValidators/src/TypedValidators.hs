{-# LANGUAGE DataKinds           #-}  --Enable datatype promotions
{-# LANGUAGE NoImplicitPrelude   #-}  --Don't load native prelude to avoid conflict with PlutusTx.Prelude
{-# LANGUAGE TemplateHaskell     #-}  --Enable Template Haskell splice and quotation syntax
{-# LANGUAGE OverloadedStrings   #-}  --Enable passing strings as other character formats, like bytestring.

module TypedValidators where

--PlutusTx 
import                  PlutusTx                       (BuiltinData, compile,unstableMakeIsData, makeIsDataIndexed)
import                  PlutusTx.Prelude               (traceIfFalse, otherwise, (==), Bool (..), Integer, ($))
import                  Plutus.V2.Ledger.Api        as PlutusV2
import                  Mappers                        (wrapValidator)
import                  Serialization                  (writeValidatorToFile, writeDataToFile)

import                  Prelude                     (IO)

------------------------------------------------------------------------------------------
-- Primites Types
------------------------------------------------------------------------------------------

{-# INLINABLE typedDatum22 #-}
typedDatum22 :: Integer -> () -> ScriptContext -> Bool
typedDatum22 datum _ _ = traceIfFalse "Not the right datum!" (datum ==  22)

{-# INLINABLE typedRedeemer11 #-}
typedRedeemer11 ::  () -> Integer -> ScriptContext -> Bool
typedRedeemer11 _ redeemer _ = traceIfFalse "Not the right redeemer!" (redeemer ==  11)

------------------------------------------------------------------------------------------
-- Custom Types
------------------------------------------------------------------------------------------

data OurWonderfullDatum = OWD Integer | JOKER_D Bool
makeIsDataIndexed ''OurWonderfullDatum [('OWD,0),('JOKER_D,1)]

data OurWonderfullRedeemer = OWR Integer | JOKER_R Bool
makeIsDataIndexed ''OurWonderfullRedeemer [('OWR,0),('JOKER_R,1)]

{-# INLINABLE customTypedDatum22 #-}
customTypedDatum22 :: OurWonderfullDatum -> () -> ScriptContext -> Bool
customTypedDatum22 (OWD datum) _ _ = traceIfFalse "Not the right datum!" (datum ==  22)

{-# INLINABLE customTypedRedeemer11 #-}
customTypedRedeemer11 ::  () -> OurWonderfullRedeemer -> ScriptContext -> Bool
customTypedRedeemer11 _ (OWR number) _    =  traceIfFalse "Not the right redeemer!" (number ==  11)
customTypedRedeemer11 _ (JOKER_R boolean) _ =  traceIfFalse "The Joker sais no!" boolean

{-# INLINABLE handson0002 #-}
handson0002 :: OurWonderfullDatum -> OurWonderfullRedeemer -> ScriptContext -> Bool
handson0002 (OWD datum) (OWR number) _                  = traceIfFalse "datum not equal to redeemer!" (datum == number)
handson0002 (JOKER_D dbool) (JOKER_R rbool) _           = traceIfFalse "datum not equal to redeemer!" (dbool == rbool)
handson0002 _ _ _                                       = traceIfFalse "conditions not matching!" (False)

------------------------------------------------------------------------------------------
-- Mappers and Compiling expresions
------------------------------------------------------------------------------------------

-- for primitives types

mappedTypedDatum22 :: BuiltinData -> BuiltinData -> BuiltinData -> ()
mappedTypedDatum22 = wrapValidator customTypedDatum22

typedDatum22Val :: PlutusV2.Validator
typedDatum22Val = PlutusV2.mkValidatorScript $$(PlutusTx.compile [|| mappedTypedDatum22 ||])

mappedTypedRedeemer11 :: BuiltinData -> BuiltinData -> BuiltinData -> ()
mappedTypedRedeemer11 = wrapValidator typedRedeemer11

typedRedeemer11Val :: Validator
typedRedeemer11Val = PlutusV2.mkValidatorScript $$(PlutusTx.compile [|| mappedTypedRedeemer11 ||])

-- for custom types

mappedCustomTypedDatum22 :: BuiltinData -> BuiltinData -> BuiltinData -> ()
mappedCustomTypedDatum22 = wrapValidator customTypedDatum22

mappedCustomTypedRedeemer11 :: BuiltinData -> BuiltinData -> BuiltinData -> ()
mappedCustomTypedRedeemer11 = wrapValidator customTypedRedeemer11

mappedHandson0002 :: BuiltinData -> BuiltinData -> BuiltinData -> ()
mappedHandson0002 = wrapValidator handson0002

customTypedDatum22Val :: Validator
customTypedDatum22Val = PlutusV2.mkValidatorScript $$(PlutusTx.compile [|| mappedCustomTypedDatum22 ||])

customTypedRedeemer11Val :: Validator
customTypedRedeemer11Val = PlutusV2.mkValidatorScript $$(PlutusTx.compile [|| mappedCustomTypedRedeemer11 ||])

handson0002Val :: Validator
handson0002Val = PlutusV2.mkValidatorScript $$(PlutusTx.compile [|| mappedHandson0002 ||])

------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------

{- Serialised Scripts and Values -}

saveTypedDatum22 :: IO ()
saveTypedDatum22 =  writeValidatorToFile "./testnet/typedDatum22.plutus" typedDatum22Val

saveTypedRedeemer11 :: IO ()
saveTypedRedeemer11 =  writeValidatorToFile "./testnet/typedRedeemer11.plutus" typedRedeemer11Val

saveCustomTypedDatum22 :: IO ()
saveCustomTypedDatum22 =  writeValidatorToFile "./testnet/customTypedDatum22.plutus" customTypedDatum22Val

saveCustomTypedRedeemer11 :: IO ()
saveCustomTypedRedeemer11 =  writeValidatorToFile "./testnet/customTypedRedeemer11.plutus" customTypedRedeemer11Val

saveHandson0001 :: IO ()
saveHandson0001 = writeValidatorToFile "./testnet/handson0002.plutus" handson0002Val

saveUnit :: IO ()
saveUnit = writeDataToFile "./testnet/unit.json" ()

saveValue11 :: IO ()
saveValue11 = writeDataToFile "./testnet/value11.json" (11 :: Integer)

saveValue22 :: IO ()
saveValue22 = writeDataToFile "./testnet/value22.json" (22 :: Integer)

saveGoodDatum  :: IO ()
saveGoodDatum = writeDataToFile "./testnet/goodOWD.json" (OWD 22)

saveBadDatum  :: IO ()
saveBadDatum = writeDataToFile "./testnet/badOWD.json" (OWD 23)

saveGoodRedeemer  :: IO ()
saveGoodRedeemer = writeDataToFile "./testnet/goodOWR.json" (OWR 22)

saveBadRedeemer  :: IO ()
saveBadRedeemer = writeDataToFile "./testnet/badOWR.json" (OWR 23)

saveOWR  :: IO ()
saveOWR = writeDataToFile "./testnet/OWR.json" ()

saveGoodJOKER_R :: IO ()
saveGoodJOKER_R = writeDataToFile "./testnet/GoodJoker_R.json" (JOKER_R True)

saveBadJOKER_R :: IO ()
saveBadJOKER_R = writeDataToFile "./testnet/BadJoker_R.json" (JOKER_R False)

saveGoodJOKER_D :: IO ()
saveGoodJOKER_D = writeDataToFile "./testnet/GoodJoker_D.json" (JOKER_D True)

saveBadJOKER_D :: IO ()
saveBadJOKER_D = writeDataToFile "./testnet/BadJoker_D.json" (JOKER_D False)

saveAll :: IO ()
saveAll = do
            saveTypedDatum22
            saveTypedRedeemer11
            saveCustomTypedDatum22
            saveCustomTypedRedeemer11
            saveUnit
            saveValue11
            saveValue22
            saveGoodDatum
            saveBadDatum
            saveGoodRedeemer
            saveBadRedeemer
            saveOWR
            saveGoodJOKER_R
            saveBadJOKER_R
            saveGoodJOKER_D
            saveBadJOKER_D
            saveHandson0001