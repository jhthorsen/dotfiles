window.addEventListener('load', function() {
  // localStorage.setItem("dotfiles:subscriptions", "{}");
  // localStorage.removeItem("dotfiles:subscriptions");

  const min_songs = 5;
  const state = JSON.parse(localStorage.getItem('dotfiles:subscriptions') || 'null');
  if (!state) return;
  if (!state.channels) state.channels = {};
  if (!state.playlists) state.playlists = {};

  async function addChannels() {

    // Find channels (artists) in a playlist that has more than min_songs
    if (location.pathname.indexOf('/playlist') === 0) {
      const found = {};
      for (const $a of await settle('ytmusic-playlist-shelf-renderer [href*="channel"]')) {
        if (!found[$a.href]) found[$a.href] = 0;
        found[$a.href]++;
      }
      for (const href in found) {
        if (found[href] >= min_songs && !state.channels[href]) state.channels[href] = false;
      }
      console.info(`[music.youtube.com.js] found=${Object.keys(found).length}`, found);
      markAsDone('playlists', location.href);
    }

    // Click the subscribe button on a channel (artist) page
    if (location.pathname.indexOf('/channel') === 0) {
      await new Promise(resolve => setTimeout(resolve, 500));
      const $button = document.querySelector("#button-shape-subscribe button");
      console.info(`[music.youtube.com.js] location=${location.href} button="${$button?.textContent}" state=${state.channels[location.href]}`);
      if (state.channels[location.href] === false && $button && $button.textContent.indexOf('Subscribed') === -1) $button.click();
      await new Promise(resolve => setTimeout(resolve, 1000));
      markAsDone('channels', location.href);
    }

    // Find playlists
    if (location.pathname.indexOf('/library/playlists') === 0) {
      for (const $playlist of await settle('a[href*="playlist?list"]')) {
        if (!state.playlists[$playlist.href]) state.playlists[$playlist.href] = false;
      }
      localStorage.setItem('dotfiles:subscriptions', JSON.stringify(state));
    }

    // Go to the next channel or playlist that has not yet been processed
    for (const namespace of ['channels', 'playlists']) {
      for (const href in state[namespace]) {
        console.debug(`[music.youtube.com.js] ${state[namespace][href] ? 'done' : 'next'}=${href}`);
        if (state[namespace][href]) continue;
        location.href = href;
      }
    }
  }

  function markAsDone(namespace, key) {
    state[namespace][key] = true;
    localStorage.setItem('dotfiles:subscriptions', JSON.stringify(state));
  };

  async function settle(sel) {
    console.info(`[music.youtube.com.js] settle="${sel}"`);
    let found = [];
    for (let i = 0; i < 4; i++) {
      await new Promise(resolve => setTimeout(resolve, 500));
      const els = document.querySelectorAll(sel);
      if (els.length && els.length === found.length) return found;
      found = els;
      window.scrollTo({behavior: 'smooth', top: 10000, left: 0});
    }
    return found;
  }

  addChannels();
})
