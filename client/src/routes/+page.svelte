<script lang="ts">
  import type monaco from 'monaco-editor'
  import { Pane } from 'svelte-splitpanes'
  import Editor from '../components/Editor.svelte'
  import Output from '../components/Output.svelte'
  import Splitpanes from '../components/Splitpanes.svelte'

  let editor: monaco.editor.IStandaloneCodeEditor
  let output = 'Enter Beef code to the left and press (F5) or (ctrl + enter) to compile and run'
  let compiling = false
</script>

<svelte:head>
  <title>Try Beef</title>
  <meta name="description" content="Try Beef" />
</svelte:head>

<div class="container">
  <Splitpanes on:resize={() => editor?.layout()}>
    <Pane>
      <Editor bind:editor bind:output bind:compiling />
    </Pane>
    <Pane>
      <Output bind:output bind:compiling />
    </Pane>
  </Splitpanes>
</div>

<style>
  .container {
    display: flex;
    height: 100%;
  }
</style>
