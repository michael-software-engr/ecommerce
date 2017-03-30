// ... edited by app gen ('grayscale' theme)

// ... also seems to work...
document.addEventListener('turbolinks:load', function turbolinksLoadCB() {
  // ... https://stackoverflow.com/questions/25967082/javascript-will-only-work-after-refreshing-the-page
  $('body').scrollspy({ target: '.navbar-fixed-top' });

  // Collapse the navbar on scroll
  $(window).scroll(function collapseNavBarOnScroll() {
    if ($('.navbar').offset().top > 50) {
      $('.navbar-fixed-top').addClass('top-nav-collapse');
    } else {
      $('.navbar-fixed-top').removeClass('top-nav-collapse');
    }
  });

  // For page scrolling feature - requires jQuery Easing plugin
  $(function pageScrollingFeature() {
    $('a.page-scroll').on('click', function clickEventHandler(event) {
      var $anchor = $(this);

      var href = $anchor.attr('href');

      if (href.match(/^\#/)) {
        // ... scroll to an ID
        //     Apparently, this removes the has part (prob. the scrollTop plugin)
        $('html, body').stop().animate({
          scrollTop: $(href).offset().top
        },
          // 850,
          650,
          'easeInOutExpo'
        );

        event.preventDefault();

        // https://stackoverflow.com/questions/15322917/clearing-url-hash
        // ... behavior goes like this:
        //     If a link is '/some_path#some_id', on first load, the URL will show the ID.
        //     If the user navigates within the same page using another ID,
        //       the user will be brought to the new ID offset and the previous ID shown
        //       on the address bar will be removed.
        if (window.location.pathname && window.location.hash) {
          window.history.replaceState('', document.title, window.location.pathname);
        }
      } else {
        console.log(
          '... anchor href = \'' + href +
          '\'. No ID\'s (#) found. We\'re only scrolling on links with ID\'s.'
        );
      }
    });
  });

  // Closes the Responsive Menu on Menu Item Click
  $('.navbar-collapse ul li a').click(function clickCB() {
    $('.navbar-toggle:visible').click();
  });
});
