# CDPP
Cardano Developer Professional Program

## Helpful URLs
- https://github.com/mallapurbharat/cardano-tx-sample/blob/main/1_native_exercises/1_simple/exercise1-simpletxfer.md
- https://github.com/EmurgoFaculty/EA_NativeScripting
- https://able-pool.io/document
- https://docs.cardano.org/cardano-testnet/tools/faucet -- used to send ADA to testnet address
- https://iohk.io/en/blog/posts/2021/02/25/babel-fees/

## Final Project - Algo Stablecoin dUSD
- Presentation with general information = presentation_final_project.pptx
- UseCases:
1) Deploy Collateral Validator 
   script = /workspace/code/Demeter/5_Stablecoin/src/shell/Collateral_deployValidator.sh
2) Mint OracleNFT
   script = /workspace/code/Demeter/5_Stablecoin/src/shell/OracleNFT_mint_bob.sh
3) Initialize PriceFeedOracle with Ada-Price of 100 USD cents 
   script = /workspace/code/Demeter/5_Stablecoin/src/shell/PriceFeedOracle_putInit.sh
4) Mint & Burn dUSD Stablecoin
   a) Minting (Wallet Bob)
      script = /workspace/code/Demeter/5_Stablecoin/src/shell/dUSD_mint_bob.sh
   b) Burning (Wallet Bob) 
      script = /workspace/code/Demeter/5_Stablecoin/src/shell/dUSD_burn_bob.sh
5) Mint & Liquidate dUSD Stablecoin
   a) Minting (Wallet Bob)
      script = /workspace/code/Demeter/5_Stablecoin/src/shell/dUSD_mint_bob.sh
   b) Minting (Wallet Alice)
      script = /workspace/code/Demeter/5_Stablecoin/src/shell/dUSD_mint_alice.sh
   c) Decrease Ada-Price in PriceFeedDatum
      script = /workspace/code/Demeter/5_Stablecoin/data/priceFeedOracleDatum.json
   d) Update Ada-Price in PriceFeedOracle
      script = /workspace/code/Demeter/5_Stablecoin/src/shell/PriceFeedOracle_update.sh
   e) Liquidation (Alice liquidates Bobs Collateral)
      script = /workspace/code/Demeter/5_Stablecoin/src/shell/dUSD_liquidate.sh