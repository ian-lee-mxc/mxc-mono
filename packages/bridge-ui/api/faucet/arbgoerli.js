import { ethers } from 'ethers';
import requestIp from 'request-ip';
import config from '../config.js';
import { Redis } from '@upstash/redis';

const redis = new Redis({
  url: config.upstash_redis_rest_url,
  token: config.upstash_redis_rest_token,
});

const provider = new ethers.providers.JsonRpcProvider(config.L1_RPC_URL);
const wallet = new ethers.Wallet(config.private_key, provider);
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

  // recaptcha check
  let getToken = await redis.get(token);
  if (!getToken) {
    return res
      .status(200)
      .send({ status: 13, msg: `This reCAPTCHA is not allowed.` });
  }

  // address check
  let receHashVal = await redis.hget('address', address);
  if (receHashVal == '1') {
    await redis.del(token);
    return res
      .status(200)
      .send({ status: 12, msg: `This address has already received.` });
  }

  // ip check
  const ipAddress = requestIp.getClientIp(req);
  let ipVal = await redis.hget('ips', ipAddress);
  if (ipVal == '1') {
    await redis.del(token);
    return res
      .status(200)
      .send({ status: 11, msg: `Try to use your mobile data to claim the faucet.` });
  }

  try {
    await wallet.sendTransaction({
      to: address,
      value: parseEther('0.02'),
    });
  } catch (error) {
    await redis.del(token);
    return res
      .status(200)
      .send({ status: 20, msg: `The transaction has failed: ${error}` });
  }

  await redis.hset('address', {
    [address]: '1',
  });
  await redis.hset('ips', {
    [ipAddress]: '1',
  });
  await redis.del(token);

  return res.status(200).send({ status: 200, data: `Successful!` });
}
