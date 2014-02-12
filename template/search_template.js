$(function(){
  var autocomplete_opts = {
    position: search_position,
    source: [
ITEMS
    ],
    select: function (event, ui) {
      search_select(ui.item.url);
    }
  };
  
  if (search_position) autocomplete_opts.position = search_position;
  
  $("#query").autocomplete(autocomplete_opts);
});
