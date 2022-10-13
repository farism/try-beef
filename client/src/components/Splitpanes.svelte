<script lang="ts">
  import { Splitpanes } from 'svelte-splitpanes'
</script>

<div class="split">
  <Splitpanes on:resize>
    <slot />
  </Splitpanes>
</div>

<style>
  .split {
    width: 100%;
  }

  .split :global(.splitpanes__pane) {
    background: inherit;
  }

  .split :global(.splitpanes__splitter) {
    background: #333;
    border-left: none;
    width: 5px;
  }

  .split :global(.splitpanes__splitter:hover) {
    background: #444;
  }

  .split :global(.splitpanes__splitter:hover:after) {
    background: #666;
  }

  .split :global(.splitpanes__splitter:before) {
    display: none;
  }

  .split :global(.splitpanes__splitter:after) {
    background: #666;
    left: 2px;
    margin: 0;
  }
</style>
