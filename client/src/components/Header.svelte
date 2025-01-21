<script>
  import { helloWorld } from '../helloworld'
  import GithubLink from './GithubLink.svelte'

  export let input = ''

  function reset() {
    input = helloWorld
    window.location.href = '/'
  }
</script>

<header>
  <a href="https://www.beeflang.org/">
    <img src="Beef.png" alt="logo" height="32" />
  </a>
  <h1><span class="heading" on:click={reset}>Try Beef</span></h1>
  <div class="spacer" />
  <button class="reset" on:click={reset}>Reset</button>
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

  .heading {
    cursor: pointer;
    transition: 0.2s;

    &:hover {
      color: #ccc;
      text-decoration: underline;
    }
  }

  .reset {
    background: none;
    border-radius: 2px;
    border: 1px solid white;
    color: white;
    cursor: pointer;
    margin-right: 12px;
    padding: 4px 12px;

    &:hover {
      background-color: rgba(255, 255, 255, 0.2);
    }
  }
</style>
