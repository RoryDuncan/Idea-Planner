
$(document).ready(
  (function() {

      var h = $(window).height(),
          w = $(window).width();

      hero = $('.above-fold');
      nav = $('.navbar-default .container');
      
      h = h - nav.innerHeight();


      hero.css({
        "padding-bottom": (h * 0.85) + "px",
        "padding-top": (h * 0.15) + "px",

      });

    
  })
);


