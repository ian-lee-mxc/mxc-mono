<script lang="ts">
  import { location } from 'svelte-spa-router';

  import BridgeForm from '../../components/BridgeForm';
  import SelectChain from '../../components/BridgeForm/SelectChain.svelte';
  import Faucet from '../../components/Faucet/Faucet.svelte';
  import Loading from '../../components/Loading.svelte';
  import { Tab, TabList, TabPanel, Tabs } from '../../components/Tabs';
  import Transactions from '../../components/Transactions';
  import { paginationInfo } from '../../store/relayerApi';
  import { srcChain } from '../../store/chain';
  import { signer } from '../../store/signer';
  import { transactions } from '../../store/transaction';
  import { L1_CHAIN_ID } from '../../constants/envVars';
  import Stake from '../../components/Stake/index.svelte';
  import { bridgeType } from '../../store/bridge';
  import { BridgeType } from '../../domain/bridge';

  import { ethers, Contract, type Signer, BigNumber } from 'ethers';
  import {
    L1MXCCROSSTOKEN,
    L1MXCTOKEN,
    ISTESTNET,
  } from '../../constants/envVars';
  import TooltipModal from '../../components/TooltipModal.svelte';
  import Button from '../../components/Button.svelte';
  import MXCCrossTokenAbi from '../../constants/abis/MXCCrossToken';
  import MXCTokenAbi from '../../constants/abis/MXCToken';
  import { LottiePlayer } from '@lottiefiles/svelte-lottie-player';

  import {
    pendingTransactions,
    transactions as transactionsStore,
  } from '../../store/transaction';
  import {
    errorToast,
    successToast,
    warningToast,
  } from '../../components/NotificationToast.svelte';

  import { _ } from 'svelte-i18n';
  import { get } from 'svelte/store';

  const isTestnet = ISTESTNET == '1';

  enum LogLevel {
    DEBUG = 'DEBUG',
    INFO = 'INFO',
    WARNING = 'WARNING',
    ERROR = 'ERROR',
    OFF = 'OFF',
  }
  ethers.utils.Logger.setLogLevel(LogLevel.OFF);

  const parseEther = ethers.utils.parseEther;
  const formatEther = ethers.utils.formatEther;

  let address: string = '';
  let tooltipOpen: boolean = false;
  let showClose: boolean = false;
  let mxcCrossVal: BigNumber = parseEther('0');
  let isApprove: boolean = false;
  let loadingClaim: boolean = false;
  let loadingApprove: boolean = false;

  async function approve() {
    loadingApprove = true;
    try {
      const MXCCrossToken = new Contract(
        L1MXCCROSSTOKEN,
        MXCCrossTokenAbi,
        $signer,
      );

      const tx = await MXCCrossToken.approve(L1MXCTOKEN, mxcCrossVal);

      successToast('Transaction sent to approve tokens transfer.');
      isApprove = false;
      await pendingTransactions.add(tx, $signer);
      successToast(`<strong>Tokens transfer approved!</strong><br />`);
    } catch (error) {
      console.error(error);
      isApprove = true;
      const headerError = '<strong>Failed to approve</strong><br />';
      if (error.cause?.status === 0) {
        console.log(111);
        const explorerUrl = `${$srcChain.explorerUrl}/tx/${error.cause.transactionHash}`;
        const htmlLink = `<a href="${explorerUrl}" target="_blank"><b><u>here</u></b></a>`;
        errorToast(
          `${headerError}Click ${htmlLink} to see more details on the explorer.`,
          true, // dismissible
        );
      } else if (
        [error.code, error.cause?.code].includes(ethers.errors.ACTION_REJECTED)
      ) {
        warningToast(`Transaction has been rejected.`);
      } else {
        errorToast(`${headerError}Try again later.`);
      }
    }
    loadingApprove = false;
  }

  async function claim() {
    loadingClaim = true;
    const MXCToken = new Contract(L1MXCTOKEN, MXCTokenAbi, $signer);
    try {
      const tx = await MXCToken.exchange(address, mxcCrossVal);

      successToast('Transaction sent to exchange tokens transfer.');
      await pendingTransactions.add(tx, $signer);
      successToast(`<strong>Tokens exchange completed!</strong><br />`);
      tooltipOpen = false;
    } catch (error) {
      console.error(error);
      const headerError = '<strong>Failed to exchange</strong><br />';
      if (error.cause?.status === 0) {
        const explorerUrl = `${$srcChain.explorerUrl}/tx/${error.cause.transactionHash}`;
        const htmlLink = `<a href="${explorerUrl}" target="_blank"><b><u>here</u></b></a>`;
        errorToast(
          `${headerError}Click ${htmlLink} to see more details on the explorer.`,
          true, // dismissible
        );
      } else if (
        [error.code, error.cause?.code].includes(ethers.errors.ACTION_REJECTED)
      ) {
        warningToast(`Transaction has been rejected.`);
      } else {
        errorToast(`${headerError}Try again later.`);
      }
    }
    loadingClaim = false;
  }

  async function checkMxcCross() {
    // console.log(L1MXCCROSSTOKEN,$signer)
    try {
      const MXCCrossToken = new Contract(
        L1MXCCROSSTOKEN,
        MXCCrossTokenAbi,
        $signer,
      );
      mxcCrossVal = await MXCCrossToken.balanceOf(address);
      let allowance = await MXCCrossToken.allowance(address, L1MXCTOKEN);
      if (mxcCrossVal.gt(0)) {
        tooltipOpen = true;
      } else {
        tooltipOpen = false;
      }
      if (mxcCrossVal.gt(allowance)) {
        isApprove = true;
      } else {
        isApprove = false;
      }
    } catch (e) {
      console.error(e);
    }
  }

  $: setAddress($signer).catch((e) => console.error(e));
  async function setAddress(signer: Signer) {
    try {
      address = await signer.getAddress();
      await checkMxcCross();
    } catch (error) {}
  }

  // List of tab's name <=> route association
  // TODO: add this into a general configuration.
  const tabsRoute = [
    { name: 'bridge', href: '/' },
    { name: 'transactions', href: '/transactions' },
    { name: 'faucet', href: '/faucet' },
    { name: 'stake', href: '/stake' },
  ]

  async function setBridge() {
    // in l1, set the BridgeType.ERC20
    bridgeType.set(BridgeType.ERC20);
  }

  $: activeTab =
    $location === '/' ? tabsRoute[0].name : $location.replace('/', '');

  $: if ($srcChain && $srcChain.id === L1_CHAIN_ID) {
    setBridge();
  }
</script>

<div class="container mx-auto text-center my-10">
  <Tabs
    class="
        tabs 
        md:bg-tabs 
        md:border-2 
        md:dark:border-1 
        md:border-gray-200 
        md:dark:border-gray-800 
        md:shadow-md 
        md:rounded-3xl 
        md:p-6 
        md:inline-block 
        md:min-h-[650px]
        p-2"
    bind:activeTab>
    
    {@const tab1 = tabsRoute[0]}
    {@const tab2 = tabsRoute[1]}
    {@const tab3 = tabsRoute[2]}
    {@const tab4 = tabsRoute[3]}

    <TabList class="block mb-4 w-full">
      <Tab name={tab1.name} href={tab1.href}>Bridge</Tab>
      <Tab name={tab2.name} href={tab2.href}>
        <span>Transactions</span>
        {#if $paginationInfo || !$signer}
          ({$transactions.length})
        {:else}
          (<Loading />)
        {/if}
      </Tab>
      {#if isTestnet}
        <Tab name={tab3.name} href={tab3.href}>Faucet</Tab>
      {/if}
      {#if $srcChain && $srcChain.id == L1_CHAIN_ID}
        <Tab name={tab4.name} href={tab4.href}>Stake</Tab>
      {/if}
    </TabList>

    <TabPanel tab={tab1.name}>
      <div class="rounded-lg py-4 flex flex-col items-center justify-center">
        <SelectChain />
      </div>
      <div class="md:w-[440px] px-4 flex flex-col items-center justify-center">
        <BridgeForm />
      </div>
    </TabPanel>

    <TabPanel tab={tab2.name}>
      <div class="md:min-w-[440px]">
        <Transactions />
      </div>
    </TabPanel>

    <TabPanel tab={tab3.name}>
      <div class="md:w-[440px] px-4 flex flex-col items-center justify-center">
        <Faucet />
      </div>
    </TabPanel>

    <TabPanel tab={tab4.name}>
      <Stake />
    </TabPanel>
  </Tabs>

  <TooltipModal
    title="Warning"
    bind:isOpen={tooltipOpen}
    bind:showXButton={showClose}>
    <span slot="body">
      <p class="text-left">
        The current bridge is incompatible with L1 MXC. Please click "Claim" to
        transform your L1 MXC into the latest version of L2 MXC, which will then
        allow you to seamlessly bridge to L3 zkEVM.
      </p>
      {#if loadingApprove}
        <Button type="accent" size="lg" class="w-4/12 mr-3" disabled={true}>
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
          class="w-4/12 mr-3"
          disabled={!isApprove}
          on:click={approve}>
          Approve
        </Button>
      {/if}

      {#if loadingClaim}
        <Button type="accent" size="lg" class="w-4/12 mr-3" disabled={true}>
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
          class="w-4/12"
          disabled={isApprove}
          on:click={claim}>
          Claim
        </Button>
      {/if}
    </span>
  </TooltipModal>
</div>
