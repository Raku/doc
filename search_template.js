$(function(){
  $("#query").autocomplete({
    source: [
ITEMS
    ],
    select: function (event, ui) {
	  search_select(ui.item.url);
    }
  }).focus();
});
