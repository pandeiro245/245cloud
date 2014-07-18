(function() {
  this.Ruffnote = (function() {
    function Ruffnote() {}

    Ruffnote.fetch = function(path, name) {
      $("#" + name).html(localStorage["ruffnote_" + name]);
      return $.get("/proxy?url=https://ruffnote.com/" + path + "/download.json", function(data) {
        localStorage["ruffnote_" + name] = data.content;
        return $("#" + name).html(data.content);
      });
    };

    return Ruffnote;

  })();

}).call(this);
