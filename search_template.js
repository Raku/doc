function display () {
  var iframe_doc = $("#buffer").get()[0].contentDocument;
  $("#display").html(iframe_doc.body.innerHTML);
}
$(function(){
  $("#query").autocomplete({
    source: [
ITEMS
    ],
    select: function (event, ui) {
      $("#buffer").attr("src", ui.item.url);
    }
  }).focus();
});
