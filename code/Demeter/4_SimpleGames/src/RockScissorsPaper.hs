{-# LANGUAGE DataKinds         #-}
{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE TemplateHaskell   #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE MultiParamTypeClasses #-}

module RockScissorsPaper where

import           PlutusTx                   (makeLift, BuiltinData, compile, fromBuiltinData, unsafeFromBuiltinData, unstableMakeIsData, makeIsDataIndexed, liftCode, applyCode, CompiledCode, toBuiltinData)
import           PlutusTx.Prelude           (otherwise, appendByteString, snd, sha2_256, (>>=), (+), (*), decodeUtf8, head, length, filter, (.), tail, Maybe(..), Integer, Bool (..) , Eq ((==)), any, trace, traceError, traceIfFalse, ($), (&&), Maybe)
import           PlutusTx.Builtins.Class    (stringToBuiltinString)
import           PlutusTx.Base              (flip)
import           Data.String                ( IsString(fromString), String )
import           Plutus.V1.Ledger.Value     as PlutusV1
import           Plutus.V2.Ledger.Api       as PlutusV2
import           Plutus.V2.Ledger.Contexts  (txSignedBy, valueSpent, findOwnInput, getContinuingOutputs, findDatum, valuePaidTo)
import           Plutus.V1.Ledger.Interval  (contains)
import           Prelude                    (IO, Show (show), span)
import qualified Prelude                    ((/=) )
import           Mappers                    (wrapValidator)
import           Serialization              (currencySymbol, writeValidatorToFile, writeDataToFile) 
import           GHC.Base                   (IO)
import           Data.Char                  (GeneralCategory(CurrencySymbol))

--THE ON-CHAIN CODE

data Game = Game
    { gFirstPlayer    :: PubKeyHash
    , gSecondPlayer   :: PubKeyHash
    , gStake          :: Integer
    , gPlayDeadline   :: POSIXTime
    , gRevealDeadline :: POSIXTime
    , gToken          :: AssetClass
    } deriving (Show)
PlutusTx.makeLift ''Game
--unstableMakeIsData ''Game

type GameChoice = BuiltinByteString

data GameDatum = GameDatum BuiltinByteString (Maybe GameChoice)
    deriving (Show)
unstableMakeIsData ''GameDatum

data GameRedeemer = Play GameChoice | Reveal BuiltinByteString GameChoice | ClaimFirst | ClaimSecond
    deriving Show
unstableMakeIsData ''GameRedeemer

{-# INLINABLE lovelaces #-}
lovelaces :: Value -> Integer
lovelaces v = valueOf v PlutusV2.adaSymbol PlutusV2.adaToken

{-# INLINABLE gameDatum #-}
gameDatum :: OutputDatum -> Maybe DatumHash
gameDatum md = case md of
    (OutputDatumHash datumhash) -> Just datumhash
    _                           -> traceError "datumhash not found"

bsRock, bsPaper, bsScissors :: GameChoice
bsRock     = "Rock"
bsPaper    = "Paper"
bsScissors = "Scissors"


{-# INLINABLE rockScissorsPaper #-}
rockScissorsPaper :: Game -> GameDatum -> GameRedeemer -> ScriptContext -> Bool
rockScissorsPaper game dat red ctx = 
    traceIfFalse "token missing from input utxo" (nftTokenAvailable ownInput) &&
    case (dat, red) of
        (GameDatum bs Nothing, Play c) ->
            traceIfFalse "not signed by second player"   (txSignedBy info (gSecondPlayer game))                         &&
            traceIfFalse "first player's stake missing"  (lovelaces (txOutValue ownInput) == gStake game)               &&
            traceIfFalse "second player's stake missing" (lovelaces (txOutValue ownOutput) == (2 * gStake game))        &&
            traceIfFalse "wrong output datum"            (outputDatum == Datum (toBuiltinData (GameDatum bs (Just c)))) &&
            traceIfFalse "token missing from output"     (nftTokenAvailable ownOutput)                                  &&
            traceIfFalse "missed deadline"               (to (gPlayDeadline game) `contains` txInfoValidRange info)
        (GameDatum bs (Just choiceP2), Reveal nonce choiceP1) ->
            traceIfFalse "not signed by first player"    (txSignedBy info (gFirstPlayer game))                          &&
            traceIfFalse "commit mismatch"               (checkBS bs nonce choiceP1)                                    &&
            traceIfFalse "first player did not win"      (beats choiceP1 choiceP2)                                      &&
            traceIfFalse "missed deadline"               (to (gRevealDeadline game) `contains` txInfoValidRange info)   &&
            traceIfFalse "wrong stake"                   (lovelaces (txOutValue ownInput) == (2 * gStake game))         &&
            traceIfFalse "NFT must go to first player"   nftToPlayer1
        (GameDatum _ Nothing, ClaimFirst) ->
            traceIfFalse "not signed by first player"    (txSignedBy info (gFirstPlayer game))                              &&
            traceIfFalse "too early"                     (from (1 + gPlayDeadline game) `contains` txInfoValidRange info)   &&
            traceIfFalse "first player's stake missing"  (lovelaces (txOutValue ownInput) == gStake game)                   &&
            traceIfFalse "NFT must go to first player"   nftToPlayer1
        (GameDatum _ (Just _), ClaimSecond) ->
            traceIfFalse "not signed by second player"   (txSignedBy info (gSecondPlayer game))                             &&
            traceIfFalse "too early"                     (from (1 + gRevealDeadline game) `contains` txInfoValidRange info) &&
            traceIfFalse "wrong stake"                   (lovelaces (txOutValue ownInput) == (2 * gStake game))             &&
            traceIfFalse "NFT must go to first player"   nftToPlayer1
        _ -> False
    where
        info :: TxInfo
        info = scriptContextTxInfo ctx

        -- | Find the game input.
        ownInput :: TxOut
        ownInput = case findOwnInput ctx of
            Nothing -> traceError "game input missing"
            Just i  -> txInInfoResolved i
        
        ownOutput :: TxOut
        ownOutput = case getContinuingOutputs ctx of
            [o] -> o
            _   -> traceError "expected exactly one game output"

        outputDatum :: Datum
        outputDatum = case gameDatum (txOutDatum ownOutput) >>= flip findDatum info of
            Nothing -> traceError "game output datum not found"
            Just d  -> d

        -- Check that the oracle input contains the NFT.
        --nftTokenAvailable = assetClassValueOf (txOutValue ownInput) (gToken game) == 1
        --nftTokenAvailable (AssetClass (currSymbol, tokenName)) oInput = traceIfFalse (decodeUtf8 $ unCurrencySymbol cSymbol) ((decodeUtf8 $ unCurrencySymbol currSymbol) == (decodeUtf8 $ unCurrencySymbol cSymbol))
        nftTokenAvailable :: TxOut -> Bool
        nftTokenAvailable oInput = traceIfFalse "NFT Token missing" (length tokenValueList == 1)
            where
                tokenValueList :: [(CurrencySymbol, TokenName, Integer)]
                tokenValueList = filter (\(_,t,a) -> a == 1 && tName == t) (flattenValue (txOutValue oInput))

                tName :: TokenName
                tName = snd $ unAssetClass $ gToken game

        checkBS :: BuiltinByteString -> BuiltinByteString -> GameChoice -> Bool
        checkBS bs nonce choiceP1 = sha2_256 (nonce `appendByteString` choiceP1) == bs

        nftToPlayer1 :: Bool
        nftToPlayer1 = traceIfFalse "Reward NFT Token for Player1 mssing" (length tokenValueList == 1)
            where
                tokenValueList :: [(CurrencySymbol, TokenName, Integer)]
                tokenValueList = filter (\(_,t,a) -> a == 1 && tName == t) (flattenValue (valuePaidTo info $ gFirstPlayer game))

                tName :: TokenName
                tName = snd $ unAssetClass $ gToken game

        beats :: GameChoice -> GameChoice -> Bool
        beats c1 c2
            | c1 == bsRock     && c2 == bsScissors  = True
            | c1 == bsPaper    && c2 == bsRock      = True
            | c1 == bsScissors && c2 == bsPaper     = True
            | otherwise                             = False

------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------

{- ##### Compile validator into UPLC Version not working 

wrappedRockScissorsPaper :: BuiltinData -> BuiltinData -> BuiltinData -> BuiltinData -> ()
wrappedRockScissorsPaper game = wrapValidator $ (rockScissorsPaper $ unsafeFromBuiltinData game)

signedRockScissorsPaper :: CompiledCode (BuiltinData -> BuiltinData -> BuiltinData -> BuiltinData -> ())
signedRockScissorsPaper = $$(compile [|| wrappedRockScissorsPaper ||])

rockScissorsPaperValidator :: Game -> Validator
rockScissorsPaperValidator game = mkValidatorScript $ signedRockScissorsPaper `applyCode` liftCode (toBuiltinData game)


-}

{-# INLINABLE rockScissorsPaperValidator #-}
rockScissorsPaperValidator :: Game -> BuiltinData -> BuiltinData -> BuiltinData -> ()
rockScissorsPaperValidator = wrapValidator . rockScissorsPaper


validator :: Game -> Validator
validator game = mkValidatorScript $
    $$(PlutusTx.compile [|| rockScissorsPaperValidator ||])
    `PlutusTx.applyCode`
    PlutusTx.liftCode game

------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------

{- Serialised Scripts and Values -}

{-
To serialize the validtor file you to run cabal repl and create the following variable:
:set -XOverloadedStrings
import Plutus.V1.Ledger.Value
import Plutus.V1.Ledger.Api
player1 = "c4034310db8742a0c48539c26aa9890d10961925ffcde9de450581cc"
player2 = "d70540296a8155451197472f28ab6c5c4e9830d5c2f1b615307ed10b"
stake = 3000000
playDeadline = POSIXTime 2636723330000
revealDeadline = POSIXTime 2696723330000
tokenCS = Plutus.V1.Ledger.Api.CurrencySymbol "c0f8644a01a6bf5db02f4afe30d604975e63dd274f1098a1738e561d"
tokenTN = TokenName "BountyNFT"
token = AssetClass (tokenCS, tokenTN)
game = Game player1 player2 stake playDeadline revealDeadline token
saveRockScissorsPaperValidator game
-}

saveRockScissorsPaperValidator :: Game -> IO ()
saveRockScissorsPaperValidator game = do
    let
    writeValidatorToFile "./validators/rockScissorsPaper.plutus" $ validator game

saveUnit :: IO ()
saveUnit = writeDataToFile "./data/unit.json" ()

{-
:set -XOverloadedStrings
import PlutusTx.Prelude
nonce = "12345"
hashBS = sha2_256 (nonce `appendByteString` bsRock)
gDatumPlayer1 = GameDatum hashBS Nothing
saveGameDatumPlayer1 gDatumPlayer1
-}
saveGameDatumPlayer1 :: GameDatum -> IO ()
saveGameDatumPlayer1 = writeDataToFile "./data/gameDatumPlayer1.json"

{-
:set -XOverloadedStrings
import PlutusTx.Prelude
nonce = "12345"
gRedeemerPlayer1Reveal = Reveal nonce bsRock
saveGameRedeemerPlayer1Reveal gRedeemerPlayer1Reveal
-}
saveGameRedeemerPlayer1Reveal :: GameRedeemer -> IO ()
saveGameRedeemerPlayer1Reveal = writeDataToFile "./data/gameRedeemerPlayer1Reveal.json"

{-
:set -XOverloadedStrings
import PlutusTx.Prelude
nonce = "12345"
hashBS = sha2_256 (nonce `appendByteString` bsRock)
gDatumPlayer2 = GameDatum hashBS (Just bsScissors)
saveGameDatumPlayer2 gDatumPlayer2
-}
saveGameDatumPlayer2 :: GameDatum -> IO ()
saveGameDatumPlayer2 = writeDataToFile "./data/gameDatumPlayer2.json"

{-
:set -XOverloadedStrings
gRedeemerPlayer2 = Play bsScissors
saveGameRedeemerPlayer2 gRedeemerPlayer2
-}
saveGameRedeemerPlayer2 :: GameRedeemer -> IO ()
saveGameRedeemerPlayer2 = writeDataToFile "./data/gameRedeemerPlayer2.json"

saveAll :: IO ()
saveAll = do
            saveUnit