import { ethers } from 'ethers';
import client from './redis.js';
import config from './config.js';
import { format } from 'prettier';

let { L1_RPC_URL, private_key } = config;
const provider = new ethers.providers.JsonRpcProvider(L1_RPC_URL);
const wallet = new ethers.Wallet(private_key, provider);
const parseEther = ethers.utils.parseEther;
const formatEther = ethers.utils.formatEther;

export default async function handler(req, res) {
  let balance = await provider.getBalance(wallet.address);
  if (parseFloat(formatEther(balance)) < 0.1) {
    return res.status(200).send({
      status: 14,
      msg: `Faucet balance is insufficient. Please contact faucet@mxc.com for assistance.`,
    });
  }

  // try {
  //   await client.connect();
  // } catch (error) {
  //   return res
  //     .status(200)
  //     .send({ status: 80, msg: `Redis connection failed: ${error}` });
  // }

  // try {
  //   await wallet.sendTransaction({
  //     to: '0x63cC3f82293A460717C832e4574Ca63C2aD247b3',
  //     value: parseEther('0.06'),
  //   });
  // } catch (error) {
  //   console.log(error);
  //   return res.status(200).send({ status: 20, msg: `Transaction Failed!` });
  // }

  // await client.set('03AKH6MRHe2AAA2DELpSH1Y9y44L41', '1');
  // await client.del('03AKH6MRHe2AAA2DELpSH1Y9y44L41');

  // let rs = await client.get('03AKH6MREEjztMp810U2vtDP6N1wC5');
  // console.log(rs);
  // if (rs) {
  //   console.log(rs, 999);
  // }

  //   await client.hSet('token', '0x12345', 1);
  //   await client.HDEL('token', '0x12345');

  // await client.hDel('received', '0xa8eF099f636AFe4210de699f546A37326820aaF7');
  // await client.hDel('received', '::1');
  // await client.hDel('ips', '0x63cC3f82293A460717C832e4574Ca63C2aD247b3');

  // let receHash = await client.HGETALL('received');
  // console.log(receHash);

  // let ipsHash = await client.HGETALL('ips');
  // console.log(ipsHash);

  //   let tokenHash = await client.HGET('token', '0x12345');
  //   console.log(tokenHash);

  return res.status(200).send({ status: 200, data: `Hello world` });
}
