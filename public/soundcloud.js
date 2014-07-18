(function() {
  this.Soundcloud = (function() {
    function Soundcloud() {}

    Soundcloud.fetch = function(sc_id, client_id, callback) {
      var url;
      url = "http://api.soundcloud.com/tracks/" + sc_id + ".json?client_id=" + client_id;
      return $.get(url, function(track) {
        return callback(track);
      });
    };

    return Soundcloud;

  })();

}).call(this);
