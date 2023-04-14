import { ethers } from 'ethers';
import requestIp from 'request-ip';

import client from '../redis.js';
import config from '../config.js';
let { L1_RPC_URL, private_key } = config;

const provider = new ethers.providers.JsonRpcProvider(L1_RPC_URL);
const wallet = new ethers.Wallet(private_key, provider);
const parseEther = ethers.utils.parseEther;
const formatEther = ethers.utils.formatEther;

const ethereumAddressRegex = /^(0x)?[0-9a-fA-F]{40}$/;
function isEthereumAddress(address) {
  return ethereumAddressRegex.test(address);
}

export default async function handler(req, res) {
  // res.statusCode = 200;
  const { address, token } = req.body;
  if (
    !address ||
    typeof address !== 'string' ||
    address.trim() === '' ||
    !isEthereumAddress(address)
  ) {
    return res.status(200).json({ status: 10, msg: 'Invalid address.' });
  }

  let balance = await provider.getBalance(wallet.address);
  if (parseFloat(formatEther(balance)) < 0.1) {
    return res.status(200).send({
      status: 14,
      msg: `Faucet balance is insufficient. Please contact faucet@mxc.com for assistance.`,
    });
  }

  try {
    await client.connect();
  } catch (error) {
    return res
      .status(200)
      .send({ status: 80, msg: `Redis connection failed: ${error}` });
  }

  // recaptcha check
  let getToken = await client.get(token);
  if (!getToken) {
    return res
      .status(200)
      .send({ status: 13, msg: `This reCAPTCHA is not allowed.` });
  }

  // ip check
  const ipAddress = requestIp.getClientIp(req);
  let ipHashVal = await client.HGET('ips', ipAddress);
  if (ipHashVal == 1) {
    return res
      .status(200)
      .send({ status: 11, msg: `This IP address has already received.` });
  }

  // address check
  let receHashVal = await client.HGET('received', address);
  if (receHashVal == 1) {
    return res
      .status(200)
      .send({ status: 12, msg: `This address has already received.` });
  }

  try {
    await wallet.sendTransaction({
      to: address,
      value: parseEther('0.02'),
    });
  } catch (error) {
    console.log(error);
    return res
      .status(200)
      .send({ status: 20, msg: `The transaction has failed.` });
  }

  await client.hSet('received', address, 1);
  await client.hSet('ips', ipAddress, 1);
  await client.del(token);
  await client.quit();

  return res.status(200).send({ status: 200, data: `Successful!` });
}
