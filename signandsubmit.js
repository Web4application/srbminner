import fs from "fs";
import { createHash } from "crypto";
import { ethers } from "ethers";
import openpgp from "openpgp";
import { create as ipfsHttpClient } from "ipfs-http-client";
import dotenv from "dotenv";

dotenv.config();

const { PRIVATE_KEY, RPC_URL, CONTRACT_ADDRESS, PGP_PRIVATE_KEY, PGP_PASSPHRASE, BLOCKCHAIN_ADDRESSES, IPFS_PROJECT_ID, IPFS_PROJECT_SECRET, IPFS_ENDPOINT } = process.env;

const addresses = BLOCKCHAIN_ADDRESSES.split(",").map(addr => addr.trim());

// Initialize IPFS client
const ipfs = ipfsHttpClient({
  url: IPFS_ENDPOINT || "https://ipfs.infura.io:5001/api/v0",
  headers: IPFS_PROJECT_ID && IPFS_PROJECT_SECRET ? {
    authorization: 'Basic ' + Buffer.from(IPFS_PROJECT_ID + ':' + IPFS_PROJECT_SECRET).toString('base64')
  } : undefined
});

async function main() {
  const privateKey = await openpgp.readKey({ armoredKey: PGP_PRIVATE_KEY });
  const decryptedKey = await openpgp.decryptKey({ privateKey, passphrase: PGP_PASSPHRASE });

  const provider = new ethers.JsonRpcProvider(RPC_URL);
  const wallet = new ethers.Wallet(PRIVATE_KEY, provider);
  const abi = [
    "function submitProof(bytes32 proofHash) public",
    "function verifyProof(bytes32 proofHash) public view returns (bool)"
  ];
  const contract = new ethers.Contract(CONTRACT_ADDRESS, abi, wallet);

  for (let addr of addresses) {
    const timestamp = new Date().toISOString();

    const identityMessage = `
I am Seriki Yakub, owner of QUBUHUB.
PGP Key: kubucoin@proton.me
Blockchain address: ${addr}
Date: ${timestamp}
`;

    // 1️⃣ Sign message
    const signed = await openpgp.sign({
      message: await openpgp.createMessage({ text: identityMessage }),
      signingKeys: decryptedKey,
      detached: false
    });

    const signedFile = `identity_signed_${addr}.asc`;
    fs.writeFileSync(signedFile, signed);
    console.log(`Signed message saved to ${signedFile}`);

    // 2️⃣ Upload to IPFS
    const { cid } = await ipfs.add(signed);
    console.log(`Uploaded to IPFS: https://ipfs.io/ipfs/${cid.toString()}`);

    // 3️⃣ Compute SHA-256 hash
    const hashBuffer = createHash("sha256").update(signed, "utf8").digest();
    const proofHash = ethers.utils.hexlify(hashBuffer);
    console.log(`Computed proof hash for ${addr}:`, proofHash);

    // 4️⃣ Submit to Ethereum
    const tx = await contract.submitProof(proofHash);
    console.log(`Transaction submitted for ${addr}:`, tx.hash);
    await tx.wait();
    console.log(`Transaction confirmed for ${addr}!`);

    // 5️⃣ Verify on-chain
    const exists = await contract.verifyProof(proofHash);
    console.log(`Proof exists on-chain for ${addr}:`, exists);
    console.log("------------------------------------------------------");
  }
}

main().catch(console.error);
