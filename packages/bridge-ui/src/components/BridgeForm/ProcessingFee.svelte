<script lang="ts">
  import { _ } from 'svelte-i18n';

  import { ProcessingFeeMethod } from '../../domain/fee';
  import { processingFees } from '../../fee/processingFees';
  import { destChain, srcChain } from '../../store/chain';
  import { signer } from '../../store/signer';
  import { token } from '../../store/token';
  import { recommendProcessingFee } from '../../utils/recommendProcessingFee';
  import ButtonWithTooltip from '../ButtonWithTooltip.svelte';
  import NoticeModal from '../NoticeModal.svelte';
  import GeneralTooltip from './ProcessingFeeTooltip.svelte';
  import {createEventDispatcher} from "svelte";

  const dispatch = createEventDispatcher();


  // export let method: ProcessingFeeMethod = ProcessingFeeMethod.RECOMMENDED;
  export let method: ProcessingFeeMethod = ProcessingFeeMethod.RECOMMENDED;
  export let amount: string = '0';

  let showProcessingFeeTooltip: boolean = false;
  let showNoneFeeTooltip: boolean = false;
  let cannotCompute = false;

  export let show: boolean = true;

  $: recommendProcessingFee($destChain, $srcChain, method, $token, $signer)
    .then((recommendedFee) => {
      amount = recommendedFee;
      cannotCompute = false;
    })
    .catch((error) => {
      console.error(error);

      amount = '0';
      cannotCompute = true;
    });

  function updateAmount(event: Event) {
    const target = event.target as HTMLInputElement;
    amount = target.value.toString();
    dispatch('updateAmount');
  }

  function focus(input: HTMLInputElement) {
    input.select();
  }

  function selectFee(selectedMethod: ProcessingFeeMethod) {
    return () => {
      method = selectedMethod;
      if (selectedMethod === ProcessingFeeMethod.NONE) {
        showNoneFeeTooltip = true;
      }
    };
  }
</script>

<div class="label flex flex-row justify-between items-center">
  <div class="py-0 flex flex-row justify-between">
    <ButtonWithTooltip onClick={() => (showProcessingFeeTooltip = true)}>
      <span slot="buttonText">{$_('bridgeForm.processingFeeLabel')}</span>
    </ButtonWithTooltip>
  </div>

  <input
    id="to-address"
    type="checkbox"
    class="toggle rounded-full duration-300"
    on:click={() => {
      show = !show;
    }}
    bind:checked={show} />
</div>



<!-- 
    TODO: how about showing recommended also in a readonly input
          and when clicking on Custom it becomes editable?
    
    TODO: transition between options
   -->
{#if show}
  {#if method === ProcessingFeeMethod.CUSTOM}
    <label class="mt-2 input-group relative">
      <input
        use:focus
        type="number"
        step="0.01"
        placeholder="0.01"
        min="0"
        on:input={updateAmount}
        class="input input-primary bg-dark-2 border-dark-2 input-md md:input-lg w-full focus:ring-0 !rounded-r-none"
        name="amount" />
      <!-- <span class="!rounded-r-lg bg-dark-2">ETH</span> -->
      <span class="!rounded-r-lg bg-dark-2">MXC</span>

    </label>
  {:else if method === ProcessingFeeMethod.RECOMMENDED}
    <div class="px-1 py-0 flex flex-row">
      <span class="mt-2 text-sm">
        {#if cannotCompute}
          <span class="text-error">⚠ {$_('bridgeForm.errorComp')}</span>
        {:else}
          <!-- {amount} ETH -->
          {amount}
          MXC
        {/if}
      </span>
    </div>
  {/if}

  <div class="flex mt-2 space-x-2">
    {#each Array.from(processingFees) as fee}
      {@const [feeMethod, { displayText }] = fee}
      {@const selected = method === feeMethod}

      <button
        class="{selected
          ? 'border-accent hover:border-accent'
          : ''} btn text-xs font-semibold flex-1 dark:bg-dark-5"
        on:click={selectFee(feeMethod)}>{displayText}</button>
    {/each}
  </div>
{/if}

<GeneralTooltip bind:show={showProcessingFeeTooltip} />

<NoticeModal bind:show={showNoneFeeTooltip} name="NoneFeeTooltip">
  <!-- TODO: translations? -->
  <div class="text-center">
    {@html $_('bridgeForm.selectNoneDesc')}
  </div>
</NoticeModal>
