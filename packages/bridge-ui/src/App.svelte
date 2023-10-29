<script lang="ts">
import { onDestroy, onMount } from 'svelte';

import Navbar from './components/Navbar.svelte';
import NotificationToast from './components/NotificationToast.svelte';
import Router from './components/Router.svelte';
import SwitchChainModal from './components/SwitchChainModal.svelte';
import { startWatching, stopWatching } from './wagmi/watcher';
import LanguageDialog from './components/LanguageModal.svelte';

import { isLanguageModalOpen } from './store/modalLanguage';

  onMount(startWatching);
  onDestroy(stopWatching);
</script>

<main>
  <Navbar />
  <Router />
  {#if $isLanguageModalOpen}
  <LanguageDialog />
  {/if}
  
</main>

<NotificationToast />
<SwitchChainModal />
