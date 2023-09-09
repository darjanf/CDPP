{-# LANGUAGE DataKinds         #-}
{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE TemplateHaskell   #-}
{-# LANGUAGE OverloadedStrings #-}

module OracleNFT where

import qualified PlutusTx
import           PlutusTx.Prelude           (Integer, Bool (..) , Eq ((==)), any, traceIfFalse, ($), (&&))
import           Plutus.V1.Ledger.Value     (flattenValue)
import           Plutus.V2.Ledger.Api       (BuiltinData, CurrencySymbol,
                                             MintingPolicy,
                                             ScriptContext (scriptContextTxInfo),
                                             TokenName (unTokenName),
                                             TxId (TxId, getTxId),
                                             TxInInfo (txInInfoOutRef),
                                             TxInfo (txInfoInputs, txInfoMint),
                                             TxOutRef (TxOutRef, txOutRefId, txOutRefIdx),
                                             mkMintingPolicyScript)
import           Plutus.V2.Ledger.Api     as PlutusV2
import           Prelude              (IO, Char)
import           Mappers          (wrapPolicy)
import           Serialization    (currencySymbol, writePolicyToFile, writeDataToFile) 
import GHC.Base (IO)

--THE ON-CHAIN CODE

{-# INLINABLE oracleNFT #-}
oracleNFT :: TxOutRef -> BuiltinData -> ScriptContext -> Bool
oracleNFT utxo _ sContext = traceIfFalse "UTxO not available!" hasUTxO &&
                         traceIfFalse "There can be only ONE!" checkMintedAmount
    where
        hasUTxO :: Bool
        hasUTxO = any (\x -> txInInfoOutRef x == utxo) $ txInfoInputs info

        checkMintedAmount :: Bool
        checkMintedAmount = case flattenValue (txInfoMint info) of
            [(_, _, amt)] -> amt == 1
            _             -> False

        info :: TxInfo
        info = scriptContextTxInfo sContext

{-# INLINABLE wrappedOracleNFTPolicy #-}
wrappedOracleNFTPolicy :: BuiltinData -> BuiltinData -> BuiltinData  -> BuiltinData -> ()
wrappedOracleNFTPolicy utxoId utxoIx = wrapPolicy $ oracleNFT utxo
    where
        utxo :: TxOutRef
        utxo = TxOutRef (TxId $ PlutusTx.unsafeFromBuiltinData utxoId) (PlutusTx.unsafeFromBuiltinData utxoIx)

oracleNFTcode :: PlutusTx.CompiledCode (BuiltinData -> BuiltinData -> BuiltinData -> BuiltinData -> ())
oracleNFTcode = $$(PlutusTx.compile [|| wrappedOracleNFTPolicy ||])

oracleNFTPolicy :: TxOutRef -> MintingPolicy
oracleNFTPolicy utxoRef = mkMintingPolicyScript $
                          oracleNFTcode
                           `PlutusTx.applyCode` PlutusTx.liftCode (PlutusTx.toBuiltinData $ getTxId $ txOutRefId utxoRef)
                           `PlutusTx.applyCode` PlutusTx.liftCode (PlutusTx.toBuiltinData $ txOutRefIdx utxoRef)



------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------

{- Serialised Scripts and Values -}

param :: TxOutRef
param  = PlutusV2.TxOutRef { txOutRefId = "b19c9fd8998093ed036e61ad8b8234c9c2cd6a657e73cbb42d3d69a0c6b193fd"
                           , txOutRefIdx = 2}   

saveOracleNFTPolicy :: IO ()
saveOracleNFTPolicy =  writePolicyToFile "./validators/oracleNFT.plutus" $ oracleNFTPolicy param   

saveUnit :: IO ()
saveUnit = writeDataToFile "./data/unit.json" ()

save100 :: IO ()
save100 = writeDataToFile "./data/100.json" ("100"::BuiltinByteString)

saveAll :: IO ()
saveAll = do
            saveOracleNFTPolicy
            saveUnit
            save100
            