<script>
  import GithubLink from './GithubLink.svelte'
</script>

<header>
  <a href="https://www.beeflang.org/">
    <img src="Beef.png" alt="logo" height="32" />
  </a>
  <h1>Try Beef</h1>
  <div class="spacer" />
  <GithubLink />
</header>

<style>
  header {
    align-items: center;
    background-image: linear-gradient(#4bb4e3, #2b94c3);
    display: flex;
    flex: 0 0 auto;
    height: var(--header-height);
    padding: 0 24px;
  }

  h1 {
    color: white;
    font-size: 24px;
    padding-left: 12px;
  }

  a {
    display: inline-flex;
  }

  .spacer {
    flex: 1 1 auto;
  }
</style>
