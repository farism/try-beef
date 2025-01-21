<script lang="ts">
  import type monaco from 'monaco-editor'
  import { Pane } from 'svelte-splitpanes'
  import Editor from '../components/Editor.svelte'
  import Output from '../components/Output.svelte'
  import SplitPanes from '../components/SplitPanes.svelte'
  import { helloWorld } from '../helloworld'

  let editor: monaco.editor.IStandaloneCodeEditor
  let input = helloWorld
  let output = 'Enter Beef code to the left and press (F5) or (ctrl + enter) to compile and run'
  let compiling = false
</script>

<svelte:head>
  <title>Try Beef</title>
  <meta name="description" content="Try Beef" />
</svelte:head>

<div class="container">
  <SplitPanes on:resize={() => editor?.layout()}>
    <Pane>
      <Editor bind:editor bind:input bind:output bind:compiling />
    </Pane>
    <Pane class="output">
      <Output bind:output bind:compiling />
    </Pane>
  </SplitPanes>
</div>

<style>
  .container {
    display: flex;
    height: 100%;
  }
</style>
