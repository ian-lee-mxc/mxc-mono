<script>
  import { UserRejectedRequestError } from '@wagmi/core';
  import { ArrowRight } from 'svelte-heros-v2';

  import { mainnetChain, taikoChain } from '../../chain/chains';
  import { destChain,srcChain } from '../../store/chain';
  import { signer } from '../../store/signer';
  import { pendingTransactions } from '../../store/transaction';
  import { selectChain } from '../../utils/selectChain';
  import {
    errorToast,
    successToast,
    warningToast,
  } from '../NotificationToast.svelte';

  const toggleChains = async () => {
    if (!$signer) {
      warningToast('Please, connect your wallet.');
      return;
    }

    const chain = $srcChain === mainnetChain ? taikoChain : mainnetChain;

    try {
      await selectChain(chain);
      successToast('Successfully changed chain.');
    } catch (error) {
      console.error(error);

      if (error instanceof UserRejectedRequestError) {
        warningToast('Switch chain request canceled.');
      } else {
        errorToast('Error switching chain.');
      }
    }
  };

  $: cannotToggle = $pendingTransactions && $pendingTransactions.length > 0;
</script>

<div
  class="flex items-center justify-between w-full px-4 md:px-7 py-6 text-sm md:text-lg">
  <div class="flex items-center w-2/5 justify-center">
    {#if $srcChain}
      <!-- <svelte:component this={$srcChain.icon} /> -->
      <img src={$srcChain.logoUrl} height={30} width={30} alt="" >
      <span class="ml-2">{$srcChain.name}</span>
    {:else}
      <!-- <svelte:component this={mainnetChain.icon} /> -->
      <img src={mainnetChain.logoUrl} height={30} width={30} alt="" >
      <span class="ml-2">{mainnetChain.name}</span>
    {/if}
  </div>

  <button
    disabled={cannotToggle}
    on:click={toggleChains}
    class="btn rounded btn-sm toggle-chain">
    <ArrowRight size="16" />
  </button>

  <div class="flex items-center w-2/5 justify-center">
    {#if $destChain}
      <!-- <svelte:component this={$destChain.icon} /> -->
      <img src={$destChain.logoUrl} height={30} width={30} alt="" >
      <span class="ml-2">{$destChain.name}</span>
    {:else}
      <!-- <svelte:component this={taikoChain.icon} /> -->
      <img src={taikoChain.logoUrl} height={30} width={30} alt="" >
      <span class="ml-2">{taikoChain.name}</span>
    {/if}
  </div>
</div>
