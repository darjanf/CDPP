## Instructions

# 1. Download cardano-node libraries for linux
URL: https://github.com/input-output-hk/cardano-node/releases
# 2. Download all configuration files for "Preview Testnet" 
(attention: verify, that you download the preview configuration files!)
URL: https://book.world.dev.cardano.org/environments.html
# 3. Download .bashrc commands for "Preview Testnet" from
URL: https://github.com/mallapurbharat/cardano-tx-sample/blob/main/0_installation/preview_preprod_network/2_setup_preview_preprod_networks.md
# 4. Extract cardano-node tar file to $HOME
# 5. Create a testnet folder under $HOME/
# 6. Create folders 'config', 'db', 'exercises' under $HOME/testnet
# 7. Create preview folder under $HOME/testnet/config
# 8. Copy configuration files from task (.2) to $HOME/testnet/config/preview
# 9. Copy commands from task (.3) to the existing $HOME/.bashrc file and change paths
# 10. Run 'previewnode' (command is defined in .bashrc)
# 11. Run 'ctip' (command is defined in .bashrc)
You sould get a similar result:
{
    "block": 103929,
    "epoch": 25,
    "era": "Babbage",
    "hash": "99441a87ad4601e4e977bf4727a02dd6d9d0dca7dddc11aa205053e02f73da25",
    "slot": 2208226,
    "syncProgress": "16.22"
}