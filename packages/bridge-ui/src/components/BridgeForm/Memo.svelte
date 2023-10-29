<script lang="ts">
  import ButtonWithTooltip from '../ButtonWithTooltip.svelte';
  import TooltipModal from '../TooltipModal.svelte';
  import { get } from 'svelte/store';
  import { _ } from 'svelte-i18n';

  export let memo: string = '';
  export let error: string = '';
  export let show: boolean = false;

  let tooltipOpen: boolean = false;

  function checkSizeLimit(input: string) {
    const bytes = new TextEncoder().encode(input).length;
    if (bytes > 128) {
      error = get(_)('bridgeForm.mxcLimit')
    } else {
      error = null;
    }
  }

  $: checkSizeLimit(memo);
</script>

<div class="label flex flex-row justify-between items-center">
  <label for="memo">
    <ButtonWithTooltip onClick={() => (tooltipOpen = true)}>
      <span slot="buttonText">{$_('bridgeForm.memo')}</span>
    </ButtonWithTooltip>
  </label>

  <input
    id="memo"
    type="checkbox"
    class="toggle rounded-full duration-300"
    on:click={() => {
      show = !show;
    }}
    bind:checked={show} />
</div>

{#if show}
  <div class="form-control">
    <input
      type="text"
      placeholder={$_('bridgeForm.enterMemo')}
      class="input input-primary bg-dark-2 input-md md:input-lg w-full focus:ring-0 border-dark-2 rounded-md"
      name="memo"
      bind:value={memo} />

    {#if error}
      <label class="label min-h-[20px] mb-0 p-0" for="name">
        <span class="label-text-alt text-error text-sm">⚠ {error}</span>
      </label>
    {/if}
  </div>
{/if}

<TooltipModal title="Memo" bind:isOpen={tooltipOpen}>
  <span slot="body">
    <p class="text-left">
      {$_('bridgeForm.memoDesc')}
    </p>
  </span>
</TooltipModal>
