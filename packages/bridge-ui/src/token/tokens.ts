// import Bull from '../components/icons/Bull.svelte';
// import Eth from '../components/icons/ETH.svelte';
// import Horse from '../components/icons/Horse.svelte';
// import Tko from '../components/icons/TKO.svelte';
import Unknown from '../components/icons/Unknown.svelte';
import { L1_CHAIN_ID, L2_CHAIN_ID, TEST_ERC20, L1MXCTOKEN } from '../constants/envVars';
import type { Token } from '../domain/token';

import Mxc from '../components/icons/MXC.svelte';
import MxcIcon from "../assets/token/mxc.png"
import ParkIcon from "../assets/token/park.svg"
import RideIcon from "../assets/token/bicycle.svg"
import MoonIcon from "../assets/token/moon.svg"


export const ETHToken: Token = {
  name: 'MXC',
  addresses: {
    [L1_CHAIN_ID]: L1MXCTOKEN,
    [L2_CHAIN_ID]: '0x00',
  },
  decimals: 18,
  symbol: 'MXC',
  logoComponent: Mxc,
  logoUrl: MxcIcon,
  isChainToken: true,
  tokenFaucet: 2000
};

// export const ETHToken: Token = {
//   name: 'Ethereum',
//   addresses: {
//     [L1_CHAIN_ID]: '0x00',
//     [L2_CHAIN_ID]: '0x00',
//   },
//   decimals: 18,
//   symbol: 'ETH',
//   logoComponent: Eth,
// };

// export const TKOToken: Token = {
//   name: 'Taiko',
//   addresses: {
//     [L1_CHAIN_ID]: '0x00',
//     [L2_CHAIN_ID]: '0x00',
//   },
//   decimals: 18,
//   symbol: 'TKO',
//   logoComponent: Tko,
// };

const symbolToLogoComponent = {
  // BLL: Bull,
  // HORSE: Horse,
  // Add more symbols
};

const symbolToLogoSvg = {
  MXC: MxcIcon,
  Ride: RideIcon,
  Park: ParkIcon,
  Moon: MoonIcon,
};

export const testERC20Tokens: Token[] = TEST_ERC20.map(
  ({ name, address, symbol }) => ({
    name,
    symbol,

    addresses: {
      [L1_CHAIN_ID]: address,
      [L2_CHAIN_ID]: '0x00',
    },
    decimals: 18,
    tokenFaucet: symbol == 'MXC' ? 2000 : 50,
    logoUrl: symbolToLogoSvg[symbol],
    logoComponent: symbolToLogoComponent[symbol] || Unknown,
  }),
);

export const tokens = [ETHToken, ...testERC20Tokens];

export function isTestToken(token: Token): boolean {
  const testingTokens = TEST_ERC20.map((testToken) =>
    testToken.symbol.toLocaleLowerCase(),
  );
  return testingTokens.includes(token.symbol.toLocaleLowerCase());
}

export function isETH(token: Token): boolean {
  return (
    token.symbol.toLocaleLowerCase() === ETHToken.symbol.toLocaleLowerCase()
  );
}

export function isERC20(token: Token): boolean {
  return !isETH(token);
}
