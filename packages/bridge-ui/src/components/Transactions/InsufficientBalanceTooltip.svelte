<script lang="ts">
  import TooltipModal from '../modals/TooltipModal.svelte';

  export let show: boolean;
</script>

<TooltipModal title="Get MXC from Faucet" bind:isOpen={show}>
  <span slot="body">
    <div class="text-left">
      <strong>
        Please get MXC from Faucet.
      </strong>

      You will need MXC to pay for Gas fee.
    </div>
  </span>
</TooltipModal>
