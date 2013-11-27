(function($) {
  $(document).ready(function() {
    $('body .editable').editable({
      editbar: $('div.editbar')
    }).filter('.is-new').editable('toggle');
  });
})(jQuery);

/*
 * Editor
 */
;(function($) {
  var $current = false;

  var methods = {
    init: function(args) {
      var $editables = this;

      args.buttons = {};
      args.buttons.edit = args.editbar.find('a[href*="#edit"]');
      args.buttons.save = args.editbar.find('a[href*="#save"]');
      args.buttons._deactive = args.editbar.find('a.deactive');

      methods.initShortcuts();

      args.buttons.edit.click(function(e) {
        e.preventDefault();
        methods.toggle.call($editables, e);
      });
      args.buttons.save.click(function(e) {
        e.preventDefault();
        if(!$(this).hasClass('deactive'))
          methods.save.call($editables, e);
      });
      args.editbar.find('a[data-formatting]').each(function(e) {
        var $a = $(this);
        var f = $a.attr('data-formatting').split(':');
        args.buttons[f[0]] = args.buttons[f[0]] ? args.buttons[f[0]].add($a) : $a;
        this.fblock_name = f[1];
        $a.click(function(e) {
          e.preventDefault();
          e.target = this;
          if(!$current) return;
          if(!$(this).hasClass('deactive')) methods.toggleFormatting.apply($editables, [e].concat(f));
        });
      });

      $editables.data('editable', args);
      $editables.on('keyup click', function(e) {
        if(!$current) return;
        args.focus = this;
        $.each(args.buttons, function(state, $buttons) {
          if(state === 'formatBlock') {
            $buttons.each(function() {
              var m = document.queryCommandValue('formatBlock') == this.fblock_name ? 'addClass' : 'removeClass';
              $buttons[m]('active');
            });
          }
          else {
            var m = document.queryCommandState(state) ? 'addClass' : 'removeClass';
            $buttons[m]('active');
          }
        });
      });

      args.heading = this.prev('h1');
      args.heading.click(function(e) {
        e.preventDefault();
        args.focus = args.heading;
      });

      return this;
    },
    initShortcuts: function() {
      $.each(
        {
          'ctrl+b': 'bold',
          'ctrl+i': 'italic',
          'ctrl+u': 'underline',
          'ctrl+y': 'redo',
          'ctrl+z': 'undo'
        },
        function(shortcut, command) {
          if(!$current) return;
          $(document).bind('keydown', shortcut, function(e) {
            e.preventDefault();
            document.execCommand(command, false, null);
          });
        }
      );
      $.each(
        {
          'ctrl+s': ['save']
        },
        function(shortcut, command) {
          if(!$current) return;
          var action = command[0];
          $(document).bind('keydown', shortcut, function(e) {
            e.preventDefault();
            command[0] = e;
            methods[action].apply($current, command.slice(0));
          });
        }
      );
    },
    save: function(e) {
      var args = this.data('editable');
      $.post(
        location.href,
        {
          name: this.attr('id'),
          title: args.heading.text(),
          content: this.html()
        },
        function(data) {
          // saved
        }
      );
      return this;
    },
    toggle: function(e) {
      var args = this.data('editable');
      if(this.hasClass('editing')) {
        $current = false;
        args.heading.removeClass('editing').removeAttr('contentEditable');
        this.removeClass('editing').removeAttr('contentEditable');
        this.data('editable').buttons._deactive.addClass('deactive').removeClass('active');
        $(this).removeClass('active');
      }
      else if(this.length) {
        $current = this;
        methods.cleanup.call(this);
        args.heading.addClass('editing').attr('contentEditable', 'true');
        this.addClass('editing').attr('contentEditable', 'true');
        this.data('editable').buttons._deactive.removeClass('deactive');
        this.click();
        $(this).addClass('active');
        $(window).scrollTop(args.heading.offset().top - 40);
        args.heading.focus();
      }
      return this;
    },
    toggleFormatting: function(e, what, extra) {
      var args = this.data('editable');
      if(!$current) {
        return;
      }
      else if(!this.is(args.focus)) {
        return;
      }
      else if(what == 'formatBlock' && e.target.fblock_name) {
        if(document.queryCommandValue('formatBlock') == e.target.fblock_name) extra = 'p';
        document.execCommand('formatBlock', false, extra);
      }
      else {
        document.execCommand(what, false, null);
      }
      methods.cleanup.call(this);
      this.click();
    },
    cleanup: function() {
      var allowed = 'p, b, i, u, a, h1, h2, h3, h4, h5, h6, pre, img, dl, dt, dd, ol, ul, li, table, td, tr, th, br';
      var block = 'div, caption, article, aside, footer, header, section, summary';
      var inline = 'span, blockquote, abbr, address, cite, code, del, em, ins, q, time, mark';
      var contents = this.contents();

      if(this.get(0) == $current.get(0) && contents.length == 1 && contents[0].nodeType == 3) {
        this.html('<p>' + this.text() + '</p>');
        return;
      }

      contents.each(function() {
        if(this.nodeType === 3) return; // text node
        var $self = $(this);

        if($self.is(allowed)) {
          methods.cleanup.call($self);
        }
        else if($self.is(inline)) {
          methods.cleanup.call($self);
          $self.replaceWith($self.html());
        }
        else if($self.is(block)) {
          methods.cleanup.call($self);
          $self.replaceWith('<p>' + $self.html() + '</p>');
        }
        else {
          $self.remove();
        }
      });
    }
  };

  $.fn.editable = function(args) {
    if(typeof args === 'object')
      return methods.init.apply(this, [args]);
    if(methods[args])
      return methods[args].apply(this, Array.prototype.slice.call(arguments, 1));
    $.error('Method ' +  method + ' does not exist on jQuery.editable');
  };
})(jQuery);

/*
<div class="editbar">
  <ul>
    <li><a href="#edit"><i class="icon-edit"></i></a></li>
    <li><a href="#save" class="deactive"><i class="icon-save"></i></a></li>
    <li><a href="#settings"><i class="icon-edit"></i></a></li>
    <%# <li><a href="#attach" class="deactive"><i class="icon-paper-clip"></i></a></li> %>
    <li><i class="divider"></i></li>
    <li><a href="#bold" class="deactive" data-formatting="bold"><i class="icon-bold"></i></a></li>
    <li><a href="#italic" class="deactive" data-formatting="italic"><i class="icon-italic"></i></a></li>
    <li><a href="#underline" class="deactive" data-formatting="underline"><i class="icon-underline"></i></a></li>
    <li><a href="#heading" class="deactive" data-formatting="formatBlock:h2"><i class="icon-font"></i></a></li>
    <li><i class="divider"></i></li>
    <%# <li><a href="#strikethrough" class="deactive" data-formatting="strikethrough"><i class="icon-strikethrough"></i></a></li> %>
    <li><a href="#orderedlist" class="deactive" data-formatting="insertorderedlist"><i class="icon-list-ol"></i></a></li>
    <li><a href="#unorderedlist" class="deactive" data-formatting="insertunorderedlist"><i class="icon-list-ul"></i></a></li>
    <li><i class="divider"></i></li>
    <li><a href="#justifyleft" class="deactive" data-formatting="justifyleft"><i class="icon-align-left"></i></a></li>
    <li><a href="#justifycenter" class="deactive" data-formatting="justifycenter"><i class="icon-align-center"></i></a></li>
    <li><a href="#justifyright" class="deactive" data-formatting="justifyright"><i class="icon-align-right"></i></a></li>
    <!-- insertimage -->
  </ul>
</div>
*/
