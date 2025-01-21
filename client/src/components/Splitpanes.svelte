<script lang="ts">
  import { Splitpanes } from 'svelte-splitpanes'
</script>

<div class="split">
  <Splitpanes on:resize theme="">
    <slot />
  </Splitpanes>
</div>

<style>
  .split {
    width: 100%;
  }

  .split :global(.splitpanes__pane) {
    background-color: inherit;
  }

  .split :global(.splitpanes__splitter) {
    background-color: #333;
    border-left: none;
    width: 5px;
    position: relative;
  }

  .split :global(.splitpanes__splitter)::after {
    background-color: #666;
    content: '';
    height: 30px;
    left: 2px;
    left: 50%;
    margin-left: 2px;
    margin: 0;
    position: absolute;
    top: 50%;
    transform: translateY(-50%);
    transition: background-color 0.3s;
    width: 1px;
  }

  .split :global(.splitpanes__splitter:hover) {
    background-color: #444;
  }

  .split :global(.splitpanes__splitter:hover:after) {
    background-color: #666;
  }

  .split :global(.splitpanes__splitter:before) {
    display: none;
  }

  .split :global(.splitpanes__splitter:after) {
    background-color: #666;
    left: 2px;
    margin: 0;
  }
</style>
