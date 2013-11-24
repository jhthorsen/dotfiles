window.console = window.console || { log: function() { window.console.messages.push(arguments) }, messages: [] };
window.console._debug = function() { if(window.DEBUG) window.console.log.apply(window.console, arguments) };
