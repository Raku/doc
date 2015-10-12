$(function(){
  $("#query").autocomplete({
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
