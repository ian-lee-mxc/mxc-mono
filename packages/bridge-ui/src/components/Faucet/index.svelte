<script lang="ts">
  import { onMount } from 'svelte';
  import { LottiePlayer } from '@lottiefiles/svelte-lottie-player';
  import { signer } from '../../store/signer';
  import { errorToast, successToast } from '../Toast.svelte';
  import type { Signer } from 'ethers';
  import axios from 'axios';
  import Button from '../buttons/Button.svelte';

  let address: string = '';
  let mxcDisabled: boolean = false;
  let moonDisabled: boolean = false;
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

    let res =  await getMXCTokenApi(address);
    if(res.status==200) {
      successToast("request successful!");
    } else {
      errorToast("request fail!");
    }
    loading = false
  }

  async function getMoonToken() {
    loading2 = true;

    let res =  await getMoonTokenApi(address);
    if(res.status==200) {
      successToast("request successful!");
    } else {
      errorToast("request fail!");
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
  <div class="max-w-lg mx-auto mb-5">
    <label class="label" for="address">
      <span class="label-text">Address</span>
    </label>
    <!-- svelte-ignore a11y-label-has-associated-control -->
    <label
      class="input-group relative rounded-lg bg-dark-2 justify-between items-center pr-4">
      <div class="text-sm">{address}</div>
    </label>
  </div>
  <div>
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
      disabled={mxcDisabled}
      on:click={getMxcToken}>
      Claim 100 MXC
    </Button>
    {/if}
    
    <div class="mb-5 text-sm">Note: Restrict one address to once a day</div>
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
      disable={moonDisabled}
      on:click={getMoonToken}>
      Claim 1 Moon token
    </Button>
    {/if}
    <div class="mb-5 text-sm">Note: Restrict one address get it once</div>
  </div>
</div>
