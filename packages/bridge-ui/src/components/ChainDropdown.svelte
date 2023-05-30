<script lang="ts">
  import { fromChain } from '../store/chain';
  import { ChevronDown, ExclamationTriangle } from 'svelte-heros-v2';
  import { mainnetChain, taikoChain } from '../chain/chains';
  import { selectChain } from '../utils/selectChain';
  import type { Chain } from '../domain/chain';
  import { errorToast, successToast } from './Toast.svelte';
  import { signer } from '../store/signer';

  import MxcIcon from "../assets/token/mxc.png"
  import EthIcon from "../assets/ether.png"

  const switchChains = async (chain: Chain) => {
    if (!$signer) {
      errorToast('Please connect your wallet');
      return;
    }

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

<div class="dropdown dropdown-end mr-4">
  <!-- svelte-ignore a11y-label-has-associated-control -->
  <!-- svelte-ignore a11y-no-noninteractive-element-to-interactive-role -->
  <label
    role="button"
    tabindex="0"
    class="btn btn-md justify-around md:w-[200px]">
    <span class="font-normal flex-1 text-left mr-2 flex items-center justify-center">
      {#if $fromChain}
        <!-- <svelte:component this={$fromChain.icon} /> -->
        <img src={$fromChain.logoUrl} height={30} width={30} alt="" >
        <span class="ml-2 hidden md:inline-block">{$fromChain.name}</span>
      {:else}
        <span class="ml-2 flex items-center">
          <ExclamationTriangle class="mr-2" size="20" />
          <span class="hidden md:block">Invalid Chain</span>
        </span>
      {/if}
    </span>
    <ChevronDown size="20" />
  </label>
  <ul
    role="listbox"
    tabindex="0"
    class="dropdown-content address-dropdown-content flex my-2 menu p-2 shadow bg-dark-2 rounded-sm w-[194px]">
    <li>
      <button
        class="flex items-center px-2 py-4 hover:bg-dark-5 rounded-xl justify-around"
        on:click={() => switchChains(mainnetChain)}>
        <!-- <svelte:component this={mainnetChain.icon} height={24} /> -->
        <img src={EthIcon} height={24} width={24} alt="" />
        <span class="pl-1.5 text-left flex-1">{mainnetChain.name}</span>
      </button>
    </li>
    <li>
      <button
        class="flex items-center px-2 py-4 hover:bg-dark-5 rounded-xl justify-around"
        on:click={() => switchChains(taikoChain)}>
        <!-- <svelte:component this={taikoChain.icon} height={24} /> -->
        <img src={MxcIcon} height={24} width={24} alt="" />
        <span class="pl-1.5 text-left flex-1">{taikoChain.name}</span>
      </button>
    </li>
  </ul>
</div>
