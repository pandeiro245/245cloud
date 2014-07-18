(function() {
  var addAccesslog, complete, init, play, ruffnote, start;

  $(function() {
    return init();
  });

  init = function() {
    var $body, $item, $start, app_id, id, key, _i, _len, _ref;
    console.log('init');
    app_id = "8QzCMkUbx7TyEApZjDRlhpLQ2OUj0sQWTnkEExod";
    key = "gzlnFfIOoLFQzQ08bU4mxkhAHcSqEok3rox0PBOM";
    Parse.initialize(app_id, key);
    localStorage['client_id'] = '2b9312964a1619d99082a76ad2d6d8c6';
    addAccesslog();
    $body = $('body');
    $body.attr({
      style: 'text-align:center;'
    });
    $body.html('');
    _ref = ['header', 'contents', 'logs', 'footer'];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      id = _ref[_i];
      $item = $('<div></div>');
      $item.attr('id', id);
      $body.append($item);
    }
    ruffnote(13475, 'header');
    ruffnote(13477, 'footer');
    $("#logs").append("<hr />");
    ParseParse.all("Twitter", function(res) {
      var twitter, twitters, _j, _len1;
      twitters = {};
      for (_j = 0, _len1 = res.length; _j < _len1; _j++) {
        twitter = res[_j];
        twitters[twitter.attributes.twitter_id] = twitter.attributes;
      }
      return ParseParse.where("Workload", null, function(workloads) {
        var hour, min, t, w, workload, _k, _len2;
        for (_k = 0, _len2 = workloads.length; _k < _len2; _k++) {
          workload = workloads[_k];
          w = workload.attributes;
          t = new Date(workload.createdAt);
          hour = Util.zero(t.getHours());
          min = Util.zero(t.getMinutes());
          $("#logs").append("" + (w.artwork_url ? '<img src=\"' + w.artwork_url + '\" />' : '<div style=\"display:inline; border: 1px solid #000; padding:20px; text-align:center; vertical-align:middle;\">no image</div>') + "\n<img src=\"" + twitters[w.twitter_id].twitter_image + "\" />@" + hour + ":" + min + "<br />\n" + w.title + " <br />\n<a href=\"#" + w.sc_id + "\" class='fixed_start btn btn-default'>この曲で集中する</a>\n<hr />");
        }
        return $('.fixed_start').click(function() {
          return start();
        });
      });
    });
    if (localStorage['twitter_id']) {
      $start = $('<input>').attr('type', 'submit');
      $start.attr('id', 'start').attr('value', '曲お任せで24分間集中する！！').attr('type', 'submit');
    } else {
      $start = $('<a></a>').html('Twitterログイン');
      $start.attr('href', '/auth/twitter');
    }
    $start.attr('class', 'btn btn-default');
    $('#contents').html($start);
    return $('#start').click(function() {
      return start();
    });
  };

  start = function() {
    var $start;
    console.log('start');
    $("#logs").hide();
    $start = $('<div></div>').attr('id', 'playing');
    $('#contents').html($start);
    if (localStorage['sc_id'] === location.hash.replace(/#/, '') || location.hash.length < 1) {
      return ParseParse.all("Music", function(musics) {
        var n, sc_id;
        n = Math.floor(Math.random() * musics.length);
        sc_id = musics[n].attributes.sc_id;
        location.hash = sc_id;
        return play();
      });
    } else {
      return play();
    }
  };

  play = function() {
    console.log('play');
    localStorage['sc_id'] = location.hash.replace(/#/, '');
    return Soundcloud.fetch(localStorage['sc_id'], localStorage['client_id'], function(track) {
      var ap, key, params, _i, _j, _len, _len1, _ref, _ref1;
      params = {};
      _ref = ['sc_id', 'twitter_id'];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        key = _ref[_i];
        params[key] = localStorage[key];
      }
      _ref1 = ['title', 'artwork_url'];
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        key = _ref1[_j];
        params[key] = track[key];
      }
      params['host'] = location.host;
      ParseParse.create("Workload", params, function(workload) {
        return window.workload = workload;
      });
      localStorage['artwork_url'] = track.artwork_url;
      if (localStorage['is_dev']) {
        Util.countDown(3000, complete);
      } else {
        Util.countDown(25 * 60 * 1000, complete);
      }
      ap = localStorage['is_dev'] ? 'false' : 'true';
      return $("#playing").html("<iframe width=\"100%\" height=\"400\" scrolling=\"no\" frameborder=\"no\" src=\"https://w.soundcloud.com/player/?visual=true&url=http%3A%2F%2Fapi.soundcloud.com%2Ftracks%2F" + localStorage['sc_id'] + "&show_artwork=true&client_id=" + localStorage['client_id'] + "&auto_play=" + ap + "\"></iframe>");
    });
  };

  complete = function() {
    var $note, $recents, $track, $tracks, Comment, query;
    console.log('complete');
    window.workload.set('is_done', true);
    window.workload.save();
    localStorage['nishiko_end'] = (new Date()).getTime();
    $note = $('<table></table').attr('id', 'note').addClass('table').attr('style', 'width: 500px; margin: 0 auto;');
    $note.html('24分おつかれさまでした！5分間交換ノートが見られます');
    $recents = $('<div></div>').attr('class', 'recents');
    $note.append($recents);
    Comment = Parse.Object.extend("Comment");
    query = new Parse.Query(Comment);
    query.descending("createdAt");
    query.find({
      success: function(comments) {
        var $comment, c, hour, img, min, t, _i, _len;
        $comment = $('<input />').attr('id', 'comment').attr('style', 'width:100%; display: block;');
        $('#note').append($comment);
        $('#comment').keypress(function(e) {
          var body;
          if (e.which === 13) {
            body = $('#comment').val();
            return window.comment(body);
          }
        });
        for (_i = 0, _len = comments.length; _i < _len; _i++) {
          c = comments[_i];
          t = new Date(c.createdAt);
          hour = t.getHours();
          min = t.getMinutes();
          $recents.append("<tr>");
          img = c.attributes.twitter_image || "";
          $recents.append("<td><img src='" + img + "' /><td>");
          $recents.append("<td>" + (Util.parseHttp(c.attributes.body)) + "</td>");
          $recents.append("<td>" + hour + "時" + min + "分</td>");
          $recents.append("</tr>");
        }
        return $('#note').append($recents);
      }
    });
    $('#contents').attr({
      style: 'text-align:center;'
    });
    $('#contents').html($note);
    $track = $("<input />").attr('id', 'track');
    $tracks = $("<div></div>").attr('id', 'tracks');
    $('#contents').append("<hr /><h3>好きなパワーソングを探す</h3>");
    $('#contents').append($track);
    $('#contents').append($tracks);
    $('#track').keypress(function(e) {
      var q, url;
      if (e.which === 13) {
        q = $('#track').val();
        url = "http://api.soundcloud.com/tracks.json?client_id=" + localStorage['client_id'] + "&q=" + q + "&duration[from]=" + (19 * 60 * 1000) + "&duration[to]=" + (25 * 60 * 1000);
        return $.get(url, function(tracks) {
          var artwork, track, _i, _len, _results;
          if (tracks[0]) {
            _results = [];
            for (_i = 0, _len = tracks.length; _i < _len; _i++) {
              track = tracks[_i];
              artwork = '';
              if (track.artwork_url) {
                artwork = "<img src=\"" + track.artwork_url + "\" width=100px/>";
              }
              _results.push($('#tracks').append("<tr>\n  <td><a href=\"#" + track.id + "\">" + track.title + "</a></td>\n  <td>" + artwork + "</td>\n  <td>" + (Util.time(track.duration)) + "</td>\n</tr>"));
            }
            return _results;
          } else {
            return alert("「" + q + "」で24分前後の曲はまだ出てないようです...。他のキーワードで探してみてください！");
          }
        });
      }
    });
    return Util.countDown(5 * 60 * 1000, 'finish');
  };

  window.finish = function() {
    console.log('finish');
    localStorage.removeItem('nishiko_end');
    return location.reload();
  };

  window.comment = function(body) {
    var $recents, $tr, hour, img, key, min, params, t, _i, _len, _ref;
    console.log('comment');
    params = {
      body: body
    };
    _ref = ['twitter_id', 'twitter_nickname', 'twitter_image', 'sc_id', 'artwork_url'];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      key = _ref[_i];
      params[key] = localStorage[key];
    }
    ParseParse.create('Comment', params);
    $recents = $('#note .recents');
    t = new Date();
    hour = t.getHours();
    min = t.getMinutes();
    $tr = $('<tr></tr>');
    img = localStorage['twitter_image'];
    $tr.append("<td><img src='" + img + "' /><td>");
    $tr.append("<td>" + (Util.parseHttp(body)) + "</td>");
    $tr.append("<td>" + hour + "時" + min + "分</td>");
    $recents.prepend($tr);
    return $('#comment').val('');
  };

  ruffnote = function(id, dom) {
    console.log('ruffnote');
    return Ruffnote.fetch("pandeiro245/245cloud/" + id, dom);
  };

  addAccesslog = function() {
    console.log('addAccesslog');
    return ParseParse.create('Accesslog', Util.addTwitterInfo({
      url: location.href
    }));
  };

}).call(this);
