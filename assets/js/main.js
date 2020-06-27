$(function(){
    setup_search_box();
    setup_auto_title_anchors();
    setup_debug_mode();
    setup_tables();
    $(window).resize(setup_search_box);
});

function setup_tables() {
    $('.pod-table').each(function() {
        if ($(this).find('thead').length
         && $(this).find('tr').length > 10
         && ! ( // don't sort operators precedence table
              $(this).find('thead th:first-child'     ).text() == 'A'
           && $(this).find('thead th:first-child + th').text() == 'Level'
         )) $(this).tablesorter({sortList: [[0,0]]})
    })
}

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

document.addEventListener("keyup", function(evt){
    if(evt.key == "Escape" && $('body').scrollTop() == 0) {
        $('#query').focus();
    }
});

function setup_debug_mode(){
    $('footer').children(':first').append('<span id="debug"> [Debug: '+ (window.sessionStorage.getItem("debug")?"on":"off") +']</span>');
    $('#debug').click(function(){
        if ( $(this).text().includes('off') ) {
            window.sessionStorage.setItem("debug", "on");
            $(this).html('[Debug: on]');
        }else{
            window.sessionStorage.removeItem("debug");
            $(this).html('[Debug: off]');
        }
    });

    if ( window.sessionStorage.getItem("debug") ) {
        console.info("checking for duplicated name and id attrs");

        var seen_name_or_id = [];

        $('#content').css('overflow', 'visible');

        $('html').find('a').each( function(i, el){
            if ( el.name ) {
                if ( seen_name_or_id.includes(el.name) ) {
                    console.log("found duplicate name attr in", el);
                }
                seen_name_or_id.push(el.name);

                $(el).after('<span><a href="#' + el.name + '" style="color: magenta;">«#'+el.name+'»</a> </span>');
            }
            if ( el.id ) {
                if ( seen_name_or_id.includes(el.id) ) {
                    console.log("found duplicate id attr in", el);
                }
                seen_name_or_id.push(el.id);
            }
        });

        console.log('setup viewport resolution display');
        $('body').append('<span id="screen_res" style="color: magenta; position: absolute; bottom: 0; left: 0;"></span>');
        window.setInterval(function screen_size_on_status_bar(){
            $('#screen_res').text(window.innerWidth + 'x' + window.innerHeight);
        }, 1000);

        console.info("add debug CSS");

        $('head').append($('<style/>', {
            id: 'debug',
            html: 'table#TOC td.toc-number { display: inherit; }'
        }));

        if(window.localStorage){
            var sS = window.localStorage;
            var commit = $('#footer-commit').text();
            if ( sS.getItem('commit') != commit ) {
                sS.clear();
                sS.setItem('commit', commit);
                console.info("wiping cache");
            }

            if ( ! sS.getItem(commit+window.location.pathname) ) {
                sS.setItem(commit+window.location.pathname, "seen");
                console.info("checking for dead links");

                function report_broken_link(url) {
                    $('html').find('#search').after('<div style="text-align: center;">Broken link: ' + url + ' found. Please report at <a href="https://webchat.freenode.net/?channels=#raku">irc.freenode.net#raku</a></div>');
                }

                var seen_link = [];
                var links = [];
                $('html').find('a[href]').each(function(i,el){ links.push(el.href)});
                $('svg').find('a').filter(function(i,e){return e.href.baseVal}).each(function(i,el){ links.push(el.href.baseVal) });
                links.forEach( function(el) {
                    var url_without_anchor = el.split('#')[0];
                    if ( ! seen_link.includes(decodeURIComponent(url_without_anchor)) ) {
                        seen_link.push(decodeURIComponent(url_without_anchor));
                    }
                });

                seen_link.forEach( function(url) {
                    var request = new XMLHttpRequest();

                    request.onreadystatechange = function(){
                        if ( request.readyState === 4 ) {
                            if ( request.status >= 400 ) {
                                report_broken_link(request.status + " for " + url);
                            } else {
                                // console.log(request.status + " for " + url);
                            }
                        }
                    }

                    try {
                        request.open('HEAD', url);
                        request.send();
                    } catch (e) { /* this will catch errors due to browser security settings for external links */ }
                });
            }
        }

    }
}
