/*
 * Author: Jan Henning Thorsen - jhthorsen@cpan.org
 * Demo: https://rawgithub.com/jhthorsen/snippets/master/js/jquery.tooltip.html
 * Minified by http://jscompress.com
 */
(function($) {
  var $win = $(window);
  var on_touch_device = !!('ontouchstart' in window);
  var tte = 'tooltip_element';
  var ttd = 'tooltip_disabled';
  var hide = function(e) {
    var args = e.data;
    var $tooltip = args.self.data(tte);
    $win.unbind('resize', show);
    $tooltip.animate({ opacity: 0 }, 70, function() { $tooltip.css('left', '-2000px'); });
    if(args.title && !args.self.data(ttd)) args.self.attr('title', args.title);
    args.tooltip_visible = false;
    return false;
  };
  var show = function(e) {
    var args = e.data;
    var $self = args.self;
    var html = $self.attr('data-tooltip');
    var $tooltip, offset, left, top, width;

    if($self.data(ttd)) return false;
    if(!html) return true;

    $tooltip = $self.data(tte);
    offset = $self.offset();
    width = $tooltip.find('.tooltip-inner').html(html).css('width', 'auto').outerWidth();

    if(args.max_width < width) width = args.max_width;
    if($win.width() < width) width = $win.width();

    $tooltip.outerWidth(width);

    left = offset.left + $self.outerWidth() / 2 - width / 2;

    if(args.pos.indexOf('under') !== -1) {
      top = offset.top + $self.outerHeight();
    }
    else {
      top = offset.top - $tooltip.outerHeight();
    }

    if(left + width > $win.width()) left = $win.width() - width;
    if(left < 0) left = 10;
    if(top < $(window).scrollTop()) top = offset.top + $self.outerHeight() + 10;

    $('div.' + args.class_name).css('z-index', args.z_index - 1);

    if(args.tooltip_visible) {
      $tooltip.css({ 'left': left, 'top': top, 'z-index': args.z_index });
    }
    else {
      if($self.attr('title')) args.title = $self.attr('title');
      args.tooltip_visible = true;
      $self.removeAttr('title');
      $tooltip.css({ 'left': left, 'top': top, 'z-index': args.z_index, 'opacity': 0 });
      $tooltip.animate({ opacity: args.opacity }, 70);
      $win.bind('resize', args, show);
    }

    return args.show_on_focus;
  };
  var toggle = function(e) {
    return e.data.tooltip_visible ? hide(e) : show(e);
  };

  $.fn.tooltip = function(_args) {
    if(_args === 'disable') {
      return this.each(function() { $(this).data(ttd, true).trigger('hide.tooltip'); });
    }
    else if(_args === 'enable') {
      return this.each(function() { $(this).data(ttd, false); });
    }
    else if(_args === 'destroy') {
      return this.each(function() {
        var $self = $(this);
        if(!$self.data(tte)) return;
        $self.data(ttd, false).trigger('hide.tooltip').data(tte).remove();
        $self.removeData(tte)
          .unbind('click', toggle)
          .unbind('mouseenter', show)
          .unbind('mouseleave', hide)
          .unbind('show.tooltip', show)
          .unbind('hide.tooltip', hide)
        $win.unbind('resize', show);
      });
    }

    return this.each(function() {
      var args = $.extend({}, _args || {});
      var $self = $(this);
      var tip = $('<div class="tooltip"><div class="tooltip-inner"></div><div class="tooltip-arrow"></div></div>');

      if($self.data(tte)) return;
      if(!$self.attr('data-tooltip')) $self.attr('data-tooltip', $self.attr('title') || '');
      if(typeof args.show_on_click == 'undefined') args.show_on_click = on_touch_device || !$self.is('a, :input');

      // options
      args.max_width = args.max_width || 320;
      args.opacity = args.opacity || 0.95;
      args.pos = args.pos || 'over';
      args.z_index = args.z_index || 1000;
      args.self = $self;

      if(m = ($self.attr('class') || '').match(/tooltip-(\w+)/)) {
        args.pos = m[1];
        tip.addClass(m[1]);
      }
      else {
        tip.addClass('top');
      }

      $self.data(tte, tip.css({ position: 'absolute', left: '-2000px' }).appendTo('body'));
      $self.bind('show.tooltip', args, show);
      $self.bind('hide.tooltip', args, hide);

      if(args.show_on_click) {
        $self.data(tte).bind('click', args, hide);
        $self.bind('click', args, toggle);
      }
      else if(args.show_on_focus) {
        $self.bind('blur', args, hide);
        $self.bind('focus', args, show);
      }
      else {
        $self.bind('mouseenter', args, show);
        $self.bind('mouseleave', args, hide);
      }
    });
  };

})(jQuery);
