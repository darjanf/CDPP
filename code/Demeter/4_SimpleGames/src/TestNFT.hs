{-# LANGUAGE DataKinds         #-}
{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE TemplateHaskell   #-}
{-# LANGUAGE OverloadedStrings #-}

module TestNFT where

import qualified PlutusTx
import           PlutusTx.Prelude           (Bool (..) , Eq ((==)), any, traceIfFalse, ($), (&&))
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
import           Prelude              (IO)
import           Mappers          (wrapPolicy)
import           Serialization    (currencySymbol, writePolicyToFile, writeDataToFile) 
import GHC.Base (IO)

--THE ON-CHAIN CODE

{-# INLINABLE testNFT #-}
testNFT :: () -> ScriptContext -> Bool
testNFT _ _ = True

{-# INLINABLE wrappedTestNFT #-}
wrappedTestNFT :: BuiltinData -> BuiltinData -> ()
wrappedTestNFT = wrapPolicy $ testNFT

testNFTPolicy :: MintingPolicy
testNFTPolicy = mkMintingPolicyScript $$(PlutusTx.compile [|| wrappedTestNFT ||])

------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------

{- Serialised Scripts and Values -}               

saveTestNFTPolicy :: IO ()
saveTestNFTPolicy =  writePolicyToFile "./validators/testNFT.plutus" testNFTPolicy   

saveUnit :: IO ()
saveUnit = writeDataToFile "./data/unit.json" ()

saveAll :: IO ()
saveAll = do
            saveTestNFTPolicy
            saveUnit
            