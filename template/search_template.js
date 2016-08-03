// WARNING
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
          PREDEFINED
          ITEMS
      ],
      select: function (event, ui) { window.location.href = ui.item.url; },
      autoFocus: true
  });
});
