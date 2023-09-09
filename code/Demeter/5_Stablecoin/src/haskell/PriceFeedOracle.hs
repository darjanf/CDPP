{-# LANGUAGE DataKinds         #-}
{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE TemplateHaskell   #-}
--{-# LANGUAGE DeriveGeneric #-}
--{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings  #-}

module PriceFeedOracle where

import Plutus.V2.Ledger.Api
    ( BuiltinData,
      ScriptContext(scriptContextTxInfo),
      mkValidatorScript,
      PubKeyHash,
      Datum(Datum),
      Validator,
      TxInInfo(txInInfoResolved),
      TxInfo,
      OutputDatum(OutputDatumHash, NoOutputDatum, OutputDatum),
      TxOut(txOutDatum, txOutValue),
      CurrencySymbol, BuiltinByteString, TokenName (TokenName))
import Plutus.V2.Ledger.Contexts
    ( findDatum,
      getContinuingOutputs,
      txSignedBy,
      findOwnInput )    
import PlutusTx
    ( compile,
      unstableMakeIsData,
      FromData(fromBuiltinData),
      liftCode,
      applyCode,
      makeLift )
import PlutusTx.Prelude
    ( Bool,
      Integer,
      Maybe(..),
      ($),
      (.),
      (&&),
      isJust,
      traceError,
      traceIfFalse,
      Eq(..), 
      filter,
      length
      )
import           Prelude                    (Show, IO)
import Plutus.V1.Ledger.Value
    (flattenValue)
import           Mappers                    (wrapValidator)
import           Serialization         (writeValidatorToFile, writeDataToFile) 

---------------------------------------------------------------------------------------------------
----------------------------- ON-CHAIN: HELPER FUNCTIONS/TYPES ------------------------------------

{-# INLINABLE parseOracleDatum #-}
parseOracleDatum :: TxOut -> TxInfo -> Maybe Integer
parseOracleDatum o info = case txOutDatum o of
    NoOutputDatum -> Nothing
    OutputDatum (Datum d) -> PlutusTx.fromBuiltinData d
    OutputDatumHash dh -> do
                        Datum d <- findDatum dh info
                        PlutusTx.fromBuiltinData d

---------------------------------------------------------------------------------------------------
----------------------------------- ON-CHAIN / VALIDATOR ------------------------------------------

data OracleParams = OracleParams
    { oNFT        :: TokenName
    , oOperator   :: PubKeyHash
    } 
PlutusTx.makeLift ''OracleParams

data OracleRedeemer = Update | Delete
    deriving Prelude.Show
PlutusTx.unstableMakeIsData ''OracleRedeemer

-- Oracle Datum
type Rate = Integer

{-# INLINABLE mkValidator #-}
mkValidator :: OracleParams -> Rate -> OracleRedeemer -> ScriptContext -> Bool
mkValidator oracle _ r ctx =
    case r of
        Update -> traceIfFalse "token missing from input!"   inputHasToken  &&
                  traceIfFalse "token missing from output!"  outputHasToken &&
                  traceIfFalse "operator signature missing!" checkOperatorSignature &&
                  traceIfFalse "invalid output datum!"       validOutputDatum
        Delete -> traceIfFalse "operator signature missing!" checkOperatorSignature

  where
    info :: TxInfo
    info = scriptContextTxInfo ctx

    -- | Check that the 'oracle' is signed by the 'oOperator'.
    checkOperatorSignature :: Bool
    checkOperatorSignature = txSignedBy info $ oOperator oracle

    -- | Find the oracle input.
    ownInput :: TxOut
    ownInput = case findOwnInput ctx of
        Nothing -> traceError "oracle input missing"
        Just i  -> txInInfoResolved i

    -- Check that the oracle input contains the NFT.
    inputHasToken :: Bool
    inputHasToken = traceIfFalse "OracleNFT in input missing" (length tokenValueList == 1)
            where
                tokenValueList :: [(CurrencySymbol, TokenName, Integer)]
                tokenValueList = filter (\(_,t,a) -> a == 1 && oNFT oracle == t) (flattenValue (txOutValue ownInput))

    -- | Find the oracle output.
    ownOutput :: TxOut
    ownOutput = case getContinuingOutputs ctx of
        [o] -> o
        _   -> traceError "expected exactly one oracle output"

    -- Check that the oracle output contains the NFT.
    outputHasToken :: Bool
    outputHasToken = traceIfFalse "OracleNFT in output missing" (length tokenValueList == 1)
            where
                tokenValueList :: [(CurrencySymbol, TokenName, Integer)]
                tokenValueList = filter (\(_,t,a) -> a == 1 && oNFT oracle == t) (flattenValue (txOutValue ownOutput))

    -- Check that the oracle output contains a valid datum.
    validOutputDatum :: Bool
    validOutputDatum = isJust $ parseOracleDatum ownOutput info

---------------------------------------------------------------------------------------------------
------------------------------------ COMPILE VALIDATOR --------------------------------------------

{-# INLINABLE  mkWrappedValidator #-}
mkWrappedValidator :: OracleParams -> BuiltinData -> BuiltinData -> BuiltinData -> ()
mkWrappedValidator = wrapValidator . mkValidator

validator :: OracleParams -> Validator
validator params = mkValidatorScript $
    $$(PlutusTx.compile [|| mkWrappedValidator ||])
    `PlutusTx.applyCode`
    PlutusTx.liftCode params

---------------------------------------------------------------------------------------------------
------------------------------------- SAVE VALIDATOR ----------------------------------------------

{- Serialised Scripts and Values -}

param :: OracleParams
param  = OracleParams {   oNFT = TokenName "OracleNFT"
                        , oOperator = "d70540296a8155451197472f28ab6c5c4e9830d5c2f1b615307ed10b" }

savePriceFeedOracleDatum :: IO ()
savePriceFeedOracleDatum = writeDataToFile "./data/priceFeedOracleDatum.json" (90::Integer)

savePriceFeedOracleUpdateRedeemer :: IO ()
savePriceFeedOracleUpdateRedeemer = writeDataToFile "./data/priceFeedOracleUpdateRedeemer.json" Update

savePriceFeedOracleDeleteRedeemer :: IO ()
savePriceFeedOracleDeleteRedeemer = writeDataToFile "./data/priceFeedOracleDeleteRedeemer.json" Delete

savePriceFeedOracleValidator :: IO ()
savePriceFeedOracleValidator = writeValidatorToFile "./validators/priceFeedOracle.plutus" $ validator param

saveAll :: IO ()
saveAll = do
            savePriceFeedOracleDatum
            savePriceFeedOracleValidator
            savePriceFeedOracleUpdateRedeemer
            savePriceFeedOracleDeleteRedeemer