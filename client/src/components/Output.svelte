<script lang="ts">
  import { Plane } from 'svelte-loading-spinners'
  import { fade, scale } from 'svelte/transition'

  export let output: string = ''
  export let compiling = false
</script>

<div class="output">
  <div class="heading">
    <div>Output:</div>
    <div>=======</div>
  </div>
  <br />
  <pre>{output}</pre>
  <div class="hint">F5 or ctrl+enter to run</div>
  {#if compiling}
    <div class="spinner" in:fade out:fade>
      <div in:scale out:scale>
        <Plane color="#4bb4e3" />
      </div>
    </div>
  {/if}
</div>

<style>
  .spinner {
    align-items: center;
    display: flex;
    height: 100%;
    justify-content: center;
    width: 100%;
    position: absolute;
    top: 0;
    left: 0;
    background: rgba(0, 0, 0, 0.5);
  }

  .output {
    box-sizing: border-box;
    color: #d4d4d4;
    font-size: 14px;
    height: 100%;
    overflow-y: scroll;
    padding: 12px 24px;
    position: relative;
  }

  .output,
  pre {
    font-family: Menlo, Monaco, 'Courier New', monospace;
  }

  .hint {
    background: #111;
    border-radius: 4px;
    bottom: 12px;
    padding: 4px 8px;
    pointer-events: none;
    position: absolute;
    right: 12px;
    transition: 0.1s all;
  }

  .output:hover .hint {
    opacity: 0;
  }
</style>
