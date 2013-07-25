/*
 * Author: Jan Henning Thorsen - jhthorsen@cpan.org
 * This is a fork of https://github.com/joewalnes/reconnecting-websocket
 * 
 * Usage:
 * ws = $.ws('/my/socket');
 * ws.on('close', function(e), { alert('Connection is closed.'); });
 * ws.on('error', function(err), { alert(err); });
 * ws.on('message', function(e) { console.log(e.data); }); // get data
 * ws.on('open', function(e), { alert('Connection is open!'); });
 * ws.send("some data"); // will be sent when connected
 */
;(function($) {
  $.ws = function(a) {
    function f(g) {
      c = new WebSocket(a);
      if (b.debug) console.debug("ReconnectingWebSocket", "attempt-connect", a);
      var h = c;
      var i = setTimeout(function() {
        if (b.debug) console.debug("ReconnectingWebSocket", "connection-timeout", a);
        e = true;
        h.close();
        e = false;
      }, b.timeoutInterval);
      c.onopen = function(c) {
        clearTimeout(i);
        if (b.debug) console.debug("ReconnectingWebSocket", "onopen", a);
        b.readyState = WebSocket.OPEN;
        g = false;
        on.open.fire(c);
        dfd_c.resolve(c);
      };
      c.onclose = function(h) {
        clearTimeout(i);
        c = null;
        dfd_c = $.Deferred();
        if (d) {
          b.readyState = WebSocket.CLOSED;
          on.close.fire(h, false);
        } else {
          b.readyState = WebSocket.CONNECTING;
          if (!g && !e) {
            if (b.debug) console.debug("ReconnectingWebSocket", "onclose", a);
            on.close.fire(h, true);
          }
          setTimeout(function() { f(true); }, b.reconnectInterval);
        }
      };
      c.onmessage = function(c) {
        if (b.debug) console.debug("ReconnectingWebSocket", "onmessage", a, c.data);
        on.message.fire(c);
      };
      c.onerror = function(c) {
        if (b.debug) console.debug("ReconnectingWebSocket", "onerror", a, c);
        on.error.fire(c);
      };
    }
    var d = false;
    var e = false;
    var c;
    var dfd_c = $.Deferred();
    var on = {
      close: $.Callbacks(),
      error: $.Callbacks(),
      message: $.Callbacks(),
      open: $.Callbacks()
    };
    var b = {
      debug: false,
      reconnectInterval: 1e3,
      timeoutInterval: 2e3,
      readyState: WebSocket.CONNECTING,
      url: a,
      close: function() { if(!c) return false; c.close(); return(d = true); },
      on: function(event, fn) { on[event].add(fn); },
      send: function(m) { var msg = m; return dfd_c.done(function() { return c.send(m); }); }
    };
    f(a);
    return b;
  };
})(jQuery);
