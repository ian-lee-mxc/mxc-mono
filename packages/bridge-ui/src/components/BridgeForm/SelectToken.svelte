<script lang="ts">
  import { getProvider } from '@wagmi/core';
  import { Contract, ethers } from 'ethers';
  import { ChevronDown, PlusCircle } from 'svelte-heros-v2';

  import { erc20ABI } from '../../constants/abi';
  import type { HTMLBridgeForm } from '../../domain/dom';
  import type { Token } from '../../domain/token';
  import { tokenService } from '../../storage/services';
  import { destChain, srcChain } from '../../store/chain';
  import { signer } from '../../store/signer';
  import { token } from '../../store/token';
  import { userTokens } from '../../store/userToken';
  import { tokens } from '../../token/tokens';
  import { selectTokenAndBridgeType } from '../../utils/selectTokenAndBridgeType';
  import Erc20 from '../icons/ERC20.svelte';
  import { errorToast, successToast } from '../NotificationToast.svelte';
  import AddCustomErc20 from './AddCustomERC20.svelte';
  import { L1_CHAIN_ID } from '../../constants/envVars';

  let dropdownElement: HTMLDivElement;
  let showAddressField = false;
  let loading = false;

  // l1 => MXC is erc20
  const l1Token = tokens.filter((item) => {
    return !item.isChainToken;
  });
  // l2 => MXC is ethToken
  const l2Token = tokens.filter((item) => {
    return item.isChainToken && item.symbol == 'MXC' ? false : true;
  });

  function closeDropdown() {
    dropdownElement?.classList.remove('dropdown-open');
    if (document.activeElement instanceof HTMLElement) {
      document.activeElement.blur();
    }
  }

  function selectTokenAndCloseDropdown(selectedToken: Token) {
    selectTokenAndBridgeType(selectedToken);
    closeDropdown();
  }

  async function addERC20(event: SubmitEvent) {
    loading = true;

    try {
      const eventTarget = event.target as HTMLBridgeForm;
      const { customTokenAddress } = eventTarget;
      const tokenAddress = customTokenAddress.value;

      if (!ethers.utils.isAddress(tokenAddress)) {
        throw new Error('not a valid ERC20 address', { cause: tokenAddress });
      }

      const provider = getProvider();
      const contract = new Contract(tokenAddress, erc20ABI, provider);

      const userAddress = await $signer.getAddress();

      // This call makes sure the contract is a valid ERC20 contract,
      // otherwise it throws and gets caught informing the user
      // it's not a valid ERC20 address
      await contract.balanceOf(userAddress);

      const [tokenName, decimals, symbol] = await Promise.all([
        contract.name(),
        contract.decimals(),
        contract.symbol(),
      ]);

      const token = {
        name: tokenName,
        addresses: {
          [$srcChain.id]: tokenAddress,
          [$destChain.id]: '0x00',
        },
        decimals: decimals,
        symbol: symbol,
        logoComponent: null,
      } as Token;

      const updateTokensList = tokenService.storeToken(token, userAddress);

      selectTokenAndBridgeType(token);

      userTokens.set(updateTokensList);
      eventTarget.reset();

      showAddressField = false;

      successToast(`Token "${tokenName}" added successfully.`);
    } catch (error) {
      console.error(error);

      // TODO: what if something else happens within the try block?
      errorToast('Not a valid ERC20 address.');
    } finally {
      loading = false;
    }
  }
</script>

<div class="dropdown dropdown-bottom dropdown-end" bind:this={dropdownElement}>
  <!-- svelte-ignore a11y-label-has-associated-control -->
  <!-- svelte-ignore a11y-no-noninteractive-tabindex -->
  <label
    tabindex="0"
    class="flex items-center justify-center hover:cursor-pointer">
    <!-- {#if $token.logoComponent}
      <svelte:component this={$token.logoComponent} />
    {:else}
      <Erc20 />
    {/if}
    <p class="px-2 text-sm">{$token.symbol.toUpperCase()}</p>
    <ChevronDown size="20" /> -->
    {#if $token.logoUrl}
      <div class="flex pr-5">
        <img src={$token.logoUrl} height={22} width={22} alt="" />
        <p class="px-2 text-sm">{$token.symbol}</p>
      </div>
    {:else}
      <div class="flex">
        <svelte:component this={$token.logoComponent} height={22} width={22} />
        <p class="px-2 text-sm">{$token.symbol}</p>
      </div>
    {/if}
    <div>
      <ChevronDown size="20" />
    </div>
  </label>
  <!-- <label tabindex="0" class="btn m-1">Click</label> -->

  <ul
    role="listbox"
    tabindex="0"
    class="dropdown-content menu my-2 bg-dark-2 rounded-box p-2">
    <!-- {#each tokens as _token (_token.symbol)}
      <li>
        <button
          on:click={() => selectTokenAndCloseDropdown(_token)}
          class="flex items-center px-2 py-4 hover:bg-dark-5 rounded-sm">
          <svelte:component
            this={_token.logoComponent}
            height={22}
            width={22} />
          <span class="text-sm font-medium bg-transparent px-2">
            {_token.symbol.toUpperCase()}
          </span>
        </button>
      </li>
    {/each} -->
    {#if $srcChain && $srcChain.id == L1_CHAIN_ID}
      {#each l1Token as _token (_token.symbol)}
        <li>
          <button
            on:click={() => selectTokenAndCloseDropdown(_token)}
            class="flex items-center px-2 py-4 hover:bg-dark-5 rounded-sm">
            <!-- <svelte:component
              this={_token.logoComponent}
              height={22}
              width={22} /> -->
            {#if _token.logoUrl}
              <img src={_token.logoUrl} height={22} width={22} alt="" />
            {:else}
              <svelte:component
                this={_token.logoComponent}
                height={22}
                width={22} />
            {/if}
            <span class="text-sm font-medium bg-transparent px-2">
              {_token.symbol}
            </span>
          </button>
        </li>
      {/each}
    {:else}
      {#each l2Token as _token (_token.symbol)}
        <li>
          <button
            on:click={() => selectTokenAndCloseDropdown(_token)}
            class="flex items-center px-2 py-4 hover:bg-dark-5 rounded-sm">
            <!-- <svelte:component
              this={_token.logoComponent}
              height={22}
              width={22} /> -->
            {#if _token.logoUrl}
              <img src={_token.logoUrl} height={22} width={22} alt="" />
            {:else}
              <svelte:component
                this={_token.logoComponent}
                height={22}
                width={22} />
            {/if}

            <span class="text-sm font-medium bg-transparent px-2">
              {_token.symbol}
            </span>
          </button>
        </li>
      {/each}
    {/if}

    {#each $userTokens as _token (_token.symbol)}
      <li>
        <button
          on:click={() => selectTokenAndCloseDropdown(_token)}
          class="flex items-center px-2 py-4 hover:bg-dark-5 rounded-sm">
          <Erc20 height={22} width={22} />
          <span class="text-sm font-medium bg-transparent px-2"
            >{_token.symbol}</span>
        </button>
      </li>
    {/each}

    <li class="divider h-[1px] m-0" />

    <li>
      <button
        on:click={() => (showAddressField = true)}
        class="flex hover:bg-dark-5 justify-between items-center p-4 rounded-sm">
        <PlusCircle size="25" />
        <span
          class="
            text-sm
            font-medium
            bg-transparent
            flex-1
            w-[100px]
            px-0
            pl-2">
          Add Custom
        </span>
      </button>
    </li>
  </ul>

  {#if showAddressField}
    <AddCustomErc20 bind:showAddressField {addERC20} bind:loading />
  {/if}
</div>
