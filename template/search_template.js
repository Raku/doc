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
        if (a.category.toLowerCase() < b.category.toLowerCase()) {
          return -1;
        } else if (a.category.toLowerCase() > b.category.toLowerCase()) {
          return 1;
        } else if (a.value.toLowerCase() < b.value.toLowerCase()) {
          return -1;
        } else if (a.value.toLowerCase() > b.value.toLowerCase()) {
          return 1;
        } else {
          return 0;
        }
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
  $("#query").catcomplete({
      response: function( e, ui ) {
        if ( ! ui.content.length ) { $('#search').addClass(   'not-found') }
        else {                       $('#search').removeClass('not-found') }
      },
      open: function() {
        var ui_el = $('.ui-autocomplete');
        if ( ui_el.offset().left < 0 ) {
            ui_el.css({left: 0})
        }
      },
      position: { my: "right top", at: "right bottom", of: "#search div" },
      source: [
ITEMS
      ],
      select: function (event, ui) { window.location.href = ui.item.url; },
      autoFocus: true
  });
});
