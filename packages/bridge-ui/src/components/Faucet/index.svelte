<script lang="ts">
  import { onMount } from 'svelte';
  import { LottiePlayer } from '@lottiefiles/svelte-lottie-player';
  import { signer } from '../../store/signer';
  import { errorToast, successToast } from '../Toast.svelte';
  import type { Signer } from 'ethers';
  import axios from 'axios';
  import Button from '../buttons/Button.svelte';

  let address: string = '';
  let loading: boolean = false;
  let loading2: boolean = false;

  const getMXCTokenApi = async (address:string) => {
    const response = await axios.get(`/api/faucet/mxc/${address}`);
    return response.data;
  };

  const getMoonTokenApi = async (address:string) => {
    const response = await axios.get(`/api/faucet/moon/${address}`);
    return response.data;
  };

  $: setAddress($signer).catch((e) => console.error(e));
  async function setAddress(signer: Signer) {
    try {
      address = await signer.getAddress();
    } catch (error) {
      
    }
  }

  async function getMxcToken() {
    loading = true;

    if(!address) {
      errorToast("No address account!");
      return
    }

    let res =  await getMXCTokenApi(address);
    if(res.status==200) {
      successToast("Request successful!");
    } else {
      errorToast("Request failed!");
    }
    loading = false
  }

  async function getMoonToken() {
    loading2 = true;

    if(!address) {
      errorToast("No address account!");
      return
    }

    let res =  await getMoonTokenApi(address);
    if(res.status==200) {
      successToast("Request successful!");
    } else {
      errorToast("Request failed!");
    }
    loading2 = false
  }

  onMount(async() => {
    (async () => {
      await setAddress($signer);
    })();
  });
</script>

<div class="my-4 md:px-4">
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
      Claim 100 MXC
    </Button>
    {/if}
    
    <p class="mb-5 mt-1 text-sm">Limit the use of a single address to once per day.</p>
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
    <p class="mt-1 text-sm">Limit the token redemption to a single occurrence </p>
    <p class="text-sm">for a specific wallet address.</p>
  </div>
</div>
