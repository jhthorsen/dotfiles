(function($) {
  $.placeholder = {
    fields: [],
    browserSupported: function() {
      return !!('placeholder' in $('<input type="text">')[0]);
    },
  };

  var adjustToResizing = function() {
    $.each($.placeholder.fields, function() {
      this.data('placeholder').css(calcPositionCss(this));
    });
  };

  var calcPositionCss = function($from) {
    var op = $from.offsetParent().offset();
    var ot = $from.offset();

    return {
      top: ot.top - op.top,
      left: ot.left - op.left,
      height: $from.height(),
      width: $from.width()
    };
  };

  $.fn.replaceholder = function(_config) {
    var config = $.extend({}, { color: '#888', cls: 'placeholder' }, _config);

    return this.each(function() {
      var $input = $(this);
      var $placeholder = $input.data('placeholder');

      if(!$input.is(':visible')) return;

      if($placeholder) {
        $placeholder.css(calcPositionCss($input));
        return;
      }

      var $placeholder = $('<label />')
        .text($input.attr('placeholder'))
        .addClass(config.cls)
        .css({
          'position': 'absolute',
          'display': 'inline',
          'float': 'none',
          'overflow': 'hidden',
          'color': config.color,
          'cursor': 'text',
          'padding-top': $input.css('padding-top'),
          'padding-right': $input.css('padding-right'),
          'padding-left': $input.css('padding-left'),
          'font-size': $input.css('font-size'),
          'font-family': $input.css('font-family'),
          'font-weight': $input.css('font-weight'),
          'text-transform': $input.css('text-transform'),
          'background': 'transparent',
          'zIndex': 99
        })
        .css(calcPositionCss($input))
        .attr('for', this.id)
        .click(function(){ $input.focus(); })
        .insertBefore(this);

      $input
        .data('placeholder', $placeholder)
        .keydown(function(e) {
          if(String.fromCharCode(e.keyCode).match(/^[\w\. ]/) || $input.val().length > 0) {
            $placeholder.hide();
          }
        })
        .keyup(function(e) {
          if(!$input.val().length) {
            $placeholder.show();
          }
        });

      $.placeholder.fields.push($input);
    });
  };

  $(document).ready(function() {
    $.placeholder.fn = $.fn.replaceholder;

    if($.placeholder.browserSupported()) {
      $.fn.replaceholder = function() { return this };
    }
    else {
      $('textarea[placeholder], input[placeholder]').replaceholder();
      $(window).on('resize', adjustToResizing);
    }
  });

})(jQuery);
