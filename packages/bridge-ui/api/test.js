import { ethers } from 'ethers';
import { format } from 'prettier';
import config from './config.js';
import { Redis } from '@upstash/redis';
let { RPC_URL, private_key, c_faucet, abiFaucet } = config;
const provider = new ethers.providers.JsonRpcProvider(RPC_URL);

const redis = new Redis({
  url: config.upstash_redis_rest_url,
  token: config.upstash_redis_rest_token,
});
const wallet = new ethers.Wallet(private_key, provider);

// const provider = new ethers.providers.JsonRpcProvider(L1_RPC_URL);
// const wallet = new ethers.Wallet(private_key, provider);
// const parseEther = ethers.utils.parseEther;
// const formatEther = ethers.utils.formatEther;

export default async function handler(req, res) {
  // const contractFaucet = new ethers.Contract(c_faucet, abiFaucet, wallet);
  // const address = `0xC75A79a61c6E828c7D58a321C44e6B1fdbAA4055`;
  // let gets = await contractFaucet.callStatic.requestMXC(address);
  // console.log(gets);

  // console.log(L1_RPC_URL, private_key);
  // let balance = await provider.getBalance(wallet.address);
  // if (parseFloat(formatEther(balance)) < 0.1) {
  //   return res.status(200).send({
  //     status: 14,
  //     msg: `Faucet balance is insufficient. Please contact faucet@mxc.com for assistance.`,
  //   });
  // }

  // const token = '03AKH6MRFeXnhcE9unaTJf2vbAy0mT';
  // await redis.del(token);

  // // await redis.set('key', 'value');
  // let data = await redis.get(token);
  // console.log(data);

  // const address = '0x63cC3f82293A460717C832e4574Ca63C2aD247b3';
  // const ipAddress = '127.0.0.1';
  // // console.log();
  // await redis.hset('address', {
  //   [address]: 1,
  // });
  // await redis.hset('ips', {
  //   [ipAddress]: 1,
  // });

  // clear all data
  // await redis.flushall();

  // await redis.hset('address', {
  //   '0xa8eF099f636AFe4210de699f546A37326820aaF7': '1',
  // });
  // let data = await redis.hget(
  //   'address',
  //   '0xa8eF099f636AFe4210de699f546A37326820aaF7',
  // );
  // console.log(data);

  // try {
  //   await wallet.sendTransaction({
  //     to: '0x63cC3f82293A460717C832e4574Ca63C2aD247b3',
  //     value: parseEther('0.06'),
  //   });
  // } catch (error) {
  //   console.log(error);
  //   return res.status(200).send({ status: 20, msg: `Transaction Failed!` });
  // }

  return res.status(200).send({ status: 200, data: 'hello' });
}
