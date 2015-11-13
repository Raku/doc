$(function(){
    setup_search_box();
    $(window).resize(setup_search_box);
});

function setup_search_box() {
    var sel = $('#search'), head = $('#logo').parent();
    if ( ! sel.length ) { return; }

    /* Setup handling of narrow screens */
    if ( head.offset().top + head.innerHeight() <= sel.offset().top ) {
        sel.addClass('two-row');
    }
    else {
        sel.removeClass('two-row');
    }

    /* Focus search box on page load, but remove it when user scrolled a bit
        ... because some use "Space" key to scroll through the page, but
        ... if our search box stays focused, they get jolted back to the
        ... top of the page
    */
    $('#query').focus();
    $(window).on('scroll.search', function(){
        if ( $(window).scrollTop() > 200 ) {
            $('#query').blur();
            $(window).off('scroll.search');
        }
    });
}
