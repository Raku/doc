$(function(){
  $('#search').css('visibility', 'visible');
  $("#query").autocomplete({
      position: { my: "right top", at: "right bottom", of: "#search div" },
      source: [
ITEMS
      ],
      select: function (event, ui) { window.location.href = ui.item.url; },
      autoFocus: true
  });
});
