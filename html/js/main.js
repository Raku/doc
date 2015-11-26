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

    /* Focus search box on page load, but remove focus if the user appears
        to be trying to scroll the page with keyboard, rather than typing
        a search query
    */
    $('#query').keydown( function(e){
        var el = $(this);
        if ( el.val().length && ( e.which == 32 || e.which == 40) ) {
            return true;
        }
        if ( e.which == 32 || e.which == 34 || e.which == 40 ) { el.blur()  ; }
        // key codes: 32: space; 34: pagedown; 40: down arrow
    });
}
