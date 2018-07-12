//WARNING
var current_search = "";

$(function(){
  $.widget( "custom.catcomplete", $.ui.autocomplete, {
    _create: function() {
      this._super();
      this.widget().menu( "option", "items", "> :not(.ui-autocomplete-category)" );
    },
    _renderItem: function( ul, item) {
        var regex = new RegExp('('
            + current_search.replace(/[-[\]{}()*+?.,\\^$|#\s]/g, '\\$&')
            + ')', 'ig');
        var text = item.label.replace(regex, '<b>$1</b>');
        return $( "<li>" )
            .append( $( "<div>" ).html(text) )
            .appendTo( ul );
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
        var a_cat = a.category.toLowerCase();
        var b_cat = b.category.toLowerCase();
        if ( a_cat < b_cat ) {return -1}
        if ( a_cat > b_cat ) {return  1}

        // We reach this point when categories are the same; so
        // we sort items by value

        var a_val = a.value.toLowerCase();
        var b_val = b.value.toLowerCase();

        // exact matches preferred
        if ( a_val == current_search) {return -1}
        if ( b_val == current_search) {return  1}

        var a_sw = a_val.startsWith(current_search);
        var b_sw = b_val.startsWith(current_search);
        // initial matches preferred
        if (a_sw && !b_sw) { return -1}
        if (b_sw && !a_sw) { return  1}

        // default
        if ( a_val < b_val ) {return -1}
        if ( a_val > b_val ) {return  1}

        return 0;
      }
      var sortedItems = items.sort(sortBy);
      var keywords = $("#query").val();
      sortedItems.push({
          category: 'Site Search',
          label: "Search the entire site for " + keywords,
          value: keywords,
          url: siteSearchUrl( keywords )
      });
      $.each( sortedItems, function( index, item ) {
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
                    'href', siteSearchUrl( $("#query").val() )
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
      source: function(request, response) {
          var items = [
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
              }, ITEMS ];
          var results = $.ui.autocomplete.filter(items, request.term);
          function trim_results(results, term) {
              var cutoff = 50;
              if (results.length < cutoff) {
                  return results;
              }
              // Prefer exact matches, then starting matches.
              var exacts = [];
              var prefixes = [];
              var rest = [];
              for (var ii = 0; ii <results.length; ii++) {
                  if (results[ii].value.toLowerCase() == term.toLowerCase()) {
                      exacts.push(ii);
                  } else if (results[ii].value.toLowerCase().startsWith(term.toLowerCase())) {
                  prefixes.push(ii);
                  } else {
                      rest.push(ii);
                  }
              }
              var keeps = [];
              var pos = 0;
              while (keeps.length <= cutoff && pos < exacts.length) {
                  keeps.push(exacts[pos++]);
              }
              pos = 0;
              while (keeps.length <= cutoff && pos < prefixes.length) {
                  keeps.push(prefixes[pos++]);
              }
              pos = 0;
              while (keeps.length <= cutoff && pos < rest.length) {
                  keeps.push(rest[pos++]);
              }
              var filtered = [];
              for (pos = 0; pos < results.length; pos++) {
                  if (keeps.indexOf(pos) != -1) {
                      filtered.push(results[pos]);
                  }
              }
              return filtered;
          };
          response(trim_results(results, request.term));
      },
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
        current_search = term.toLowerCase();

        var search_method = false;
        if (term.match(/^\s*\.[a-zA-Z][a-zA-Z0-9_-]+\s*$/)) {
            search_method = true;
            term = term.substr(1);
        }

        var len = term.length;
        var matcher = new RegExp( $.ui.autocomplete.escapeRegex( term ), "i" );
        var OK_distance = len > 9 ? 4 : len > 6 ? 3 : len > 4 ? 2 : 1;
        return $.grep( array, function( value ) {
            if (search_method && value.category != 'Method') {
                return false;
            }
            if (len >=2 ) {
                var result = sift4( value.value, term, 4, 0);
                if (result <=OK_distance) {
                    return true;
                }
            }

            // Try the old school match
            return matcher.test( value.label || value.value || value );
        } );
    }
} );

function siteSearchUrl( keywords ) {
    return 'https://www.google.com/search?q=site%3Adocs.perl6.org+' + encodeURIComponent( keywords );
}

/*
 * Courtesy https://siderite.blogspot.com/2014/11/super-fast-and-accurate-string-distance.html
 */

// Sift4 - common version
// online algorithm to compute the distance between two strings in O(n)
// maxOffset is the number of characters to search for matching letters
// maxDistance is the distance at which the algorithm should stop computing the value and just exit (the strings are too different anyway)
function sift4(s1, s2, maxOffset, maxDistance) {
    if (!s1||!s1.length) {
        if (!s2) {
            return 0;
        }
        return s2.length;
    }

    if (!s2||!s2.length) {
        return s1.length;
    }

    var l1=s1.length;
    var l2=s2.length;

    var c1 = 0;  //cursor for string 1
    var c2 = 0;  //cursor for string 2
    var lcss = 0;  //largest common subsequence
    var local_cs = 0; //local common substring
    var trans = 0;  //number of transpositions ('ab' vs 'ba')
    var offset_arr=[];  //offset pair array, for computing the transpositions

    while ((c1 < l1) && (c2 < l2)) {
        if (s1.charAt(c1) == s2.charAt(c2)) {
            local_cs++;
            var isTrans=false;
            //see if current match is a transposition
            var i=0;
            while (i<offset_arr.length) {
                var ofs=offset_arr[i];
                if (c1<=ofs.c1 || c2 <= ofs.c2) {
                    // when two matches cross, the one considered a transposition is the one with the largest difference in offsets
                    isTrans=Math.abs(c2-c1)>=Math.abs(ofs.c2-ofs.c1);
                    if (isTrans)
                    {
                        trans++;
                    } else
                    {
                        if (!ofs.trans) {
                            ofs.trans=true;
                            trans++;
                        }
                    }
                    break;
                } else {
                    if (c1>ofs.c2 && c2>ofs.c1) {
                        offset_arr.splice(i,1);
                    } else {
                        i++;
                    }
                }
            }
            offset_arr.push({
                c1:c1,
                c2:c2,
                trans:isTrans
            });
        } else {
            lcss+=local_cs;
            local_cs=0;
            if (c1!=c2) {
                c1=c2=Math.min(c1,c2);  //using min allows the computation of transpositions
            }
            //if matching characters are found, remove 1 from both cursors (they get incremented at the end of the loop)
            //so that we can have only one code block handling matches
            for (var i = 0; i < maxOffset && (c1+i<l1 || c2+i<l2); i++) {
                if ((c1 + i < l1) && (s1.charAt(c1 + i) == s2.charAt(c2))) {
                    c1+= i-1;
                    c2--;
                    break;
                }
                if ((c2 + i < l2) && (s1.charAt(c1) == s2.charAt(c2 + i))) {
                    c1--;
                    c2+= i-1;
                    break;
                }
            }
        }
        c1++;
        c2++;
        if (maxDistance)
        {
            var temporaryDistance=Math.max(c1,c2)-lcss+trans;
            if (temporaryDistance>=maxDistance) return Math.round(temporaryDistance);
        }
        // this covers the case where the last match is on the last token in list, so that it can compute transpositions correctly
        if ((c1 >= l1) || (c2 >= l2)) {
            lcss+=local_cs;
            local_cs=0;
            c1=c2=Math.min(c1,c2);
        }
    }
    lcss+=local_cs;
    return Math.round(Math.max(l1,l2)- lcss +trans); //add the cost of transpositions to the final result
}
