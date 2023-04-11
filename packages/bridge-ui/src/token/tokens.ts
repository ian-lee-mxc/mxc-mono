// import Bull from '../components/icons/Bull.svelte';
// import Horse from '../components/icons/Horse.svelte';
// import Tko from '../components/icons/TKO.svelte';
import Eth from '../components/icons/ETH.svelte';
import Mxc from '../components/icons/MXC.svelte';
import Unknown from '../components/icons/Unknown.svelte';
import { L1_CHAIN_ID, L2_CHAIN_ID, TEST_ERC20 } from '../constants/envVars';
import type { Token } from '../domain/token';

import MxcIcon from "../assets/token/mxc.png"
import ParkIcon from "../assets/token/park.svg"
import RideIcon from "../assets/token/bicycle.svg"
import MoonIcon from "../assets/token/moon.svg"

export const ETHToken: Token = {
  name: 'Ethereum',
  addresses: [
    {
      chainId: L1_CHAIN_ID,
      address: '0x00',
    },
    {
      chainId: L2_CHAIN_ID,
      address: '0x00',
    },
  ],
  decimals: 18,
  symbol: 'ETH',
  logoComponent: Eth,
};

export const MXCToken: Token = {
  name: 'MXC',
  addresses: [
    {
      chainId: L1_CHAIN_ID,
      address: '0x00',
    },
    {
      chainId: L2_CHAIN_ID,
      address: '0x00',
    },
  ],
  decimals: 18,
  symbol: 'MXC',
  logoComponent: Mxc,
  logoUrl: MxcIcon
};

// export const TKOToken: Token = {
//   name: 'Taiko',
//   addresses: [
//     {
//       chainId: L1_CHAIN_ID,
//       address: '0x00',
//     },
//     {
//       chainId: L2_CHAIN_ID,
//       address: '0x00',
//     },
//   ],
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
  Ride: RideIcon,
  Park: ParkIcon,
  Moon: MoonIcon
};

export const testERC20Tokens: Token[] = TEST_ERC20.map(
  ({ name, address, symbol }) => ({
    name,
    symbol,

    addresses: [
      {
        chainId: L1_CHAIN_ID,
        address,
      },
      {
        chainId: L2_CHAIN_ID,
        address: '0x00',
      },
    ],
    decimals: 18,
    logoComponent: symbolToLogoComponent[symbol] || Unknown,
    logoUrl: symbolToLogoSvg[symbol],
  }),
);
// ETHToken
export const tokens = [MXCToken, ...testERC20Tokens];
