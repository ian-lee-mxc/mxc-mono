import type { ComponentType } from 'svelte';

type Address = {
  chainId: number;
  address: string;
};

export type Token = {
  name: string;
  addresses: Address[];
  symbol: string;
  decimals: number;
  logoUrl?: string;
  // is chain token
  isETHToken?: boolean;
  // faucet get number
  tokenFaucet?: number;
  logoComponent: ComponentType;
};

export type TokenDetails = {
  symbol: string;
  decimals: number;
  address: string;
  userTokenBalance: string;
};

export interface TokenService {
  storeToken(token: Token, address: string): Token[];
  getTokens(address: string): Token[];
  removeToken(token: Token, address: string): Token[];
}
