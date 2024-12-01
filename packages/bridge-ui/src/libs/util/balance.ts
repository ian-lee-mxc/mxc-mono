import { getAccount, getBalance, type GetBalanceReturnType } from '@wagmi/core';
import { formatEther } from 'viem';

import { truncateString } from '$libs/util/truncateString';
import { config } from '$libs/wagmi';
import { ethBalance } from '$stores/balance';

export function renderBalance(balance: Maybe<GetBalanceReturnType>): string {
  if (!balance) return '0.00';

  const [integerPart, decimalPart] = balance.formatted.split('.');
  const maxlength = Number(balance.formatted) < 0.000001 ? balance.decimals : 6;

  const truncatedDecimal = decimalPart ? truncateString(decimalPart, maxlength, '') : '';
  const formattedBalance = decimalPart ? `${integerPart}.${truncatedDecimal}` : integerPart;

  return `${formattedBalance} ${truncateString(balance.symbol, 7)}`;
}

export function renderEthBalance(balance: bigint, maxlength = 8): string {
  return `${truncateString(formatEther(balance).toString(), maxlength, '')}`;
}

export const refreshUserBalance = async () => {
  const account = getAccount(config);
  let balance = BigInt(0);
  if (account?.address) {
    balance = (await getBalance(config, { address: account.address })).value;
  }
  ethBalance.set(balance);
};
