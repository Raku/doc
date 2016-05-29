$(function(){
    setup_search_box();
    setup_auto_title_anchors();
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
}

function setup_auto_title_anchors() {
    $('#content').find('h1,h2,h3,h4,h5,h6').each(function(i, el){
        if ( ! $(el).attr('id') ) { return; }
        $(el).append(
            '<a href="#' + $(el).attr('id') + '" class="title-anchor">§</a>'
        );
    });
}
