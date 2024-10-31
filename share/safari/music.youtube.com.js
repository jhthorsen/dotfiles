window.addEventListener('load', function() {
  // localStorage.setItem("dotfiles:subscribed:user_real_name", "Your Name");
  // localStorage.removeItem("dotfiles:subscribed:user_real_name");
  // localStorage.removeItem("dotfiles:subscriptions");

  let user_real_name = localStorage.getItem('dotfiles:subscribed:user_real_name');
  if (!user_real_name) return;

  const trim2k = (s) => s.replace(/\s+/g, ' ').trim();
  let state = JSON.parse(localStorage.getItem('dotfiles:subscriptions') || '{}');
  let min_songs = 5;
  let playlists = null;

  if (!state.channels) state.channels = {};
  if (!state.playlists) state.playlists = {};

  function addChannels() {

    // Find channels (artists) in a playlist that has more than min_songs
    if (location.pathname.indexOf('/playlist') !== -1) {
      const found = {};
      for (const $a of document.querySelectorAll('ytmusic-playlist-shelf-renderer [href*="channel"]')) {
        const href = $a.pathname;
        if (!found[href]) found[href] = 0;
        found[href]++;
      }
      for (const href in found) {
        if (found[href] >= min_songs && !state.channels[href]) state.channels[href] = false;
      }
      localStorage.setItem('dotfiles:subscriptions', JSON.stringify(state));
    }

    // Click the subscribe button on a channel (artist) page
    if (location.pathname.indexOf('/channel') !== -1 && !state.channels[location.pathname]) {
      const $button = document.querySelector("#button-shape-subscribe button");
      console.log(`Found ${$button?.textContent} on channel page ${location.pathname}`);
      markAsDone('channels', location.pathname);
      if ($button && $button.textContent.indexOf('Subscribed') === -1) $button.click();
    }

    // Go to the next channel that has not yet been processed
    for (const href in state.channels) {
      if (state.channels[href]) continue;
      return location.href = href;
    }

    // Find available playlists
    if (!playlists) {
      playlists = {};
      for (const $link of document.querySelectorAll('.ytmusic-guide-section-renderer [role=link]')) {
        const playlist_name = trim2k($link.textContent);
        if (!state.playlists[playlist_name] && playlist_name.indexOf(user_real_name) !== -1) {
          state.playlists[playlist_name] = false;
          playlists[playlist_name] = $link;
        }
      }
      localStorage.setItem('dotfiles:subscriptions', JSON.stringify(state));
    }

    // Go to the next playlist that has not yet been processed
    for (const playlist_name in state.playlists) {
      if (state.playlists[playlist_name] || !playlists[playlist_name]) continue;
      markAsDone('playlists', playlist_name);
      return playlists[playlist_name].click();
    }

    clearTimeout(tid);
  }

  function markAsDone(namespace, key) {
    state[namespace][key] = true;
    localStorage.setItem('dotfiles:subscriptions', JSON.stringify(state));
  };

  const tid = setInterval(addChannels, 1000);
})
