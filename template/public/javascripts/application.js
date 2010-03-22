$(document).ready(function(){
  if(!sortPlease) return;
  $.tablesorter.addWidget({
    id: "columnHighlight",
    format: function(table) {
      if (!this.tds)
        this.tds =  $("td", table.tBodies[0]);
      if (!this.headers)
        this.headers = $("thead th", table);
      this.tds.removeClass("sorted");
      var ascSort = $("th." + table.config.cssAsc);
      var descSort = $("th." + table.config.cssDesc);
      if (ascSort.length)
        index = this.headers.index(ascSort[0]);
      if (descSort.length)
        index = this.headers.index(descSort[0]);
      $("tr td:nth-child(" + (index+1) + ")", table.tBodies[0]).each(function(row){
        $(this).addClass('sorted');
      });
    }
  }); 
  $.tablesorter.addParser({
    id: "newNumbers",
    is: function(s,table) {
      var c = table.config;
      var obj = parseFloat(s, 10);
      return (obj === +obj) || (toString.call(obj) === '[object Number]');
    },
    format: function(s){
      return parseFloat(s, 10);
    },
    type: "numeric"
  });

  //initialize the table
  var table = window.table = $('#data').tablesorter({
    widgets: ['columnHighlight'],
    sortList: sortOrder//,
    //debug: true
  })
  .tablesorterPager({container: $("#pager"), positionFixed: false, size: perPage})
  .tablesorterMultiPageFilter({filterSelector: $("#filter input")});

});