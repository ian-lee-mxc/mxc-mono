<script lang="ts">
  // import { fly } from 'svelte/transition';
  // import { Moon, Sun } from 'svelte-heros-v2';

  import { signer } from '../store/signer';
  import AddressDropdown from './AddressDropdown.svelte';
  import ChainDropdown from './ChainDropdown.svelte';
  import ConnectWallet from './ConnectWallet.svelte';
  // import TaikoLight from './icons/TaikoLight.svelte';
  // import TaikoLogo from './icons/TaikoLogo.svelte';
  // import Tko from './icons/TKO.svelte';

  import Logo from '../assets/mxc-logo.svg'
  import iconLocales from '../assets/locales.svg'

  import { isLanguageModalOpen } from '../store/modalLanguage';


  // let isDarkMode = localStorage.getItem('theme') === 'dark';

  // function switchToLightMode() {
  //   if (!document) {
  //     return;
  //   }
  //   document.documentElement.setAttribute('data-theme', 'light');
  //   localStorage.setItem('theme', 'light');
  //   isDarkMode = false;
  // }

  // function switchToDarkMode() {
  //   if (!document) {
  //     return;
  //   }
  //   document.documentElement.setAttribute('data-theme', 'dark');
  //   localStorage.setItem('theme', 'dark');
  //   isDarkMode = true;
  // }

  function toggleDialog() {
    isLanguageModalOpen.update(value => !value);
  }
</script>
<!-- bg-base-100 -->
<div class="navbar md:px-6">
  <div class="flex-1 items-end">
    <span class="taiko-light-logo">
      <!-- <TaikoLight width={120} /> -->
      <img src="{Logo}"  width={120}  alt="">
    </span>
    <span class="taiko-logo">
      <!-- <TaikoLogo width={120} /> -->
      <img src="{Logo}"  width={120}  alt="">
    </span>
    <span class="md:hidden">
      <!-- <Tko width={50} /> -->
      <img src="{Logo}" width="50"  alt="">
    </span>
    <!-- <a
      class="
        hidden 
        text-sm 
        leading-none
        md:inline-block 
        md:pl-4 
        md:font-medium 
        md:text-lg 
        hover:text-[#E81899]
      "
      href="https://taiko.xyz/docs/guides/use-the-bridge"
      target="_blank"
      rel="noreferrer">Guide ↗</a> -->
      <a
      class="
        hidden 
        text-sm 
        leading-none
        md:inline-block 
        md:pl-4 
        md:font-medium 
        md:text-lg 
        hover:text-[#E81899]
        pb-2
      "
      href="https://wannsee.mxc.com/docs/Tutorials/use-the-bridge"
      target="_blank"
      rel="noreferrer">Guide ↗</a>
  </div>
  <div class="flex-none">
    {#if $signer}
      <ChainDropdown />
      <AddressDropdown />
    {:else}
      <ConnectWallet />
    {/if}

    <div class="ml-2">
      <!-- svelte-ignore a11y-click-events-have-key-events -->
      <div class="localicon csp" on:click={toggleDialog}>
        <img src={iconLocales} alt="" />
      </div>
      <!-- {#if isDarkMode}
        <button in:fly={{ y: 10, duration: 500 }} class="btn btn-sm btn-circle">
          <Moon on:click={switchToLightMode} />
        </button>
      {:else}
        <button
          in:fly={{ y: 10, duration: 500 }}
          class="btn btn-sm btn-circle bg-base-100 hover:bg-base-100 text-neutral border-none">
          <Sun on:click={switchToDarkMode} class="text-gray-800" />
        </button>
      {/if} -->
    </div>
  </div>
</div>
