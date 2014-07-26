(function() {
  var Util;

  Util = (function() {
    function Util() {}

    Util.minAgo = function(min) {
      return new Date((new Date()).getTime() - min * 60 * 1000);
    };

    Util.scaffolds = function(ids) {
      var $body, $item, id, _i, _len, _results;
      $body = $('body');
      $body.html('');
      _results = [];
      for (_i = 0, _len = ids.length; _i < _len; _i++) {
        id = ids[_i];
        $item = $('<div></div>');
        $item.attr('id', id);
        _results.push($body.append($item));
      }
      return _results;
    };

    Util.time = function(mtime) {
      var day, hour, min, month, sec, time;
      if (mtime < 24 * 3600 * 1000) {
        time = parseInt(mtime / 1000);
        min = parseInt(time / 60);
        sec = time - min * 60;
        return "" + (Util.zero(min)) + ":" + (Util.zero(sec));
      } else {
        time = new Date(mtime * 1000);
        month = time.getMonth() + 1;
        day = time.getDate();
        hour = time.getHours();
        min = time.getMinutes();
        return "" + (Util.zero(month)) + "/" + (Util.zero(day)) + " " + (Util.zero(hour)) + ":" + (Util.zero(min));
      }
    };

    Util.zero = function(i) {
      if (i < 10) {
        return "0" + i;
      } else {
        return "" + i;
      }
    };

    Util.countDown = function(duration, callback, started) {
      var past;
      if (callback == null) {
        callback = 'reload';
      }
      if (started == null) {
        started = null;
      }
      if (!started) {
        started = (new Date()).getTime();
      }
      past = (new Date()).getTime() - started;
      if (duration > past) {
        $('title').html(Util.time(duration - past));
        if (callback === 'reload') {
          return setTimeout("Util.countDown(" + duration + ", null, " + started + ")", 1000);
        } else {
          return setTimeout("Util.countDown(" + duration + ", " + callback + ", " + started + ")", 1000);
        }
      } else {
        if (callback === 'reload') {
          return location.reload();
        } else {
          return callback();
        }
      }
    };

    Util.parseHttp = function(str) {
      return str.replace(/https?:\/\/[\w?=&.\/-;#~%-]+(?![\w\s?&.\/;#~%"=-]*>)/g, function(http) {
        var text;
        text = http;
        if (text.length > 20) {
          text = text.substring(0, 21) + "...";
        }
        return "<a href=\"" + http + "\" target=\"_blank\">" + text + "</a>";
      });
    };

    Util.addTwitterInfo = function(params) {
      return $.extend(params, {
        twitter_id: localStorage['twitter_id'],
        twitter_nickname: localStorage['twitter_nickname'],
        twitter_image: localStorage['twitter_image']
      });
    };

    return Util;

  })();

  window.Util = window.Util || Util;

}).call(this);
