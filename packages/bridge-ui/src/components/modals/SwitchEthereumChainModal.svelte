<script lang="ts">
  import { _ } from 'svelte-i18n';
  import { fetchSigner, switchNetwork, getNetwork } from '@wagmi/core';
  import type { Chain } from '../../domain/chain';
  import { isSwitchEthereumChainModalOpen } from '../../store/modal';
  import Modal from './Modal.svelte';
  import { signer } from '../../store/signer';
  import { mainnetChain, taikoChain } from '../../chain/chains';
  import { errorToast, successToast } from '../Toast.svelte';
  import { L2_CHAIN_ID } from '../../constants/envVars';

  const addChain = async (chain: Chain) => {
    await window.ethereum.request({
      method: "wallet_addEthereumChain",
      params: [{
        chainId: "0x4ed79b",
        rpcUrls: ["https://wannsee-rpc.mxc.com/"],
        chainName: "wannsee",
        nativeCurrency: {
          name: "MXC",
          symbol: "MXC",
          decimals: 18
        },
        blockExplorerUrls: ["https://wannsee-explorer.mxc.com/"]
      }]
    });

    const wagmiSigner = await fetchSigner();
    signer.set(wagmiSigner);
    isSwitchEthereumChainModalOpen.set(false);
    successToast('Successfully switched chain');
  }

  const switchChain = async (chain: Chain) => {
    try {
      await switchNetwork({
        chainId: chain.id,
      });
      const wagmiSigner = await fetchSigner();

      signer.set(wagmiSigner);
      isSwitchEthereumChainModalOpen.set(false);
      successToast('Successfully switched chain'); 
    } catch (e) {
      console.error(e);
      // errorToast('Error switching ethereum chain');
      errorToast('Error Switching Chain. Try Add MXC Network or Switching Manually On Your Wallet');
    }
  };
</script>

<Modal
  title={$_('switchChainModal.title')}
  showXButton={false}
  isOpen={$isSwitchEthereumChainModalOpen}>
  <div class="w-100 text-center px-4">
    <span class="font-light text-sm">{$_('switchChainModal.subtitle')}</span>
    <div class="py-8 space-y-4 flex flex-col">
      <button
        class="btn btn-dark-5 h-[60px] text-base"
        on:click={async () => {
          await switchChain(mainnetChain);
        }}>
        <svelte:component this={mainnetChain.icon} /><span class="ml-2"
          >{mainnetChain.name}</span>
      </button>
      <button
        class="btn btn-dark-5 h-[60px] text-base"
        on:click={async () => {
          await switchChain(taikoChain);
        }}>
        <svelte:component this={taikoChain.icon} /><span class="ml-2"
          >{taikoChain.name}</span>
      </button>
      <button
        class="btn btn-dark-5 h-[60px] text-base"
        on:click={async () => {
          await addChain(mainnetChain);
        }}>
        <svelte:component this={mainnetChain.icon} /><span class="ml-2"
          >Add MXC Network</span>
      </button>
    </div>
  </div>
</Modal>
