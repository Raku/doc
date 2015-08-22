$(function(){
  $('#search').css('visibility', 'visible');
  $("#query").autocomplete({
      response: function( e, ui ) {
        if ( ! ui.content.length ) { $('#search').addClass(   'not-found') }
        else {                       $('#search').removeClass('not-found') }
      },
      position: { my: "right top", at: "right bottom", of: "#search div" },
      source: [
ITEMS
      ],
      select: function (event, ui) { window.location.href = ui.item.url; },
      autoFocus: true
  });
});
