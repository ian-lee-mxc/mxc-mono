<script lang="ts">
  // import { UserRejectedRequestError } from '@wagmi/core';
  // import { chains } from '../../chain/chains';
  import { ethers, Contract, type Signer } from 'ethers';
  import { LottiePlayer } from '@lottiefiles/svelte-lottie-player';
  import axios from 'axios';
  import { onMount } from 'svelte';
  import {
    // L1_CHAIN_NAME,
    // L2_CHAIN_NAME,
    L1_CHAIN_ID,
    L2_CHAIN_ID,
  } from '../../constants/envVars';
  import type { Chain } from '../../domain/chain';
  import type { Token } from '../../domain/token';
  import { srcChain } from '../../store/chain';
  import { signer } from '../../store/signer';
  import { token } from '../../store/token';
  import { pendingTransactions } from '../../store/transaction';
  import { isTestToken } from '../../token/tokens';
  import { getIsMintedWithEstimation } from '../../utils/getIsMintedWithEstimation';
  import { getLogger } from '../../utils/logger';
  import { mintERC20 } from '../../utils/mintERC20';
  import Button from '../Button.svelte';
  import Loading from '../Loading.svelte';
  import {
    errorToast,
    successToast,
    warningToast,
  } from '../NotificationToast.svelte';
  import TestTokenDropdown from './TestTokenDropdown.svelte';
  import { SITE_KEY } from '../../constants/envVars';
  import { L2Contracts, L2Abis } from '../../constants/config';

  // import { selectChain } from '../../utils/selectChain';
  // import Eth from '../icons/ETH.svelte';
  // import Tko from '../icons/TKO.svelte';

  const log = getLogger('component:Faucet');

  let actionDisabled: boolean = true;
  let loading: boolean = false;
  let errorReason: string = '';
  let switchingNetwork: boolean = false;

  let address: string = '';
  let loading2: boolean = false;
  let loading3: boolean = false;
  let allowCaptcha: boolean = false;
  let isFaucetEth: boolean = true;
  let capToken: string;
  let mxcAllowed: string = 0;

  const getMXCTokenApi = async (address: string) => {
    const response = await axios.get(`/api/faucet/mxc/${address}`);
    return response.data;
  };

  const getMoonTokenApi = async (address: string) => {
    const response = await axios.get(`/api/faucet/moon/${address}`);
    return response.data;
  };

  const getEthApi = async (address: string) => {
    const response = await axios.post(`/api/faucet/arbgoerli`, {
      address,
      token: capToken,
    });
    return response.data;
  };

  const recaptchaApi = async (token: string) => {
    const response = await axios.post(`/api/recaptcha`, { token });
    return response.data;
  };

  $: setAddress($signer).catch((e) => console.error(e));
  async function setAddress(signer: Signer) {
    try {
      address = await signer.getAddress();
    } catch (error) {}
  }

  async function getEth() {
    loading3 = true;
    if (!address) {
      errorToast('No address account!');
      return;
    }
    let res = await getEthApi(address);
    if (res.status == 200) {
      isFaucetEth = false;
      successToast('Request successful!');
    } else {
      isFaucetEth = true;
      errorToast(res.msg);
    }

    loading3 = false;
    if ((window as any).grecaptcha) {
      (window as any).grecaptcha.reset();
    }
  }

  async function getMxcToken() {
    loading = true;

    if (!address) {
      errorToast('No address account!');
      return;
    }

    let res = await getMXCTokenApi(address);
    if (res.status == 200) {
      successToast('Request successful!');
    } else {
      errorToast(res.msg);
    }
    loading = false;
  }

  async function getMoonToken() {
    loading2 = true;

    if (!address) {
      errorToast('No address account!');
      return;
    }

    let res = await getMoonTokenApi(address);
    if (res.status == 200) {
      successToast('Request successful!');
    } else {
      errorToast(res.msg);
    }
    loading2 = false;
  }

  function getCaptcha() {
    setTimeout(() => {
      try {
        (window as any).grecaptcha.render('grecaptcha', {
          sitekey: SITE_KEY,
          callback: async (token) => {
            let res = await recaptchaApi(token);
            if (res.data && res.data.success) {
              allowCaptcha = true;
              isFaucetEth = true;
              capToken = res.data.token || '';
            } else {
              allowCaptcha = false;
            }
          },
        });
      } catch (error) {
        console.log(error);
        // getCaptcha()
      }
    }, 1000);
  }

  $: if ($srcChain && $srcChain.id === L1_CHAIN_ID) {
    getCaptcha();
  }

  async function getFaucetAmount(signer: ethers.Signer, srcChain: Chain) {
    if (signer && srcChain && srcChain.id == L2_CHAIN_ID) {

      const contract = new Contract(L2Contracts.faucet, L2Abis.faucet, signer);
      let getMxcAllowed = await contract.mxcAllowed();
      mxcAllowed = ethers.utils.formatUnits(getMxcAllowed, 18);
    }
  }

  $: getFaucetAmount($signer, $srcChain);

  onMount(async () => {
    (async () => {
      await setAddress($signer);
      getCaptcha();
    })();
  });

  async function shouldDisableButton(signer: Signer, _token: Token) {
    if (
      !signer ||
      !_token ||
      !isTestToken(_token) ||
      $srcChain.id === L2_CHAIN_ID ||
      _token.symbol === 'WETH'
    ) {
      // If signer or token is missing, the button
      // should remained disabled
      return true;
    }

    loading = true;

    try {
      const { isMinted, estimatedGas } = await getIsMintedWithEstimation(
        signer,
        _token,
      );

      if (isMinted) {
        errorReason = 'Token already minted';
        return true;
      }

      const balance = await signer.getBalance();

      if (balance.gt(estimatedGas)) {
        log(`Token ${_token.symbol} can be minted`);

        errorReason = '';
        return false;
      }

      errorReason = 'Insufficient balance';
    } catch (error) {
      console.error(error);

      if (inL1Chain) {
        // We only want to inform the user there is a problem here if
        // they are in the right network. Otherwise, the error is expected.
        errorToast(
          `There seems to be a problem with minting ${_token.symbol} tokens.`,
        );
      }

      errorReason = 'Cannot mint token';
    } finally {
      loading = false;
    }

    return true;
  }

  async function mint(srcChain: Chain, signer: Signer, _token: Token) {
    loading = true;

    try {
      const tx = await mintERC20(srcChain.id, _token, signer);

      successToast(`Transaction sent to mint ${_token.symbol} tokens.`);

      await pendingTransactions.add(tx, signer);

      successToast(
        `<strong>Transaction completed!</strong><br />Your ${_token.symbol} tokens are in your wallet.`,
      );

      // Re-assignment is needed to trigger checks on the current token
      $token = _token;
    } catch (error) {
      console.error(error);

      const headerError = '<strong>Failed to mint tokens</strong>';
      if (error.cause?.status === 0) {
        const explorerUrl = `${srcChain.explorerUrl}/tx/${error.cause.transactionHash}`;
        const htmlLink = `<a href="${explorerUrl}" target="_blank"><b><u>here</u></b></a>`;
        errorToast(
          `${headerError}<br />Click ${htmlLink} to see more details on the explorer.`,
          true, // dismissible
        );
      } else if (error.cause?.code === ethers.errors.ACTION_REJECTED) {
        warningToast(`Transaction has been rejected.`);
      } else {
        errorToast(`${headerError}<br />Try again later.`);
      }
    } finally {
      loading = false;
    }
  }

  // async function switchNetwork() {
  //   switchingNetwork = true;

  //   try {
  //     await selectChain(chains[L1_CHAIN_ID]);
  //   } catch (error) {
  //     console.error(error);

  //     if (error instanceof UserRejectedRequestError) {
  //       warningToast('Switching network has been rejected.');
  //     } else {
  //       errorToast('Failed to switch network.');
  //     }
  //   } finally {
  //     switchingNetwork = false;
  //   }
  // }

  $: shouldDisableButton($signer, $token)
    .then((disable) => (actionDisabled = disable))
    .catch((error) => console.error(error));

  // $: wrongChain = $srcChain && $srcChain.id === L2_CHAIN_ID;
  $: inL2Chain = $srcChain && $srcChain.id === L2_CHAIN_ID;
  $: inL1Chain = $srcChain && $srcChain.id === L1_CHAIN_ID;
  $: pendingTx = $pendingTransactions && $pendingTransactions.length > 0;
  $: disableSwitchButton = switchingNetwork || pendingTx;
  $: disableMintButton = actionDisabled || loading;
</script>

<div class="space-y-4">
  {#if inL2Chain}
    <!-- <p>
      You are on
      <span class="inline-flex items-center space-x-1 mx-2">
        <Tko width={12} height={12} />
        <strong>{L2_CHAIN_NAME}</strong>
      </span>
      network. Please switch to
      <span class="inline-flex items-center space-x-1 mx-2">
        <Eth width={12} height={12} />
        <strong>{L1_CHAIN_NAME}</strong>
      </span>
      to be able to mint Test Tokens.
    </p>

    <Button
      type="accent"
      class="w-full"
      on:click={switchNetwork}
      disabled={disableSwitchButton}>
      <span>
        {#if switchingNetwork}
          <Loading text="Switching…" />
        {:else if pendingTx}
          <Loading text="Pending tx…" />
        {:else}
          Switch to {L1_CHAIN_NAME}
        {/if}
      </span>
    </Button> -->
    <div class="pt-5">
      {#if loading}
        <Button type="accent" size="lg" class="w-6/12" disabled={true}>
          <LottiePlayer
            src="/lottie/loader.json"
            autoplay={true}
            loop={true}
            controls={false}
            renderer="svg"
            background="transparent"
            height={26}
            width={26}
            controlsLayout={[]} />
        </Button>
      {:else}
        <Button
          type="accent"
          size="lg"
          class="w-6/12"
          disabled={!address}
          on:click={getMxcToken}>
          Claim {mxcAllowed} MXC
        </Button>
      {/if}

      <p class="mb-5 mt-1 text-sm">
        Limit the use of a single address to once per day.
      </p>
    </div>

    <div>
      {#if loading2}
        <Button type="accent" size="lg" class="w-6/12" disabled={true}>
          <LottiePlayer
            src="/lottie/loader.json"
            autoplay={true}
            loop={true}
            controls={false}
            renderer="svg"
            background="transparent"
            height={26}
            width={26}
            controlsLayout={[]} />
        </Button>
      {:else}
        <Button
          type="accent"
          size="lg"
          class="w-6/12"
          disabled={!address}
          on:click={getMoonToken}>
          Claim 1 Moon
        </Button>
      {/if}
      <p class="mt-1 text-sm">
        Limit the token redemption to a single occurrence
      </p>
      <p class="text-sm">for a specific wallet address.</p>
    </div>
  {:else}
    {#if loading3}
      <Button type="accent" size="lg" class="w-6/12" disabled={true}>
        <LottiePlayer
          src="/lottie/loader.json"
          ,
          autoplay={true}
          loop={true}
          controls={false}
          renderer="svg"
          background="transparent"
          height={26}
          width={26}
          controlsLayout={[]} />
      </Button>
    {:else}
      <Button
        type="accent"
        size="lg"
        class="w-6/12"
        disabled={!allowCaptcha || !isFaucetEth}
        on:click={getEth}>
        Claim 0.02 ETH
      </Button>
    {/if}
    <p class="mt-1">
      The Arbitrum-Goerli eth can be received only once by an address account in
      the Wannsee network.
    </p>
    <div class="mt-4 flex justify-center" id="grecaptcha" />

    <TestTokenDropdown bind:selectedToken={$token} />

    {#if $token && isTestToken($token)}
      <p>
        <!-- You can request {$token.tokenFaucet} {$token.symbol}. {$token.symbol} is only available to
        be minted on {L1_CHAIN_NAME}. If you are on {L2_CHAIN_NAME}, your
        network will be changed first. You must have a small amount of ETH in
        your {L1_CHAIN_NAME}
        wallet to send the transaction. -->
        MXC Arbitrum Faucet - This faucet is only for running MXC supernodes. Each
        address will get {$token.tokenFaucet}
        {$token.symbol}. If you want to get MXC faucet on Wannsee, you need to
        change your network first. Please make sure you get the Arbitrum Goerli
        ETH first in this faucet.
      </p>
    {:else}
      <p>No token selected to mint.</p>
    {/if}

    <Button
      type="accent"
      class="w-full"
      disabled={disableMintButton}
      on:click={() => mint($srcChain, $signer, $token)}>
      <span>
        {#if loading}
          <Loading />
        {:else if actionDisabled}
          {errorReason || 'Mint'}
        {:else}
          Mint {$token.name}
        {/if}
      </span>
    </Button>
  {/if}
</div>
