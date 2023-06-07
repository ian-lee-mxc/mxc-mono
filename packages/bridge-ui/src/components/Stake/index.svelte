<script lang="ts">
	import { _ } from 'svelte-i18n';
	import { onMount } from 'svelte';
	import { LottiePlayer } from '@lottiefiles/svelte-lottie-player';
    import { errorToast, successToast } from '../NotificationToast.svelte';
    import Button from '../Button.svelte';
	import { signer } from '../../store/signer';
  	import { BigNumber, Contract, ethers, Signer } from 'ethers';
    import { srcChain } from '../../store/chain';
	import { L1_CROSS_CHAIN_SYNC_ADDRESS, TEST_ERC20 } from '../../constants/envVars';
	import { truncateString } from '../../utils/truncateString';
	import MXCL1_ABI from '../../constants/abis/MXCL1';
	import {erc20ABI} from '../../constants/abi/';
	import { L1_CHAIN_ID } from '../../constants/envVars';
	import type { Chain } from '../../domain/chain';
	// import { format } from 'prettier';
	import { formatEther } from 'ethers/lib/utils.js';
	import {
		pendingTransactions,
		// transactioner,
		transactions as transactionsStore,
	} from '../../store/transaction';

	const parseEther = ethers.utils.parseEther
	const mxcAddr = TEST_ERC20.filter(item=>item.symbol=="MXC")[0].address
	let amountInput: HTMLInputElement;
	let stakeBalance: string;
	let tokenBalance: string;
	let amount: string;
	let loading: boolean = false;
	let btnDisabled: boolean = true;
	let requiresAllowance: boolean = false;

	async function getUserStack(
		signer: ethers.Signer,
		srcChain: Chain,
	) {
		if (signer && srcChain && srcChain.id==L1_CHAIN_ID) {
			let _addr = await signer.getAddress()
			// const addr = await addrForToken();
			if (_addr == ethers.constants.AddressZero) {
				stakeBalance = '0';
				return;
			}
			const contract = new Contract(L1_CROSS_CHAIN_SYNC_ADDRESS, MXCL1_ABI, signer);
			// const userBalance = await contract.getStakeAmount();
            let addr = await signer.getAddress()
			const userBalance = await contract.getMxcTokenBalance(addr);
			stakeBalance = ethers.utils.formatUnits(userBalance, 18);
		}
	}

	async function getUserBalance(
		signer: ethers.Signer,
		srcChain: Chain,
	) {
		if (signer && srcChain && srcChain.id==L1_CHAIN_ID) {
			let _addr = await signer.getAddress()
			if (_addr == ethers.constants.AddressZero) {
				tokenBalance = '0';
				return;
			}
			const contract = new Contract(mxcAddr, erc20ABI, signer);
			const userBalance = await contract.balanceOf(await signer.getAddress());
			tokenBalance = ethers.utils.formatUnits(userBalance, 18);
		}
	}

	async function checkAllowance(
		amt: string,
		srcChain: Chain,
		signer: Signer,
	) {
		if (!srcChain || !amt || !signer) return false;

		let signer_addr = await signer.getAddress()
		const mxcToken = new Contract(mxcAddr, erc20ABI, signer);
		let allowance = await mxcToken.allowance(signer_addr, L1_CROSS_CHAIN_SYNC_ADDRESS)
		// console.log(parseFloat(amt) >= parseFloat(formatEther(allowance)))
		// need allowance return true, 
		return parseFloat(amt) > parseFloat(formatEther(allowance));
	}

	async function approve() {
		try {
			loading = true;
			const mxcToken = new Contract(mxcAddr, erc20ABI, $signer);
			await mxcToken.approve(L1_CROSS_CHAIN_SYNC_ADDRESS, parseEther(amount));

			requiresAllowance = false;
		} catch (e) {
			console.error(e);
			errorToast($_('toast.errorSendingTransaction'));
		} finally {
			loading = false;
		}
	}

	async function stake() {
		try {
			const mxcL1 = new Contract(L1_CROSS_CHAIN_SYNC_ADDRESS, MXCL1_ABI, $signer);
			let mockData = await mxcL1.callStatic.depositMxcToken(parseEther(amount))
			if(!mockData) {
				errorToast($_('toast.errorSendingTransaction'));
			}

			console.log("success")

			// const tx = await mxcL1.stake(parseEther(amount))
			// pendingTransactions.add(tx, $signer);

			// successToast($_('toast.transactionSent'));
			// amountInput.value = ""
			// await $signer.provider.waitForTransaction(tx.hash, 1);

			// await getUserStack($signer, $srcChain)
			// await getUserBalance($signer, $srcChain)

		} catch (e) {
			console.error(e);
			errorToast($_('toast.errorSendingTransaction'));
		} finally {
			loading = false;
		}
	}

	$: getUserStack($signer, $srcChain);
	$: getUserBalance($signer, $srcChain);
	$: isBtnDisabled(
		$signer,
		amount,
		tokenBalance,
		$srcChain,
	)
    .then((d) => (btnDisabled = d))
    .catch((e) => console.error(e));

	$: checkAllowance(amount, $srcChain, $signer)
    .then((a) => (requiresAllowance = a))
    .catch((e) => console.error(e));

	async function isBtnDisabled(
		signer: Signer,
		amount: string,
		tokenBalance: string,
		srcChain: Chain,
	) {
		if (!signer) return true;
		if (!tokenBalance) return true;
		if (!srcChain) return true;
		const chainId = srcChain.id;
		if (!chainId || chainId!==L1_CHAIN_ID) return true;

		if (!amount || ethers.utils.parseUnits(amount).eq(BigNumber.from(0)))
			return true;
		
		if (parseFloat(amount)<5000) return true;

		if (isNaN(parseFloat(amount))) return true;
		if (
			BigNumber.from(ethers.utils.parseUnits(tokenBalance, 18)).lt(
				ethers.utils.parseUnits(amount, 18),
			)
		) return true;

		return false;
	}

	function updateAmount(e: any) {
		amount = (e.target.value as number).toString();
	}
	
</script>

<div class="my-4 md:px-4">
	
	<div class="form-control my-4 md:my-8">
		<!-- svelte-ignore a11y-label-has-associated-control -->
		<label class="label text-left label-text">
			{$_('bridgeForm.balance')}:
			{tokenBalance || 0}
			MXC
		</label>

		<label class="label" for="amount">
		  <span class="label-text">{$_('bridgeForm.fieldLabel')}</span>
	  
		  	{#if $signer && stakeBalance}
				<div class="label-text ">
				<span>
					Staked:
					{stakeBalance.length > 10
						? `${truncateString(stakeBalance, 6)}...`
						: stakeBalance}
					MXC
				</span>
				</div>
			{/if}
		</label>
	  
		<label
		  class="input-group relative rounded-lg bg-dark-2 justify-between items-center pr-4">
		  <input
			type="number"
			placeholder="6000000"
			min="0"
			on:input={updateAmount}
			class="input input-primary bg-dark-2 input-md md:input-lg w-full focus:ring-0 border-dark-2"
			name="amount"
			bind:this={amountInput} />
		</label>
		<!-- svelte-ignore a11y-label-has-associated-control -->
		<label class="label label-text text-left">At least stake 6000,000 MXC</label>
	</div>
	
	{#if loading}
		<Button type="accent" size="lg" class="w-full" disabled={true}>
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
	{:else if !requiresAllowance}
		<Button
		  type="accent"
		  size="lg"
		  class="w-full"
		  on:click={stake}
		  disabled={btnDisabled}>
		  Stake
		</Button>
	{:else}
		<Button
			type="accent"
			class="w-full"
			on:click={approve}
			disabled={btnDisabled}>
			{$_('home.approve')}
		</Button>
	{/if}
</div>
  