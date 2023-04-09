import * as dotenv from 'dotenv';

const config = dotenv.config().parsed;

export default {
  private_key: config.PRIVATE_KEY,

  address1: '0x4faBD45F69D907aC3a3941c34f466A6EFf44bAcA',
  address2: '0xa8eF099f636AFe4210de699f546A37326820aaF7',

  RPC_URL: `https://rpc.a2.taiko.xyz`,
  c_simpleStorage: `0x6F17DbD2C10d11f650fE49448454Bf13dFA91641`,
  c_moonToken: `0x6c3c72297C448A4BAa6Fc45552657Ad68378E3E1`,
  c_faucet: `0x3c195C14D329C6B91Fd241d09a960d5A31eA8742`,

  // RPC_URL: `https://wannsee-rpc.mxc.com`,
  // c_simpleStorage: ``,
  // c_moonToken: ``,
  // c_faucet: ``,

  abiFaucet: [
    'function requestMoon(address recipient) external',
    'function requestMXC(address recipient) external',
  ],
};
