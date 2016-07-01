$(function(){
    setup_search_box();
    setup_auto_title_anchors();
    setup_collapsible_TOC();
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

function setup_collapsible_TOC() {
    var state;
    if ( ! $('nav.indexgroup > ol').length ) { return; }

    // fix for jumpy .slideDown() effect
    $('nav.indexgroup > ol').each( function(){
        $(this).css( 'height', $(this).height() );
    });

    state = Cookies.get('toc_state') || 'shown';
    if ( state == 'hidden' ) {
        $('nav.indexgroup > ol').hide();
    }

    $('nav.indexgroup')
        .prepend('<h2 id="TOC_title">Table of Contents'
            + ' <a href="#">['
            + ( state == 'hidden' ? 'show' : 'hide')
            + ']</a></h2>'
        )
        .find('> h2 > a')
            .click(function() {
                var el = $(this);
                if (el.text() == '[hide]') {
                    Cookies.set('toc_state', 'hidden');
                    el.parents('nav').find('ol').slideUp();
                    el.text('[show]');
                }
                else {
                    Cookies.set('toc_state', 'shown');
                    el.parents('nav').find('ol').slideDown();
                    el.text('[hide]');
                }

                return false;x
            });
}
