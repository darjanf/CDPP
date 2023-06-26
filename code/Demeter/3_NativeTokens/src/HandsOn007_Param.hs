{-# LANGUAGE DataKinds         #-}
{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE TemplateHaskell   #-}
{-# LANGUAGE OverloadedStrings #-}

module DarjanCoins where

import           PlutusTx                               (BuiltinData, compile, unsafeFromBuiltinData, unstableMakeIsData, makeIsDataIndexed, liftCode, applyCode, CompiledCode, toBuiltinData)
import           PlutusTx.Prelude                       (Bool (..),traceIfFalse, otherwise, Integer, (.), ($), (<=), (&&), (==), (/=), all, foldr, emptyByteString, consByteString)
import           Plutus.V1.Ledger.Value                 as PlutusV1
import           Plutus.V1.Ledger.Interval              (contains, to) 
import           Plutus.V2.Ledger.Api                   as PlutusV2
import           Plutus.V2.Ledger.Contexts              (txSignedBy, valueSpent, ownCurrencySymbol)

--Serialization
import           Mappers                                (wrapPolicy)
import           Serialization                          (currencySymbol, writePolicyToFile,  writeDataToFile) 
import           Prelude                                (IO, Show (show))
import           Text.Printf                            (printf)

-- ON-CHAIN CODE

{-# INLINABLE darjanCoins #-}
darjanCoins :: [PubKeyHash] -> () -> ScriptContext -> Bool
darjanCoins conds _ sContext = traceIfFalse "Incorrect Signatures!" (checkSignaturePassed)
    where
        info :: TxInfo
        info = scriptContextTxInfo sContext

        checkSignaturePassed :: Bool
        checkSignaturePassed = all (\x -> txSignedBy info $ x) conds

{- Compile into UPLC-}

{-# INLINABLE wrappedDarjanCoinPolicy #-}
wrappedDarjanCoinPolicy :: BuiltinData -> BuiltinData -> BuiltinData -> ()
wrappedDarjanCoinPolicy pkhlist = wrapPolicy $ (darjanCoins $ unsafeFromBuiltinData pkhlist)

signedCode :: CompiledCode (BuiltinData -> BuiltinData -> BuiltinData -> ())
signedCode = $$(compile [|| wrappedDarjanCoinPolicy ||])

signedPolicy :: [PubKeyHash] -> MintingPolicy
signedPolicy pkhlist = mkMintingPolicyScript $ signedCode `applyCode` liftCode (toBuiltinData pkhlist)

-- Serialized Scripts and Values 

-- PKH alice and bob = ["c4034310db8742a0c48539c26aa9890d10961925ffcde9de450581cc", "d70540296a8155451197472f28ab6c5c4e9830d5c2f1b615307ed10b"]
-- To serialize the validtor file you to run cabal repl and create the following variable:
-- import Plutus.V2.Ledger.Api
-- pkhlist = ["c4034310db8742a0c48539c26aa9890d10961925ffcde9de450581cc", "d70540296a8155451197472f28ab6c5c4e9830d5c2f1b615307ed10b"]
-- Then calling the method "saveSignedPolicy" and using the variable "pkhlist" as parameter: saveSignedPolicy pkhlist

saveSignedPolicy :: [PubKeyHash] -> IO ()
saveSignedPolicy pkhlist = writePolicyToFile "./validators/handson0007.plutus" $ signedPolicy pkhlist

signedCurrencySymbol :: [PubKeyHash] -> CurrencySymbol
signedCurrencySymbol = Serialization.currencySymbol . signedPolicy

saveUnit :: IO ()
saveUnit = writeDataToFile "./data/unit.json" ()

saveAll :: IO ()
saveAll = do
            saveUnit