'''
###########################################################
#                                                         #
#                     ⚠️ ATTENTION ⚠️                     #
#                                                         #
#  Follow these instructions carefully to create the      #
#  raw NFT data and perform on-chain minting correctly.   #
#  Errors in JSON files, images, or .env parameters       #
#  can cause transaction failures or loss of funds.       #
#                                                         #
###########################################################

Instruction to create raw data for NFTs:

1- Before running this script, create a .json file for the new member of the ByteTheCookies Team using the following format:

{
    "tokenID": Latest Token ID + 1 of the NFT Collection (or some ID never used),
    "name": "Member name",
    "description": "Creative description of the member",
    "image": "data:image/svg+xml;<<base64,base64-image-endoded>>" #base64 code after the ";"
}

IMPORTANT: On-chain image uploads only work with very small files, around 3-4 KB (max 5 KB). 
Normally images are stored off-chain, but here we include them on-chain to guarantee absolute
ownership and make the NFT's asset fully self-contained, reflecting its ideological value.

2- Run the script to create a .txt file for each .json file. Each .txt will contain the 
base64-encoded data, which will serve as the final content to be uploaded on-chain.

3- Put the final base64-encoded data in the 'exampleImageUri' variable in the script/Interactions.sol file

4- Read the Makefile and use the mint command using the keystore file of the member. 

Remember to set the member name in the .env file before running the command, and make sure 
that the corresponding on-chain address has enough ETH to cover both the transaction 
fees and the minting cost (0.1 ETH + fees).

Future work should automate this process....

'''

import os
import json
import base64


current_dir = os.path.dirname(os.path.abspath(__file__))

for filename in os.listdir(current_dir):
    if filename.lower().endswith(".json"):
        json_path = os.path.join(current_dir, filename)

        with open(json_path, "r", encoding="utf-8") as f:
            data = f.read()

        encoded = base64.b64encode(data.encode("utf-8")).decode("utf-8")
        final_content = f"application/json;base64,{encoded}"

        output_filename = os.path.splitext(filename)[0] + ".txt"
        output_path = os.path.join(current_dir, output_filename)

        with open(output_path, "w", encoding="utf-8") as f:
            f.write(final_content)

        print(f"Created at: {output_filename}")
