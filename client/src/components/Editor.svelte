<script lang="ts">
  import type monaco from 'monaco-editor'
  import editorWorker from 'monaco-editor/esm/vs/editor/editor.worker?worker'
  import cssWorker from 'monaco-editor/esm/vs/language/css/css.worker?worker'
  import htmlWorker from 'monaco-editor/esm/vs/language/html/html.worker?worker'
  import jsonWorker from 'monaco-editor/esm/vs/language/json/json.worker?worker'
  import tsWorker from 'monaco-editor/esm/vs/language/typescript/ts.worker?worker'
  import { onMount } from 'svelte'
  import { helloWorld } from '../helloworld'

  export let editor: monaco.editor.IStandaloneCodeEditor
  export let output: string = ''
  export let compiling = false

  let divEl: HTMLDivElement
  let Monaco

  function encode(str: string) {
    return btoa(str)
  }

  function decode(str: string) {
    return atob(str)
  }

  function endpoint() {
    return import.meta.env.PROD ? 'https://trybeef.fly.dev' : 'http://localhost:8081'
  }

  async function compile(code: string) {
    compiling = true

    const host = endpoint()

    try {
      const res = await fetch(`${host}/compile?code=${code}`)

      output = await res.text()
    } catch (e) {
      console.log({ e })
    }

    compiling = false
  }

  async function updateUrl(code: string) {
    try {
      const host = endpoint()
      const response = await fetch(`${host}/sprunge/${code}`, { method: 'post' })
      const url = await response.text()
      const id = url.replace('http://sprunge.us/', '')
      window.location.hash = '/' + id
    } catch (e) {
      console.log({ e })
    }
  }

  async function initMonaco(value: string = helloWorld) {
    // @ts-ignore
    self.MonacoEnvironment = {
      getWorker: function (_moduleId: any, label: string) {
        if (label === 'json') {
          return new jsonWorker()
        }
        if (label === 'css' || label === 'scss' || label === 'less') {
          return new cssWorker()
        }
        if (label === 'html' || label === 'handlebars' || label === 'razor') {
          return new htmlWorker()
        }
        if (label === 'typescript' || label === 'javascript') {
          return new tsWorker()
        }
        return new editorWorker()
      },
    }

    Monaco = await import('monaco-editor')

    editor = Monaco.editor.create(divEl, {
      value,
      language: 'csharp',
      theme: 'vs-dark',
      minimap: {
        enabled: false,
      },
      padding: {
        top: 12,
      },
    })

    editor.onKeyDown((e) => {
      if (e.code === 'F5' || (e.code === 'Enter' && (e.ctrlKey || e.metaKey))) {
        e.stopPropagation()

        if (!compiling) {
          const code = encode(editor.getValue())

          updateUrl(code)

          compile(code)
        }
      }
    })
  }

  onMount(async () => {
    const id = window.location.hash.replace('#/', '').trim()

    if (id) {
      try {
        const sprunge = await fetch(`${endpoint()}/sprunge/${id}`)

        const code = await sprunge.text()

        if (code) {
          initMonaco(decode(code))
        }
      } catch (e) {
        initMonaco()
      }
    } else {
      initMonaco()
    }

    function resize() {
      editor.layout()
    }

    window.addEventListener('resize', resize)

    return () => {
      window.removeEventListener('resize', resize)
      editor.dispose()
    }
  })
</script>

<div bind:this={divEl} class="editor" />

<style>
  .editor {
    height: 100%;
    width: 100%;
  }
</style>
