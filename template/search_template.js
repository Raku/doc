$(function(){
  $.widget( "custom.catcomplete", $.ui.autocomplete, {
    _create: function() {
      this._super();
      this.widget().menu( "option", "items", "> :not(.ui-autocomplete-category)" );
    },
    _renderMenu: function( ul, items ) {
      var that = this,
      currentCategory = "";
      function sortBy(a, b) {
        // We want to place 5to6 docs to the end of the list.
        // See if either a or b are in 5to6 category.
        var isp5a = false, isp5b = false;
        if ( a.category.substr(0,4) == '5to6' ) { isp5a = true; }
        if ( b.category.substr(0,4) == '5to6' ) { isp5b = true; }

        // If one of the categories is a 5to6 but other isn't,
        // move 5to6 to be last
        if ( isp5a  && !isp5b ) {return  1}
        if ( !isp5a && isp5b  ) {return -1}

        // Sort by category alphabetically; 5to6 items would both have
        // the same category if we reached this point and category sort
        // will happen only on non-5to6 items
        if ( a.category.toLowerCase() < b.category.toLowerCase() ) {return -1}
        if ( a.category.toLowerCase() > b.category.toLowerCase() ) {return  1}

        // We reach this point when categories are the same; so
        // we sort items by value
        if ( a.value.toLowerCase() < b.value.toLowerCase() ) {return -1}
        if ( a.value.toLowerCase() > b.value.toLowerCase() ) {return  1}
        return 0;
      }
      $.each( items.sort(sortBy), function( index, item ) {
        var li;
        if ( item.category != currentCategory ) {
          ul.append( "<li class='ui-autocomplete-category'>" + item.category + "</li>" );
          currentCategory = item.category;
        }
        li = that._renderItemData( ul, item );
        if ( item.category ) {
          li.attr( "aria-label", item.category + " : " + item.label );
        }
      });
    }
  });
  $("#query").attr('placeholder', '🔍').catcomplete({
      response: function( e, ui ) {
        if ( ! ui.content.length ) {
            $('#search').addClass('not-found')
                .find('#try-web-search').attr(
                    'href', 'https://www.google.com/search?q=site%3Adocs.perl6.org+'
                    + encodeURIComponent( $("#query").val() )
                );
        }
        else {
            $('#search').removeClass('not-found')
        }
      },
      open: function() {
        var ui_el = $('.ui-autocomplete');
        if ( ui_el.offset().left < 0 ) {
            ui_el.css({left: 0})
        }
      },
      position: { my: "right top", at: "right bottom", of: "#search div" },
      source: [
          {
              category: "Syntax",
              value: "# single-line comment",
              url: "/language/syntax#Single-line_comments"
          }, {
              category: "Syntax",
              value: "#` multi-line comment",
              url: "/language/syntax#Multi-line_/_embedded_comments"
          }, {
              category: "Signature",
              value: ";; (long name)",
              url: "/type/Signature#index-entry-Long_Names"
          },
          ITEMS
      ],
      select: function (event, ui) { window.location.href = ui.item.url; },
      autoFocus: true
  });
});

/*
 * allow for inexact searching via sift4
 * try to restrict usage, and always check the standard
 * search mechanism if sift4 doesn't match
 */
$.extend( $.ui.autocomplete, {
    escapeRegex: function( value ) {
        return value.replace( /[\-\[\]{}()*+?.,\\\^$|#\s]/g, "\\$&" );
    },
    filter: function( array, term ) {
        var max_distance = 2;
        var len = term.length;
        var matcher = new RegExp( $.ui.autocomplete.escapeRegex( term ), "i" );
        return $.grep( array, function( value ) {
            if (len >=2 ) {
                var OK_distance = Math.min(max_distance, len -1);
                var result = sift4( value.value, term, Math.max(5, len+1), Math.max(3, len-1));
                if (result <=OK_distance) {
                    return true;
                }
            }

            // Try the old school match
            return matcher.test( value.label || value.value || value );
        } );
    }
} );
