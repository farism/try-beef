<script lang="ts">
  import type monaco from 'monaco-editor'
  import editorWorker from 'monaco-editor/esm/vs/editor/editor.worker?worker'
  import cssWorker from 'monaco-editor/esm/vs/language/css/css.worker?worker'
  import htmlWorker from 'monaco-editor/esm/vs/language/html/html.worker?worker'
  import jsonWorker from 'monaco-editor/esm/vs/language/json/json.worker?worker'
  import tsWorker from 'monaco-editor/esm/vs/language/typescript/ts.worker?worker'
  import { onMount } from 'svelte'

  const MICROBIN_URL = 'https://microbin-misty-violet-1746.fly.dev'

  export let editor: monaco.editor.IStandaloneCodeEditor
  export let input: string = ''
  export let output: string = ''
  export let compiling = false

  let divEl: HTMLDivElement
  let Monaco

  function encode(str: string) {
    return btoa(encodeURIComponent(str))
  }

  function decode(str: string) {
    return decodeURIComponent(atob(str))
  }

  function endpoint() {
    return import.meta.env.PROD ? 'https://trybeef.fly.dev' : 'http://localhost:8080'
  }

  async function post(url: string, data: any) {
    return await fetch(url, {
      method: 'POST',
      body: JSON.stringify(data),
      headers: {
        Accept: 'application/json',
        'Content-Type': 'application/json',
      },
    })
  }

  async function upload(code: string) {
    try {
      const response = await post(endpoint() + '/upload', { code })

      const id = await response.text()

      window.location.hash = '/' + id

      return id
    } catch (e) {}
  }

  async function compile(id: string) {
    compiling = true

    const host = endpoint()

    try {
      const res = await post(`${host}/compile`, { id })

      output = await res.text()
    } catch (e) {
      console.log({ e })
    }

    compiling = false
  }

  async function initMonaco(value: string) {
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

    editor.onKeyDown(async (e) => {
      if (e.code === 'F5' || ((e.ctrlKey || e.metaKey) && e.code === 'Enter')) {
        e.stopPropagation()

        if (!compiling) {
          const id = await upload(editor.getValue())

          if (id) {
            await compile(id)
          }
        }
      }
    })
  }

  onMount(() => {
    const host = endpoint()

    const id = window.location.hash.replace('#/', '').trim()

    if (id) {
      fetch(`${host}/upload/${id}`)
        .then(async (response) => {
          initMonaco(await response.text())
        })
        .catch(() => {
          initMonaco(input)
        })
    } else {
      initMonaco(input)
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
