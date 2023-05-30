<script>
  import { switchNetwork } from '@wagmi/core';
  import { ArrowRight } from 'svelte-heros-v2';
  import { fromChain, toChain } from '../../store/chain';
  import { signer } from '../../store/signer';
  import { mainnetChain, taikoChain } from '../../chain/chains';
  import { errorToast, successToast } from '../Toast.svelte';
  import { selectChain } from '../../utils/selectChain';

  const toggleChains = async () => {
    if (!$signer) {
      errorToast('Please connect your wallet');
      return;
    }

    const chain = $fromChain === mainnetChain ? taikoChain : mainnetChain;

    try {
      await selectChain(chain);
      successToast('Successfully changed chain');
    } catch (e) {
      console.error(e);
      // errorToast('Error switching chain');
      errorToast('Error Switching Chain. Try Switching Manually On Your Wallet');
    }
  };
</script>

<div
  class="flex items-center justify-between w-full px-4 md:px-7 py-6 text-sm md:text-lg text-white">
  <div class="flex items-center w-2/5 justify-center">
    {#if $fromChain}
      <!-- <svelte:component this={$fromChain.icon} /> -->
      <img src={$fromChain.logoUrl} height={30} width={30} alt="" >
      <span class="chain-name ml-2">{$fromChain.name}</span>
    {:else}
      <!-- <svelte:component this={mainnetChain.icon} /> -->
      <img src={mainnetChain.logoUrl} height={30} width={30} alt="" >
      <span class="chain-name ml-2">{mainnetChain.name}</span>
    {/if}
  </div>

  <button on:click={toggleChains} class="btn btn-square btn-sm toggle-chain">
    <ArrowRight size="16" />
  </button>

  <div class="flex items-center w-2/5 justify-center">
    {#if $toChain}
      <!-- <svelte:component this={$toChain.icon} /> -->
      <img src={$toChain.logoUrl} height={30} width={30} alt="" >
      <span class="chain-name ml-2">{$toChain.name}</span>
    {:else}
      <!-- <svelte:component this={taikoChain.icon} /> -->
      <img src={taikoChain.logoUrl} height={30} width={30} alt="" >
      <span class="chain-name ml-2">{taikoChain.name}</span>
    {/if}
  </div>
</div>
