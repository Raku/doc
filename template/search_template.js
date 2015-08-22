// cannot use $(...) here, because jQuery is loaded asynchronously,
// and might not be available yet.
document.addEventListener("DOMContentLoaded", function(event) {
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
