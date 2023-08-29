<script lang="ts">
  import { BigNumber, ethers, type Signer } from 'ethers';
  import { ArrowRight } from 'svelte-heros-v2';

  import type { Chain } from '../../domain/chain';
  import type { Token } from '../../domain/token';
  import { srcChain } from '../../store/chain';
  import { signer } from '../../store/signer';
  import { isERC20 } from '../../token/tokens';
  import Button from '../Button.svelte';
  import Loading from '../Loading.svelte';
  import { L1_CHAIN_ID } from '../../constants/envVars';
  import { _ } from 'svelte-i18n';
  import { get } from 'svelte/store';

  export let token: Token;

  export let requiresAllowance = false;

  export let requiresAllowanceMxc = false;
  export let computingAllowance = false;

  export let tokenBalance: string = '';
  export let computingTokenBalance = false;

  export let actionDisabled = false;

  export let amountEntered = false;

  export let approve: (token: Token, isMxc: boolean = false) => Promise<void>;
  export let bridge: (token: Token) => Promise<void>;

  /* 
  remove button type="accent"
  */

  let approving = false;
  let bridging = false;

  function hasBalance(token: Token, tokenBalance: string) {
    return (
      tokenBalance &&
      ethers.utils
        .parseUnits(tokenBalance, token.decimals)
        .gt(BigNumber.from(0))
    );
  }

  function shouldShowSteps(
    token: Token,
    signer: Signer,
    srcChain: Chain,
    tokenBalance: string,
    computingTokenBalance: boolean,
  ) {
    return (
      !computingTokenBalance &&
      srcChain && // chain selected?
      signer && // wallet connected?
      token && // token selected?
      (isERC20(token) || (!isERC20(token) && srcChain.id == L1_CHAIN_ID)) &&
      hasBalance(token, tokenBalance)
    );
  }

  function clickApprove() {
    approving = true;
    approve(token).finally(() => {
      approving = false;
    });
  }

  function clickApproveMxc() {
    approving = true;
    approve(token, true).finally(() => {
      approving = false;
    });
  }

  function clickBridge() {
    bridging = true;
    bridge(token).finally(() => {
      bridging = false;
    });
  }

  $: showSteps = shouldShowSteps(
    token,
    $signer,
    $srcChain,
    tokenBalance,
    computingTokenBalance,
  );

  $: loading = approving || bridging;
</script>

{#if showSteps}
  <div class="flex space-x-4 items-center">
    {#if loading}
      <Button class="action-button flex-1" disabled={true}>
        {#if approving}
          <Loading text={$_("bridgeForm.approving")} />
        {:else}
          ✓ {$_('bridgeForm.approved')}
        {/if}
      </Button>
      <ArrowRight />
      <Button class="action-button flex-1" disabled={true}>
        {#if bridging}
          <Loading text={$_('bridgeForm.bridging')}  />
        {:else}
          {$_('bridgeForm.bridge')}
        {/if}
      </Button>
    {:else}
      <Button class="action-button flex-1"
        on:click={clickApprove}
        disabled={!requiresAllowance || actionDisabled}>
        {requiresAllowance
          ? get(_)('bridgeForm.approveToken')
          : !computingAllowance && amountEntered
          ? `✓ ${get(_)('bridgeForm.approved')}`
          : get(_)('bridgeForm.approve')}
      </Button>
      <ArrowRight />
      {#if requiresAllowanceMxc}
        <Button class="action-button flex-1"
                on:click={clickApproveMxc}
                disabled={!requiresAllowanceMxc || actionDisabled}>
          {requiresAllowanceMxc
                  ? `${get(_)('bridgeForm.approve')} MXC`
                  : !computingAllowance && amountEntered
                          ? `✓ ${get(_)('bridgeForm.approved')}} MXC`
                          : `${get(_)('bridgeForm.approve')} MXC`}
        </Button>
        <ArrowRight />
      {/if}
      <Button
        class="action-button flex-1"
        on:click={clickBridge}
        disabled={requiresAllowance || actionDisabled}>
        {$_('bridgeForm.bridge')}
      </Button>
    {/if}
  </div>
{:else if bridging}
  <Button class="action-button w-full" disabled={true}>
    <Loading text={$_('bridgeForm.bridging')} />
  </Button>
{:else}
  <Button
    class="action-button w-full"
    on:click={clickBridge}
    disabled={actionDisabled}>
    {$_('bridgeForm.bridge')}
  </Button>
{/if}
