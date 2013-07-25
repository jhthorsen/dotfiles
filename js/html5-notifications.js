/*
 * This will enable a HTML5 notification compatible API in chrome and other
 * HTML5 ready browsers.
 * See http://www.w3.org/TR/notifications/ for documentation.
 *
 * Notes
 * - The requestPermission() callback may receive "unsupported" (non-standard)
 * - It prefers window.webkitNotifications if available
 * - You can enable notifications in firefox with
 *   https://addons.mozilla.org/en-us/firefox/addon/html-notifications/
 */
if(window.webkitNotifications) {
  window.Notification = function(title, args) {
    var n = window.webkitNotifications.createNotification(args.iconUrl || '', title, args.body || '');
    $.each(['onshow', 'onclose'], function(k, i) { if(args[k]) this[k] = args[k]; });
    n.ondisplay = function() { if(this.onshow) this.onshow() };
    n.show();
    return n;
  };
  window.Notification.permission = webkitNotifications.checkPermission() ? 'default' : 'granted';
  window.Notification.requestPermission = function(cb) {
    webkitNotifications.requestPermission(function() {
      window.Notification.permission = webkitNotifications.checkPermission() ? 'denied' : 'granted';
      cb(window.Notification.permission);
    });
  };
  window.Notification.prototype.close = function() { if(this.onclose) this.onclose(); };
}
else if(!window.Notification) {
  window.Notification = function(title, args) { return this; };
  window.Notification.permission = 'unsupported'; // TODO: "denied" instead?
  window.Notification.requestPermission = function(cb) { cb('unsupported'); };
  window.Notification.prototype.close = function() { if(this.onclose) this.onclose(); };
}
