<script>
  import Header from '../components/Header.svelte'
</script>

<div class="app">
  <Header />
  <main>
    <slot />
  </main>
</div>

<style>
  :root {
    --header-height: 48px;
  }

  main {
    height: calc(100vh - var(--header-height));
  }

  .app {
    align-items: stretch;
    display: flex;
    flex-direction: column;
    height: 100vh;
    width: 100vw;
  }
</style>
