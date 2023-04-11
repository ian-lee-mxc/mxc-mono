import { ethers } from 'ethers';
import config from '../../config.js';
let { RPC_URL, private_key, c_faucet, abiFaucet } = config;

const provider = new ethers.providers.JsonRpcProvider(RPC_URL);
const wallet = new ethers.Wallet(private_key, provider);

const ethereumAddressRegex = /^(0x)?[0-9a-fA-F]{40}$/;
function isEthereumAddress(address) {
  return ethereumAddressRegex.test(address);
}

export default async function handler(req, res) {
  res.statusCode = 200;
  const { address } = req.query;

  if (
    typeof address !== 'string' ||
    address.trim() === '' ||
    !isEthereumAddress(address)
  ) {
    return res.status(200).json({ status: 400, data: 'Invalid address' });
  }

  const contractFaucet = new ethers.Contract(c_faucet, abiFaucet, wallet);
  try {
    await contractFaucet.callStatic.requestMoon(address, {
      gasPrice: 9000000000000,
      gasLimit: 3000000,
    });
  } catch (error) {
    return res
      .status(200)
      .send({ status: 400, data: `Faucet Request Moon Token Fail!` });
  }

  let tx = await contractFaucet.requestMoon(address, {
    gasPrice: 9000000000000,
    gasLimit: 3000000,
  });
  await tx.wait();
  return res
    .status(200)
    .send({ status: 200, data: `Faucet Request Moon Token Successful!` });
}
