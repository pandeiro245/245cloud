(function() {
  this.ParseParse = (function() {
    function ParseParse() {}

    ParseParse.find = function(model_name, id, callback) {};

    ParseParse.where = function(model_name, cond, callback) {
      var Model, query;
      Model = Parse.Object.extend(model_name);
      query = new Parse.Query(Model);
      query.equalTo("is_done", true);
      query.descending("createdAt");
      return query.find({
        success: function(data) {
          return callback(data);
        }
      });
    };

    ParseParse.all = function(model_name, callback) {
      var Model, query;
      Model = Parse.Object.extend(model_name);
      query = new Parse.Query(Model);
      return query.find({
        success: function(data) {
          return callback(data);
        }
      });
    };

    ParseParse.find_or_create = function(model_name, key_params, params, callback) {};

    ParseParse.create = function(model_name, params, callback) {
      var Model, key, model, val;
      if (callback == null) {
        callback = null;
      }
      Model = Parse.Object.extend(model_name);
      model = new Model();
      for (key in params) {
        val = params[key];
        if (key.match(/_id$/)) {
          val = parseInt(val);
        }
        model.set(key, val);
      }
      return model.save(null, {
        error: function(model, error) {
          return console.log(error);
        },
        success: function(model) {
          if (callback) {
            return callback(model);
          }
        }
      });
    };

    return ParseParse;

  })();

}).call(this);
