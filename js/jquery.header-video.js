(function($) {
  $(document).ready(function() {
    $('header.video').each(function() {
      var $header = $(this);
      var $video = $('<video autoplay="1" loop="1">');
      var min_width = $header.attr('data-min-width') || 960;
      var sources = $header.attr('data-source');

      if(!sources) return;
      if($(window).width() < min_width) return;

      $.each(sources.split(','), function() {
        if(this) $video.append('<source src="' + this + '">');
      });

      $header.find('iframe').replaceWith($video);
    });
  });
})(jQuery);
