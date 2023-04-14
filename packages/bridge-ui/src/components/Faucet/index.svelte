<script lang="ts">
  import { onMount } from 'svelte';
  import { LottiePlayer } from '@lottiefiles/svelte-lottie-player';
  import { signer } from '../../store/signer';
  import { errorToast, successToast } from '../Toast.svelte';
  import type { Signer } from 'ethers';
  import axios from 'axios';
  import Button from '../buttons/Button.svelte';
  import { SITE_KEY  } from '../../constants/envVars';
  import { L1_CHAIN_ID, L2_CHAIN_ID } from '../../constants/envVars';
  import { fromChain } from '../../store/chain';
  import { formatEther } from 'ethers/lib/utils.js';


  let address: string = '';
  let loading: boolean = false;
  let loading2: boolean = false;
  let loading3: boolean = false;
  let allowCaptcha: boolean = false;
  let isFaucetEth: boolean = true;
  let capToken: string;

  const getMXCTokenApi = async (address:string) => {
    const response = await axios.get(`/api/faucet/mxc/${address}`);
    return response.data;
  };

  const getMoonTokenApi = async (address:string) => {
    const response = await axios.get(`/api/faucet/moon/${address}`);
    return response.data;
  };

  const getEthApi = async (address:string) => {
    const response = await axios.post(`/api/faucet/arbgoerli`,{address, token: capToken});
    return response.data;
  };

  const recaptchaApi = async (token:string) => {
    const response = await axios.post(`/api/recaptcha`,{token});
    return response.data;
  };


  $: setAddress($signer).catch((e) => console.error(e));
  async function setAddress(signer: Signer) {
    try {
      address = await signer.getAddress();
    } catch (error) {
      
    }
  }

  async function getEth() {
    loading3 = true;
    if(!address) {
      errorToast("No address account!");
      return
    }
    let res =  await getEthApi(address);
    if(res.status==200) {
      successToast("Request successful!");
    } else {
      errorToast(res.msg);
    }
    isFaucetEth = false
    loading3 = false
    if((window as any).grecaptcha) {
      (window as any).grecaptcha.reset()
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

  function getCaptcha() {
    setTimeout(() => {
      if(!(window as any).grecaptcha) {
        getCaptcha()
      } else {
        try{
          (window as any).grecaptcha.render("grecaptcha", {
            sitekey: SITE_KEY,
            callback: async(token)=>{
              let res = await recaptchaApi(token)
              if(res.data.success) {
                allowCaptcha = true
                capToken = res.data.token || ""
              } else {
                allowCaptcha = false
              }
            }
          });
        }catch(error){}
      }
    }, 1000);
  }

  $: if ($fromChain && $fromChain.id === L1_CHAIN_ID) {
    getCaptcha()
  }

  onMount(async() => {
    (async () => {
      await setAddress($signer);
      getCaptcha()
    })();
  });
</script>

<div class="my-4 md:px-4">
  {#if $fromChain && $fromChain.id==L1_CHAIN_ID}
    {#if loading3}
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
        disabled={!allowCaptcha || !isFaucetEth}
        on:click={getEth}>
        Claim 0.02 ETH
      </Button>
    {/if}
    <p class="mt-1 text-sm">The arbitrue-goerli eth can be received only once </p>
    <p class="text-sm">by an address account in the Wannsee network.</p>
    <div class="mt-4 flex justify-center" id="grecaptcha"></div>
  {:else}
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
  {/if}
</div>
