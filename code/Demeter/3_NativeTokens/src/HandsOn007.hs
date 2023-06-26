{-# LANGUAGE DataKinds         #-}
{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE TemplateHaskell   #-}
{-# LANGUAGE OverloadedStrings #-}

module DarjanCoins where

import           PlutusTx                        (BuiltinData, compile, unstableMakeIsData, makeIsDataIndexed)
import           PlutusTx.Prelude                (Bool (..),traceIfFalse, otherwise, Integer, ($), (<=), (&&), (==), (/=), all, foldr, emptyByteString, consByteString)
import           Plutus.V2.Ledger.Api            (BuiltinData, CurrencySymbol,
                                                 MintingPolicy, ScriptContext,
                                                 mkMintingPolicyScript)
import           Plutus.V1.Ledger.Value       as PlutusV1
import           Plutus.V1.Ledger.Interval      (contains, to) 
import           Plutus.V2.Ledger.Api        as PlutusV2
import           Plutus.V2.Ledger.Contexts      (txSignedBy, valueSpent, ownCurrencySymbol)

--Serialization
import           Mappers                (wrapPolicy)
import           Serialization          (currencySymbol, writePolicyToFile,  writeDataToFile) 
import           Prelude                (IO)

-- ON-CHAIN CODE



{-# INLINABLE darjanCoins #-}
darjanCoins :: () -> ScriptContext -> Bool
darjanCoins _ sContext = traceIfFalse "Incorrect Signatures!" (checkSignaturePassed)
    where
        info :: TxInfo
        info = scriptContextTxInfo sContext

        conditions :: [PubKeyHash]
        conditions = [
            (
                PubKeyHash { getPubKeyHash = (foldr (\x y -> consByteString x y) emptyByteString [99,52,48,51,52,51,49,48,100,98,56,55,52,50,97,48,99,52,56,53,51,57,99,50,54,97,97,57,56,57,48,100,49,48,57,54,49,57,50,53,102,102,99,100,101,57,100,101,52,53,48,53,56,49,99,99]) }
            ), -- PKH alice
            (
                PubKeyHash { getPubKeyHash = (foldr (\x y -> consByteString x y) emptyByteString [100,55,48,53,52,48,50,57,54,97,56,49,53,53,52,53,49,49,57,55,52,55,50,102,50,56,97,98,54,99,53,99,52,101,57,56,51,48,100,53,99,50,102,49,98,54,49,53,51,48,55,101,100,49,48,98]) }
            )  -- PKH bob
            ]

        checkSignaturePassed :: Bool
        --checkSignaturePassed = True
        checkSignaturePassed = all (\x -> txSignedBy info $ x) conditions

{-# INLINABLE wrappedDarjanCoinPolicy #-}
wrappedDarjanCoinPolicy :: BuiltinData -> BuiltinData -> ()
wrappedDarjanCoinPolicy = wrapPolicy $ darjanCoins

darjanCoinPolicy :: MintingPolicy
darjanCoinPolicy = mkMintingPolicyScript $$(PlutusTx.compile [|| wrappedDarjanCoinPolicy ||])

-- Serialised Scripts and Values 

saveDarjanCoinPolicy :: IO ()
saveDarjanCoinPolicy = writePolicyToFile "./validators/handson0007.plutus" darjanCoinPolicy

saveUnit :: IO ()
saveUnit = writeDataToFile "./data/unit.json" ()

saveAll :: IO ()
saveAll = do
            saveDarjanCoinPolicy
            saveUnit