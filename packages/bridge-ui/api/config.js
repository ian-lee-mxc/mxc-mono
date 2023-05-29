import * as dotenv from 'dotenv';
dotenv.config();

let {
  PRIVATE_KEY,
  RECAPTCHA_SECRET_KEY,
  UPSTASH_REDIS_REST_URL,
  UPSTASH_REDIS_REST_TOKEN,
} = process.env;

export default {
  version: 7,
  private_key: PRIVATE_KEY,
  recaptcha_secret_key: RECAPTCHA_SECRET_KEY,
  upstash_redis_rest_url: UPSTASH_REDIS_REST_URL,
  upstash_redis_rest_token: UPSTASH_REDIS_REST_TOKEN,

  // address1: '0x4faBD45F69D907aC3a3941c34f466A6EFf44bAcA',
  // address2: '0xa8eF099f636AFe4210de699f546A37326820aaF7',

  // RPC_URL: `https://rpc.a2.taiko.xyz`,
  // c_moonToken: `0x6c3c72297C448A4BAa6Fc45552657Ad68378E3E1`,
  // c_faucet: `0x3c195C14D329C6B91Fd241d09a960d5A31eA8742`,

  RPC_URL: `https://wannsee-rpc.mxc.com`,
  L1_RPC_URL: `https://goerli-rollup.arbitrum.io/rpc`,
  c_moonToken: `0xe031013A7B7Caf05FC20Bdc49B731E3F2f0cAfFd`,
  c_faucet: `0xEAA4b0e2e0CB6Ce39B547767cEd6711e704831E4`,

  abiFaucet: [
    'function requestMoon(address recipient) external',
    'function requestMXC(address recipient) external',
  ],
};
