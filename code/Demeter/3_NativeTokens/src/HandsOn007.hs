{-# LANGUAGE DataKinds         #-}
{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE TemplateHaskell   #-}
{-# LANGUAGE OverloadedStrings #-}

module DarjanCoins where

import           PlutusTx                        (BuiltinData, compile, unstableMakeIsData, makeIsDataIndexed)
import           PlutusTx.Prelude                (Bool (..),traceIfFalse, otherwise, Integer, ($), (<=), (&&), any)
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
darjanCoins :: BuiltinData -> ScriptContext -> Bool
darjanCoins _ sContext = traceIfFalse ("Only Alice and Bob are allowed to mint!") checkSignaturePassed
    where
        info :: TxInfo
        info = scriptContextTxInfo sContext

        -- PKH of Alice and Bob
        pkhList :: [PubKeyHash]
        pkhList = ["c4034310db8742a0c48539c26aa9890d10961925ffcde9de450581cc","d70540296a8155451197472f28ab6c5c4e9830d5c2f1b615307ed10b"]

        checkSignaturePassed :: Bool
        checkSignaturePassed = any (\x -> txSignedBy info x) pkhList   

{-# INLINABLE wrappedDarjanCoinPolicy #-}
wrappedDarjanCoinPolicy :: BuiltinData -> BuiltinData -> ()
wrappedDarjanCoinPolicy = wrapPolicy darjanCoins

darjanCoinPolicy :: MintingPolicy
darjanCoinPolicy = mkMintingPolicyScript $$(PlutusTx.compile [|| wrappedDarjanCoinPolicy ||])

-- Serialised Scripts and Values 

saveDarjanCoinPolicy :: IO ()
saveDarjanCoinPolicy = writePolicyToFile "./validators/handson007.plutus" darjanCoinPolicy

saveUnit :: IO ()
saveUnit = writeDataToFile "./data/unit.json" ()

saveAll :: IO ()
saveAll = do
            saveDarjanCoinPolicy
            saveUnit